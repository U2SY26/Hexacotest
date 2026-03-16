import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../config/admob_ids.dart';
import '../models/score.dart';
import '../models/counselor_persona.dart';
import '../services/counseling_llm_service.dart';
import '../services/counseling_timer_service.dart';
import '../services/history_service.dart';
import '../services/rewarded_ad_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/ad_banner.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/counselor_avatar.dart';

/// AI 심리상담 — 캐릭터 중심 대화 화면
class CounselingChatScreen extends StatefulWidget {
  final CounselorPersona persona;
  final bool isKo;

  const CounselingChatScreen({
    super.key,
    required this.persona,
    required this.isKo,
  });

  @override
  State<CounselingChatScreen> createState() => _CounselingChatScreenState();
}

class _CounselingChatScreenState extends State<CounselingChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isLoading = false;
  bool _timeExpired = false;
  bool _canWatchAd = true;
  Scores? _scores;
  late final String _deviceLanguage;
  late final String _deviceLocaleId;

  // Speech-to-text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  // Speech bubble pop-in animation
  late final AnimationController _bubbleController;
  late final Animation<double> _bubbleScale;

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bubbleScale = CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeOutBack,
    );
    _initSpeech();
    _init();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (mounted) setState(() => _isListening = false);
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  Future<void> _init() async {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    _deviceLanguage = locale.languageCode;
    _deviceLocaleId = locale.toString();

    final history = await HistoryService.load();
    if (history.isNotEmpty) {
      _scores = Scores.fromMap(history.first.scores);
    } else {
      _scores = const Scores(h: 50, e: 50, x: 50, a: 50, c: 50, o: 50);
    }

    _remainingSeconds = await CounselingTimerService.getRemainingSeconds();
    _canWatchAd = await CounselingTimerService.canWatchAd();

    RewardedAdService.loadAd();

    final greeting =
        CounselorPromptBuilder.greeting(widget.persona, _deviceLanguage);
    _messages.add(ChatMessage(
      role: 'assistant',
      content: greeting,
      timestamp: DateTime.now(),
    ));

    if (mounted) {
      setState(() {});
      _bubbleController.forward();
    }

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        if (mounted) setState(() => _timeExpired = true);
        return;
      }
      _remainingSeconds--;
      await CounselingTimerService.addUsedSeconds(1);
      if (mounted) {
        setState(() {
          if (_remainingSeconds <= 0) _timeExpired = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _bubbleController.dispose();
    _speech.stop();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading || _timeExpired) return;

    _textController.clear();

    // Stop listening if active
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }

    _messages.add(ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    ));

    _bubbleController.reset();
    setState(() => _isLoading = true);

    try {
      final response = await CounselingLLMService.sendMessage(
        counselor: widget.persona,
        history: _messages.sublist(0, _messages.length - 1),
        userMessage: text,
        scores: _scores!,
        languageCode: _deviceLanguage,
      );

      if (mounted) {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: response,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      if (mounted) {
        _messages.add(ChatMessage(
          role: 'assistant',
          content: _deviceLanguage == 'ko'
              ? '죄송합니다, 일시적인 문제가 발생했어요. 다시 말씀해주시겠어요?'
              : 'Sorry, something went wrong. Could you say that again?',
          timestamp: DateTime.now(),
        ));
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
      _bubbleController.forward();
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else if (_speechAvailable) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          _textController.text = result.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        },
        localeId: _deviceLocaleId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  void _showChatHistory() {
    final accentColor = Color(widget.persona.accentColor);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                widget.isKo ? '대화 기록' : 'Chat History',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return ChatBubble(
                    isUser: msg.role == 'user',
                    message: msg.content,
                    avatarEmoji:
                        msg.role == 'assistant' ? widget.persona.emoji : null,
                    accentColor: accentColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _watchAdForTime() async {
    final adShown = await RewardedAdService.showAd(
      onAdDismissed: () {},
      onUserEarnedReward: () async {
        await CounselingTimerService.incrementAdWatch();
        final remaining = await CounselingTimerService.getRemainingSeconds();
        final canWatch = await CounselingTimerService.canWatchAd();
        if (mounted) {
          setState(() {
            _remainingSeconds = remaining;
            _timeExpired = false;
            _canWatchAd = canWatch;
          });
          _startTimer();
        }
      },
    );
    if (!adShown) {
      RewardedAdService.loadAd();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isKo
                  ? '광고를 준비 중입니다. 잠시 후 다시 시도해주세요.'
                  : 'Preparing ad. Please try again in a moment.',
            ),
            backgroundColor: AppColors.orange500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(widget.persona.accentColor);

    // Latest counselor message for speech bubble
    String latestMsg = '';
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].role == 'assistant') {
        latestMsg = _messages[i].content;
        break;
      }
    }

    // Avatar reacts to state
    final avatarState = _isLoading
        ? CounselorState.talking
        : _isListening
            ? CounselorState.listening
            : CounselorState.idle;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkCard,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.persona.name(widget.isKo),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: accentColor,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _remainingSeconds > 60
                  ? AppColors.emerald500.withValues(alpha: 0.1)
                  : AppColors.red500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _remainingSeconds > 60
                    ? AppColors.emerald500.withValues(alpha: 0.3)
                    : AppColors.red500.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 14,
                  color: _remainingSeconds > 60
                      ? AppColors.emerald500
                      : AppColors.red500,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _remainingSeconds > 60
                        ? AppColors.emerald500
                        : AppColors.red500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          BannerAdWidget(adUnitId: bannerAdUnitId),

          // ── Main character area ──
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _messages.length > 1 ? _showChatHistory : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),

                    // Speech bubble (typing dots or latest message)
                    if (_isLoading)
                      _SpeechBubble(
                        accentColor: accentColor,
                        child: _TypingDots(accentColor: accentColor),
                      )
                    else if (latestMsg.isNotEmpty)
                      ScaleTransition(
                        scale: _bubbleScale,
                        alignment: Alignment.bottomCenter,
                        child: _SpeechBubble(
                          accentColor: accentColor,
                          child: Text(
                            latestMsg,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    // ── Large Rive avatar (center of screen) ──
                    CounselorAvatar(
                      persona: widget.persona,
                      state: avatarState,
                      size: 160,
                    ),

                    const SizedBox(height: 12),

                    // Listening indicator
                    if (_isListening)
                      Text(
                        widget.isKo ? '듣고 있어요...' : 'Listening...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.red500.withValues(alpha: 0.8),
                        ),
                      )
                    // History hint
                    else if (_messages.length > 2)
                      Text(
                        widget.isKo
                            ? '${_messages.length}개 메시지 · 탭하여 기록 보기'
                            : '${_messages.length} messages · tap for history',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ),

          // Time expired banner
          if (_timeExpired)
            _TimeExpiredBanner(
              isKo: widget.isKo,
              canWatchAd: _canWatchAd,
              onWatchAd: _watchAdForTime,
            ),

          // Input area with mic
          _InputArea(
            controller: _textController,
            isKo: widget.isKo,
            enabled: !_timeExpired && !_isLoading,
            accentColor: accentColor,
            onSend: _sendMessage,
            isListening: _isListening,
            speechAvailable: _speechAvailable,
            onMicTap: _toggleListening,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Speech Bubble — 말풍선 (아래쪽 꼬리 포함)
// ═══════════════════════════════════════════════════════════════════════════

class _SpeechBubble extends StatelessWidget {
  final Color accentColor;
  final Widget child;

  const _SpeechBubble({required this.accentColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accentColor.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(child: child),
        ),
        // Downward-pointing tail
        CustomPaint(
          size: const Size(20, 10),
          painter: _BubbleTailPainter(
            fillColor: AppColors.darkCard,
            borderColor: accentColor.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _BubbleTailPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
//  Typing Dots — 점 3개 바운스 애니메이션
// ═══════════════════════════════════════════════════════════════════════════

class _TypingDots extends StatefulWidget {
  final Color accentColor;
  const _TypingDots({required this.accentColor});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value * 3 - i) % 3).clamp(0.0, 1.0);
            final y = sin(phase * pi) * -6;
            return Transform.translate(
              offset: Offset(0, y),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor
                      .withValues(alpha: 0.3 + phase * 0.7),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Time Expired Banner
// ═══════════════════════════════════════════════════════════════════════════

class _TimeExpiredBanner extends StatelessWidget {
  final bool isKo;
  final bool canWatchAd;
  final VoidCallback onWatchAd;

  const _TimeExpiredBanner({
    required this.isKo,
    required this.canWatchAd,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange500.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            isKo ? '오늘 상담 시간이 종료되었습니다' : 'Today\'s session has ended',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (canWatchAd) ...[
            Text(
              isKo
                  ? '광고를 시청하면 5분을 추가할 수 있어요'
                  : 'Watch an ad to get 5 more minutes',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onWatchAd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_outline,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isKo ? '광고 보고 +5분' : 'Watch Ad +5min',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Text(
              isKo ? '내일 다시 만나요!' : 'See you tomorrow!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Input Area — 텍스트 입력 + 마이크 + 전송
// ═══════════════════════════════════════════════════════════════════════════

class _InputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isKo;
  final bool enabled;
  final Color accentColor;
  final VoidCallback onSend;
  final bool isListening;
  final bool speechAvailable;
  final VoidCallback onMicTap;

  const _InputArea({
    required this.controller,
    required this.isKo,
    required this.enabled,
    required this.accentColor,
    required this.onSend,
    required this.isListening,
    required this.speechAvailable,
    required this.onMicTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        children: [
          // Mic button
          if (speechAvailable)
            GestureDetector(
              onTap: enabled ? onMicTap : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? AppColors.red500.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: isListening
                        ? AppColors.red500.withValues(alpha: 0.5)
                        : AppColors.darkBorder,
                    width: isListening ? 2 : 1,
                  ),
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none_rounded,
                  size: 22,
                  color: isListening
                      ? AppColors.red500
                      : enabled
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.gray700,
                ),
              ),
            ),
          if (speechAvailable) const SizedBox(width: 6),

          // Text field
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: enabled
                    ? (isKo ? '메시지를 입력하세요...' : 'Type a message...')
                    : (isKo ? '상담 시간이 종료되었습니다' : 'Session ended'),
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                filled: true,
                fillColor: AppColors.darkBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.darkBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide:
                      BorderSide(color: accentColor.withValues(alpha: 0.5)),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                      color: AppColors.darkBorder.withValues(alpha: 0.5)),
                ),
              ),
              onSubmitted: (_) => onSend(),
              textInputAction: TextInputAction.send,
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: enabled ? onSend : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: enabled ? AppGradients.primaryButton : null,
                color: enabled ? null : AppColors.gray700,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 20,
                color: enabled ? Colors.white : AppColors.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
