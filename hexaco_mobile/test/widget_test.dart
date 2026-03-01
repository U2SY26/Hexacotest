import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hexaco_mobile/controllers/test_controller.dart';
import 'package:hexaco_mobile/data/data_repository.dart';
import 'package:hexaco_mobile/models/question.dart';
import 'package:hexaco_mobile/models/type_profile.dart';
import 'package:hexaco_mobile/screens/home_screen.dart';

void main() {
  testWidgets('Home screen renders', (WidgetTester tester) async {
    const question = Question(
      id: 1,
      factor: 'H',
      facet: 1,
      reverse: false,
      tier: 1,
      ko: '테스트 문항',
      en: 'Test item',
    );

    const profile = TypeProfile(
      id: 'T001',
      nameKo: '샘플 타입',
      nameEn: 'Sample Type',
      descriptionKo: '샘플 설명',
      descriptionEn: 'Sample description',
      scores: {'H': 50, 'E': 50, 'X': 50, 'A': 50, 'C': 50, 'O': 50},
    );

    final data = AppData(questions: [question], types: [profile], insights: []);
    final controller = TestController(data);

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(controller: controller),
      ),
    );

    expect(find.textContaining('HEXACO'), findsWidgets);
  });
}
