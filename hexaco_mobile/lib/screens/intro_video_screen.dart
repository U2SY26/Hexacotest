import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../ui/app_tokens.dart';

class IntroVideoScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const IntroVideoScreen({super.key, required this.onComplete});

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('intro_video_shown') ?? false);
  }

  static Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('intro_video_shown', true);
  }
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showSkip = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    // Show skip button after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showSkip = true);
      }
    });
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset('assets/video/intro.mp4');

    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.play();

      _controller.addListener(() {
        if (_controller.value.position >= _controller.value.duration) {
          _onVideoComplete();
        }
      });

      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (e) {
      // Video failed to load, skip to home
      _onVideoComplete();
    }
  }

  void _onVideoComplete() async {
    await IntroVideoScreen.markAsShown();
    widget.onComplete();
  }

  void _skipVideo() {
    _controller.pause();
    _onVideoComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            if (_initialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.purple500,
                ),
              ),

            // Skip Button
            if (_showSkip)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showSkip ? 1.0 : 0.0,
                  child: GestureDetector(
                    onTap: _skipVideo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '건너뛰기',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.skip_next,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Progress Indicator
            if (_initialized)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 24,
                right: 24,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: false,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.purple500,
                    bufferedColor: AppColors.purple500,
                    backgroundColor: AppColors.darkBorder,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
