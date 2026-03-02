import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'controllers/test_controller.dart';
import 'data/data_repository.dart';
import 'screens/home_screen.dart';
import 'screens/intro_video_screen.dart';
import 'screens/test_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/card_collection_screen.dart';
import 'services/analytics_service.dart';
import 'services/version_check_service.dart';
import 'ui/app_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!const bool.fromEnvironment('FLUTTER_TEST')) {
    // Firebase 초기화
    await Firebase.initializeApp();
    AnalyticsService.init();

    // Remote Config 초기화 (버전 체크용)
    await VersionCheckService.init();

    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified),
    );
  }
  final data = await DataRepository.load();
  runApp(HexacoApp(data: data));
}

class HexacoApp extends StatelessWidget {
  final AppData data;
  final TestController controller;

  HexacoApp({super.key, required this.data}) : controller = TestController(data);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.purple500,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      title: '5분 - 나를 알아보기 위한 투자',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppColors.darkBg,
        fontFamily: 'Pretendard',
        textTheme: ThemeData.dark(useMaterial3: true)
            .textTheme
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
              builder: (_) => _InitialScreen(controller: controller),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (_) => HomeScreen(controller: controller),
            );
          case '/test':
            return MaterialPageRoute(
              builder: (_) => TestScreen(controller: controller),
            );
          case '/result':
            return MaterialPageRoute(
              builder: (_) => ResultScreen(controller: controller, data: data),
            );
          case '/settings':
            return MaterialPageRoute(
              builder: (_) => SettingsScreen(controller: controller),
            );
          case '/collection':
            return MaterialPageRoute(
              builder: (_) => CardCollectionScreen(
                isKo: controller.language == 'ko',
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => HomeScreen(controller: controller),
            );
        }
      },
    );
  }
}

class _InitialScreen extends StatefulWidget {
  final TestController controller;

  const _InitialScreen({required this.controller});

  @override
  State<_InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<_InitialScreen> {
  bool? _showIntro;

  @override
  void initState() {
    super.initState();
    _checkIntro();
  }

  Future<void> _checkIntro() async {
    final shouldShow = await IntroVideoScreen.shouldShow();
    if (mounted) {
      setState(() => _showIntro = shouldShow);
    }
  }

  void _onIntroComplete() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro == null) {
      return const Scaffold(
        backgroundColor: AppColors.darkBg,
        body: Center(child: CircularProgressIndicator(color: AppColors.purple500)),
      );
    }

    if (_showIntro!) {
      return IntroVideoScreen(onComplete: _onIntroComplete);
    }

    return HomeScreen(controller: widget.controller);
  }
}
