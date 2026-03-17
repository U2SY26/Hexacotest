# Community Board (커뮤니티 게시판) Design Spec

**Date**: 2026-03-15
**Status**: Approved
**Approach**: Firestore Direct Integration + Cloud Functions

---

## 1. Overview

Hexaco Mobile 앱에 익명 커뮤니티 게시판을 추가한다. 기존 기능(성격검사, 카드 수집, AI 상담)은 변경하지 않는다.

### Core Features
- 단일 자유게시판 (고민 상담, 자유 토론)
- 댓글 + 대댓글 (2depth)
- 다국어 자동 번역 (Gemini 2.5 Flash)
- 레벨링 시스템 (3dweb 참조, Rive 레벨업 애니메이션)
- 비속어 필터링 (Perspective API + Gemini 2.5 Flash)
- 신고 3건 누적 → 블라인드 + 누적 제재
- 엄지척 5개+ → BEST 라벨 + 최상단 댓글
- FCM 푸시 알림 + Firestore 알림 내역

---

## 2. User Identity System

### Authentication
- **Firebase Anonymous Auth** + 해시된 기기 ID 매핑
- 첫 게시판 진입 시 자동 로그인 + 닉네임 설정
- 기기 ID: Android `android_id` / iOS `identifierForVendor`
- **기기 ID는 SHA-256 해시하여 저장** (원본 저장 금지, 개인정보 보호)
- Anonymous Auth UID ↔ hashedDeviceId 매핑은 서버 측에서 검증

### Nickname
- 랜덤 자동 부여 (예: "용감한코끼리42")
- 사용자 변경 가능
- 중복 허용 (hashedDeviceId로 구분)

---

## 3. Firestore Data Model

### community_users/{hashedDeviceId}
```json
{
  "uid": "string (Firebase Auth UID)",
  "hashedDeviceId": "string (SHA-256)",
  "nickname": "string",
  "xp": 0,
  "level": 1,
  "reportCount": 0,
  "banCount": 0,
  "banUntil": null,
  "fcmToken": "string",
  "lang": "ko",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### posts/{postId}
```json
{
  "authorId": "string (hashedDeviceId)",
  "nickname": "string",
  "level": 1,
  "title": "string (max 100 chars)",
  "content": "string (max 2000 chars)",
  "lang": "string (작성 언어 코드)",
  "likeCount": 0,
  "commentCount": 0,
  "isBlinded": false,
  "reportCount": 0,
  "isEdited": false,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### posts/{postId}/comments/{commentId}
```json
{
  "authorId": "string (hashedDeviceId)",
  "nickname": "string",
  "level": 1,
  "content": "string (max 500 chars)",
  "lang": "string",
  "parentCommentId": "string | null",
  "likeCount": 0,
  "isBest": false,
  "isBlinded": false,
  "reportCount": 0,
  "isEdited": false,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### posts/{postId}/likes/{hashedDeviceId}
```json
{
  "createdAt": "Timestamp"
}
```

### posts/{postId}/comments/{commentId}/likes/{hashedDeviceId}
```json
{
  "createdAt": "Timestamp"
}
```

### posts/{postId}/reports/{hashedDeviceId}
```json
{
  "reason": "string (optional)",
  "createdAt": "Timestamp"
}
```

### posts/{postId}/comments/{commentId}/reports/{hashedDeviceId}
```json
{
  "reason": "string (optional)",
  "createdAt": "Timestamp"
}
```

### notifications/{hashedDeviceId}/items/{notifId}
```json
{
  "type": "comment | reply | like | best | report | levelup",
  "postId": "string",
  "commentId": "string | null",
  "fromNickname": "string",
  "message": "string",
  "isRead": false,
  "createdAt": "Timestamp"
}
```

### Composite Indexes Required
```
posts: isBlinded ASC, createdAt DESC
posts: isBlinded ASC, likeCount DESC
comments: parentCommentId ASC, isBest DESC, createdAt ASC
notifications/items: isRead ASC, createdAt DESC
```

---

## 4. Leveling System

### XP Rewards
| Activity | XP |
|---|---|
| Post created | +10 |
| Comment/reply created | +5 |
| Like received | +3 |
| BEST comment (5+ likes) | +20 |
| Blinded (reported) | -30 |

### Level Formula (from 3dweb)
Each level requires `30 * level` XP to advance. Cumulative XP: `15 * level * (level - 1)`.
```
Level 1 → 0 XP (need 30 to level up)
Level 2 → 30 XP (need 60 to level up)
Level 3 → 90 XP (need 90 to level up)
Level 4 → 180 XP (need 120 to level up)
Level 5 → 300 XP ...
```

### Badge Tiers
| Level | Color | Hex | Effects |
|---|---|---|---|
| 1-4 | Gray | #9CA3AF | None |
| 5-9 | Green | #10B981 | None |
| 10-19 | Blue | #3B82F6 | Glow |
| 20-49 | Purple | #8B5CF6 | Glow |
| 50+ | Gold | #F59E0B | Glow + Shimmer |

### Rive Level-Up Animation
- Source: `E:\Hexacotest\22243-46463-level-up (1).riv` (Rive Community, by Maximized, CC BY)
- Hexagon design — HEXACO 앱 테마와 일치
- State machine inputs: `Level` (SMINumber), `currentXP` (SMINumber), `nextlvlXP` (SMINumber), `Replay` (SMITrigger)
- Move to `assets/rive/level_up.riv`
- Adapt `level_up_overlay.dart` and `level_badge.dart` widgets from 3dweb, match Hexaco styling

---

## 5. Content Moderation

### Profanity Filter (Two-Pass)
1. **Perspective API** — toxicity, profanity, threat scores (multilingual)
   - Block threshold: toxicity >= 0.85 or profanity >= 0.90
   - Borderline range: toxicity 0.60-0.85
2. **Gemini 2.5 Flash** — contextual review if Perspective scores in borderline range
   - Prompt: "Is this content inappropriate for a community board? Reply YES or NO with reason."
   - Block if Gemini returns YES

### UX During Filter
- Show loading spinner with "검토 중..." / "Checking..." message
- Typical latency: 1-2 seconds

### Rate Limiting
| Action | Cooldown | Max per day |
|---|---|---|
| Post | 30 seconds | Unlimited |
| Comment/Reply | 10 seconds | Unlimited |
| Report | 5 seconds | 10 |

### Content Length Limits
| Field | Max |
|---|---|
| Post title | 100 chars |
| Post content | 2000 chars |
| Comment/Reply | 500 chars |

### Reporting & Sanctions
- **3 reports from different users** → automatic blind
- Cloud Function increments `banCount`, sets `banUntil` timestamp

| Cumulative Blinds | Sanction |
|---|---|
| 1st | 1 day write ban |
| 2nd | 3 days write ban |
| 3rd+ | Permanent write ban (read-only) |

- Client checks `banUntil` before allowing post/comment creation
- Server-side validation in security rules as backup

---

## 6. Post/Comment Management

### Edit
- Author can edit own post/comment anytime (no time limit)
- Sets `isEdited: true`, updates `updatedAt`
- Re-runs profanity filter on edited content

### Delete
- Author can delete own post/comment anytime
- Soft delete: set `isDeleted: true` (preserves comment tree structure)
- Deleted content shows as "삭제된 글입니다" / "This post has been deleted"

---

## 7. Translation

- **Trigger**: User taps translate button on post/comment
- **Engine**: Gemini 2.5 Flash via Firebase AI
- **Flow**: Detect source lang → translate to user's device language
- **Cache**: Store translated text in client memory (not Firestore) to reduce API calls within session

---

## 8. BEST Comment System

- Comment reaches 5+ likes → Cloud Function sets `isBest: true`
- BEST comments display with highlight label and sort to top
- Multiple BEST comments per post allowed, ordered by likeCount DESC
- BEST XP bonus: +20 XP to author (one-time, tracked by `bestXpAwarded` flag on comment)

---

## 9. Notification System

### Triggers (Cloud Functions)
| Event | Notification To | Type |
|---|---|---|
| New comment on my post | Post author | `comment` |
| Reply to my comment | Comment author | `reply` |
| Like on my post/comment | Author | `like` |
| My comment becomes BEST | Comment author | `best` |
| My post/comment blinded | Author | `report` |
| Level up | User | `levelup` |

### Notification Throttling
- Like notifications: batch to max 1 push per 5 minutes per post
  - e.g., "용감한코끼리 외 4명이 회원님의 글을 좋아합니다"
- Other notifications: send immediately

### Delivery
- **Firestore**: `notifications/{hashedDeviceId}/items/` collection for in-app history
- **FCM Push**: Cloud Function sends push notification via FCM (Admin SDK bypasses security rules for cross-user reads)
- **UI**: Bell icon (top-right, left of settings gear), red badge for unread count

---

## 10. New Screens

| Screen | Route | Description |
|---|---|---|
| `CommunityScreen` | `/community` | Post list, BEST posts highlighted |
| `PostDetailScreen` | `/community/post/:id` | Post detail + comments/replies, translate button |
| `PostWriteScreen` | `/community/write` | Post creation with profanity check |
| `NotificationScreen` | `/notifications` | Notification list with read/unread |
| `NicknameSetupScreen` | `/community/setup` | First-time nickname setup |

---

## 11. UI Integration

### Home Screen Changes
- Add "Community" entry point (bottom nav or card on home)
- Add bell icon (notification) to top-right app bar, left of settings gear
- Red badge on bell icon showing unread notification count

### Post List Layout
- Card-based list, each card shows: nickname + level badge, title, content preview, like count, comment count, time ago
- Pull-to-refresh
- Cursor-based pagination: `startAfterDocument`, 20 posts per page
- Sort: newest first (default)

### Comment Layout
- Flat list with indent for replies (parentCommentId)
- BEST comments pinned to top with highlight
- Each comment shows: nickname + level badge, content, like button, reply button, report button, translate button

### Offline/Error Handling
- No network: show cached data if available, "네트워크 연결을 확인해주세요" banner
- Write failures: show error snackbar, keep draft in text field
- No optimistic updates — wait for server confirmation

---

## 12. Cloud Functions Required

| Function | Trigger | Purpose |
|---|---|---|
| `onPostReport` | Firestore onCreate on `posts/{postId}/reports/{userId}` | Count reports, blind if >= 3, update author banCount/banUntil, notify, XP deduction |
| `onCommentReport` | Firestore onCreate on `comments/../reports/{userId}` | Count reports, blind if >= 3, update author banCount/banUntil, notify, XP deduction |
| `onCommentLike` | Firestore onCreate on `comments/../likes/{userId}` | Increment likeCount (transaction), check >= 5 → set isBest + award XP, notify |
| `onPostLike` | Firestore onCreate on `posts/{postId}/likes/{userId}` | Increment likeCount (transaction), award XP to author, notify |
| `onCommentDelete` | Firestore onDelete on `comments/../likes/{userId}` | Decrement likeCount (transaction) for unlike |
| `onPostUnlike` | Firestore onDelete on `posts/{postId}/likes/{userId}` | Decrement likeCount (transaction) for unlike |
| `onNewComment` | Firestore onCreate on comments | Increment post commentCount, notify post/parent comment author, award XP |
| `onLevelCheck` | Called by XP-modifying functions (not a separate trigger) | Recalculate level from XP, check level-up → notify |
| `filterContent` | HTTPS callable | Perspective API + Gemini 2.5 Flash content check, rate limit enforcement |

---

## 13. Dependencies (New)

### Flutter Packages
- `cloud_firestore` — Firestore SDK
- `firebase_auth` — Anonymous Auth
- `firebase_messaging` — FCM push notifications
- `crypto` — SHA-256 hashing for device ID

### Cloud Functions
- Perspective API via HTTP (requires API key)
- `firebase-admin` — Firestore admin, FCM
- Gemini 2.5 Flash via Firebase AI (already available)

### Assets
- `level_up.riv` — Rive Community hexagon level-up animation (CC BY, by Maximized)
- `level_badge.dart` — Badge widget adapted from 3dweb (adapt colors/styling)
- `level_up_overlay.dart` — Level-up overlay widget adapted from 3dweb

---

## 14. Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper: check if user is authenticated
    function isAuth() {
      return request.auth != null;
    }

    // Helper: check if user owns the document (authorId matches)
    function isOwner(authorId) {
      return isAuth() && request.auth.token.deviceId == authorId;
    }

    // community_users: owner read/write only
    match /community_users/{userId} {
      allow read: if isAuth() && request.auth.token.deviceId == userId;
      allow create: if isAuth() && request.auth.token.deviceId == userId;
      allow update: if isAuth() && request.auth.token.deviceId == userId
        && !request.resource.data.diff(resource.data).affectedKeys()
            .hasAny(['xp', 'level', 'banCount', 'banUntil', 'reportCount']);
      // xp, level, ban fields are server-only (Cloud Functions)
    }

    // posts
    match /posts/{postId} {
      allow read: if true;
      allow create: if isAuth()
        && request.resource.data.authorId == request.auth.token.deviceId
        && request.resource.data.likeCount == 0
        && request.resource.data.commentCount == 0
        && request.resource.data.isBlinded == false
        && request.resource.data.reportCount == 0
        && request.resource.data.title.size() <= 100
        && request.resource.data.content.size() <= 2000;
      allow update: if isOwner(resource.data.authorId)
        && !request.resource.data.diff(resource.data).affectedKeys()
            .hasAny(['likeCount', 'commentCount', 'isBlinded', 'reportCount', 'authorId']);
      allow delete: if isOwner(resource.data.authorId);

      // likes subcollection
      match /likes/{likeUserId} {
        allow read: if true;
        allow create: if isAuth() && request.auth.token.deviceId == likeUserId;
        allow delete: if isAuth() && request.auth.token.deviceId == likeUserId;
      }

      // reports subcollection
      match /reports/{reportUserId} {
        allow create: if isAuth() && request.auth.token.deviceId == reportUserId;
        // no read, no update, no delete for users
      }

      // comments subcollection
      match /comments/{commentId} {
        allow read: if true;
        allow create: if isAuth()
          && request.resource.data.authorId == request.auth.token.deviceId
          && request.resource.data.likeCount == 0
          && request.resource.data.isBlinded == false
          && request.resource.data.reportCount == 0
          && request.resource.data.content.size() <= 500;
        allow update: if isOwner(resource.data.authorId)
          && !request.resource.data.diff(resource.data).affectedKeys()
              .hasAny(['likeCount', 'isBest', 'isBlinded', 'reportCount', 'authorId']);
        allow delete: if isOwner(resource.data.authorId);

        match /likes/{likeUserId} {
          allow read: if true;
          allow create: if isAuth() && request.auth.token.deviceId == likeUserId;
          allow delete: if isAuth() && request.auth.token.deviceId == likeUserId;
        }

        match /reports/{reportUserId} {
          allow create: if isAuth() && request.auth.token.deviceId == reportUserId;
        }
      }
    }

    // notifications: owner read/update only
    match /notifications/{userId}/items/{notifId} {
      allow read: if isAuth() && request.auth.token.deviceId == userId;
      allow update: if isAuth() && request.auth.token.deviceId == userId
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['isRead']);
      // create/delete by Cloud Functions only (Admin SDK)
    }
  }
}
```

---

## 15. Out of Scope (Future)

- Image/media attachments in posts
- Direct messaging between users
- Category/tag system
- Search functionality
- Admin dashboard (web)
- CAPTCHA / bot prevention (monitor first, add if needed)
