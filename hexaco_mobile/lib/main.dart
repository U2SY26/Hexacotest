import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'controllers/test_controller.dart';
import 'data/data_repository.dart';
import 'screens/home_screen.dart';
import 'screens/test_screen.dart';
import 'screens/result_screen.dart';
import 'ui/app_tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!const bool.fromEnvironment('FLUTTER_TEST')) {
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
          default:
            return MaterialPageRoute(
              builder: (_) => HomeScreen(controller: controller),
            );
        }
      },
    );
  }
}
