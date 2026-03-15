import * as admin from "firebase-admin";
import {onDocumentCreated, onDocumentDeleted} from "firebase-functions/v2/firestore";
import {onCall, HttpsError} from "firebase-functions/v2/https";

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// ─── Helper: Add XP and check level-up ───

async function addXp(userId: string, amount: number): Promise<boolean> {
  const userRef = db.collection("community_users").doc(userId);

  return db.runTransaction(async (tx) => {
    const doc = await tx.get(userRef);
    if (!doc.exists) return false;

    const data = doc.data()!;
    const oldXp = (data.xp as number) || 0;
    const oldLevel = (data.level as number) || 1;
    const newXp = Math.max(0, oldXp + amount);
    const newLevel = calculateLevel(newXp);

    tx.update(userRef, {xp: newXp, level: newLevel, updatedAt: admin.firestore.FieldValue.serverTimestamp()});

    if (newLevel > oldLevel) {
      // Create level-up notification
      await createNotification(userId, {
        type: "levelup",
        fromNickname: "System",
        message: `레벨 ${newLevel} 달성! 축하합니다!`,
      });
      return true;
    }
    return false;
  });
}

function calculateLevel(totalXp: number): number {
  let level = 1;
  let cumulative = 0;
  while (true) {
    const needed = 30 * level;
    if (cumulative + needed > totalXp) break;
    cumulative += needed;
    level++;
  }
  return level;
}

// ─── Helper: Create notification + FCM push ───

async function createNotification(
  userId: string,
  data: {type: string; postId?: string; commentId?: string; fromNickname: string; message: string}
) {
  // Save to Firestore
  await db.collection("notifications").doc(userId).collection("items").add({
    ...data,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Send FCM push
  try {
    const userDoc = await db.collection("community_users").doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;
    if (fcmToken) {
      await messaging.send({
        token: fcmToken,
        notification: {title: "Hexaco 커뮤니티", body: data.message},
        data: {type: data.type, postId: data.postId || "", commentId: data.commentId || ""},
      });
    }
  } catch (e) {
    console.error("FCM send failed:", e);
  }
}

// ─── Helper: Apply ban ───

async function applyBan(userId: string) {
  const userRef = db.collection("community_users").doc(userId);
  const doc = await userRef.get();
  if (!doc.exists) return;

  const banCount = ((doc.data()!.banCount as number) || 0) + 1;
  let banUntil: Date | null = null;

  if (banCount === 1) {
    banUntil = new Date(Date.now() + 24 * 60 * 60 * 1000); // 1 day
  } else if (banCount === 2) {
    banUntil = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000); // 3 days
  }
  // banCount >= 3: permanent (no banUntil needed, checked by client as banCount >= 3)

  await userRef.update({
    banCount,
    banUntil: banUntil ? admin.firestore.Timestamp.fromDate(banUntil) : null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ─── Post Report ───

export const onPostReport = onDocumentCreated(
  "posts/{postId}/reports/{reporterId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = db.collection("posts").doc(postId);

    const reportCount = (await postRef.collection("reports").count().get()).data().count;

    if (reportCount >= 3) {
      const postDoc = await postRef.get();
      const authorId = postDoc.data()?.authorId;

      await postRef.update({isBlinded: true, reportCount});
      await addXp(authorId, -30);
      await applyBan(authorId);

      await createNotification(authorId, {
        type: "report",
        postId,
        fromNickname: "System",
        message: "게시글이 신고로 인해 블라인드 처리되었습니다.",
      });
    } else {
      await postRef.update({reportCount});
    }
  }
);

// ─── Comment Report ───

export const onCommentReport = onDocumentCreated(
  "posts/{postId}/comments/{commentId}/reports/{reporterId}",
  async (event) => {
    const {postId, commentId} = event.params;
    const commentRef = db.collection("posts").doc(postId).collection("comments").doc(commentId);

    const reportCount = (await commentRef.collection("reports").count().get()).data().count;

    if (reportCount >= 3) {
      const commentDoc = await commentRef.get();
      const authorId = commentDoc.data()?.authorId;

      await commentRef.update({isBlinded: true, reportCount});
      await addXp(authorId, -30);
      await applyBan(authorId);

      await createNotification(authorId, {
        type: "report",
        postId,
        commentId,
        fromNickname: "System",
        message: "댓글이 신고로 인해 블라인드 처리되었습니다.",
      });
    } else {
      await commentRef.update({reportCount});
    }
  }
);

// ─── Post Like ───

export const onPostLike = onDocumentCreated(
  "posts/{postId}/likes/{likerId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = db.collection("posts").doc(postId);

    const likeCount = (await postRef.collection("likes").count().get()).data().count;
    await postRef.update({likeCount});

    const postDoc = await postRef.get();
    const authorId = postDoc.data()?.authorId;
    const likerId = event.params.likerId;

    if (authorId && authorId !== likerId) {
      await addXp(authorId, 3);

      const likerDoc = await db.collection("community_users").doc(likerId).get();
      const likerNickname = likerDoc.data()?.nickname || "누군가";

      await createNotification(authorId, {
        type: "like",
        postId,
        fromNickname: likerNickname,
        message: `${likerNickname}님이 회원님의 글을 좋아합니다.`,
      });
    }
  }
);

// ─── Post Unlike ───

export const onPostUnlike = onDocumentDeleted(
  "posts/{postId}/likes/{likerId}",
  async (event) => {
    const postId = event.params.postId;
    const postRef = db.collection("posts").doc(postId);
    const likeCount = (await postRef.collection("likes").count().get()).data().count;
    await postRef.update({likeCount});
  }
);

// ─── Comment Like ───

export const onCommentLike = onDocumentCreated(
  "posts/{postId}/comments/{commentId}/likes/{likerId}",
  async (event) => {
    const {postId, commentId, likerId} = event.params;
    const commentRef = db.collection("posts").doc(postId).collection("comments").doc(commentId);

    const likeCount = (await commentRef.collection("likes").count().get()).data().count;
    await commentRef.update({likeCount});

    const commentDoc = await commentRef.get();
    const authorId = commentDoc.data()?.authorId;

    if (authorId && authorId !== likerId) {
      await addXp(authorId, 3);

      const likerDoc = await db.collection("community_users").doc(likerId).get();
      const likerNickname = likerDoc.data()?.nickname || "누군가";

      await createNotification(authorId, {
        type: "like",
        postId,
        commentId,
        fromNickname: likerNickname,
        message: `${likerNickname}님이 회원님의 댓글을 좋아합니다.`,
      });
    }

    // BEST check
    if (likeCount >= 5) {
      const wasBest = commentDoc.data()?.isBest || false;
      if (!wasBest) {
        await commentRef.update({isBest: true});
        await addXp(authorId, 20);

        await createNotification(authorId, {
          type: "best",
          postId,
          commentId,
          fromNickname: "System",
          message: "회원님의 댓글이 BEST로 선정되었습니다! (+20 XP)",
        });
      }
    }
  }
);

// ─── Comment Unlike ───

export const onCommentUnlike = onDocumentDeleted(
  "posts/{postId}/comments/{commentId}/likes/{likerId}",
  async (event) => {
    const {postId, commentId} = event.params;
    const commentRef = db.collection("posts").doc(postId).collection("comments").doc(commentId);
    const likeCount = (await commentRef.collection("likes").count().get()).data().count;
    await commentRef.update({likeCount});
  }
);

// ─── New Comment ───

export const onNewComment = onDocumentCreated(
  "posts/{postId}/comments/{commentId}",
  async (event) => {
    const {postId, commentId} = event.params;
    const data = event.data?.data();
    if (!data) return;

    const postRef = db.collection("posts").doc(postId);

    // Increment post comment count
    const commentCount = (await postRef.collection("comments")
      .where("isDeleted", "==", false).count().get()).data().count;
    await postRef.update({commentCount});

    // Award XP to commenter
    await addXp(data.authorId, 5);

    // Notify
    const parentCommentId = data.parentCommentId;
    if (parentCommentId) {
      // Reply — notify parent comment author
      const parentDoc = await postRef.collection("comments").doc(parentCommentId).get();
      const parentAuthorId = parentDoc.data()?.authorId;
      if (parentAuthorId && parentAuthorId !== data.authorId) {
        await createNotification(parentAuthorId, {
          type: "reply",
          postId,
          commentId,
          fromNickname: data.nickname,
          message: `${data.nickname}님이 회원님의 댓글에 답글을 달았습니다.`,
        });
      }
    } else {
      // Top-level comment — notify post author
      const postDoc = await postRef.get();
      const postAuthorId = postDoc.data()?.authorId;
      if (postAuthorId && postAuthorId !== data.authorId) {
        await createNotification(postAuthorId, {
          type: "comment",
          postId,
          commentId,
          fromNickname: data.nickname,
          message: `${data.nickname}님이 회원님의 글에 댓글을 달았습니다.`,
        });
      }
    }
  }
);

// ─── Content Filter (HTTPS Callable) ───

export const filterContent = onCall(async (request) => {
  const {text} = request.data;
  if (!text || typeof text !== "string") {
    throw new HttpsError("invalid-argument", "text is required");
  }

  // 1. Perspective API check
  const perspectiveApiKey = process.env.PERSPECTIVE_API_KEY;
  if (perspectiveApiKey) {
    try {
      const fetch = require("node-fetch");
      const response = await fetch(
        `https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze?key=${perspectiveApiKey}`,
        {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify({
            comment: {text},
            languages: ["ko", "en", "ja", "zh"],
            requestedAttributes: {
              TOXICITY: {},
              PROFANITY: {},
              THREAT: {},
            },
          }),
        }
      );
      const result = await response.json();
      const toxicity = result.attributeScores?.TOXICITY?.summaryScore?.value || 0;
      const profanity = result.attributeScores?.PROFANITY?.summaryScore?.value || 0;
      const threat = result.attributeScores?.THREAT?.summaryScore?.value || 0;

      if (toxicity >= 0.85 || profanity >= 0.90 || threat >= 0.85) {
        return {allowed: false, reason: "inappropriate_content"};
      }

      // Borderline — could add Gemini 2nd pass here
      if (toxicity >= 0.60) {
        // TODO: Gemini 2.5 Flash 2nd pass for borderline content
        // For now, allow borderline content
      }
    } catch (e) {
      console.error("Perspective API error:", e);
      // Allow on API failure (fail open)
    }
  }

  return {allowed: true};
});
