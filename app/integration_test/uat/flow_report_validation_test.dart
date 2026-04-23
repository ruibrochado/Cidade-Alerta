import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';

void main() {
  patrolTest(
    'UAT 12: User tries to submit a report with empty fields and sees errors',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);

      await auth.login('teste@cidadealerta.pt', '123456');

      await $(Icons.add).tap();
      await $.pumpAndSettle();

      await $('Limpeza').tap();
      await $.pumpAndSettle();

      await $('Submeter Denúncia').tap();

      expect($('O título é obrigatório'), findsOneWidget);
      expect($('A descrição é obrigatória'), findsOneWidget);

      await $(TextField).at(0).enterText('Título Válido');
      await $('Submeter Denúncia').tap();

      expect($('O título é obrigatório'), findsNothing);
      expect($('A descrição é obrigatória'), findsOneWidget);
    },
  );
}