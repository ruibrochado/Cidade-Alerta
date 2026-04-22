import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// ATENÇÃO: Substitui 'cidade_alerta' pelo nome real do teu package
import 'package:app/main.dart' as app;

void main() {
  patrolTest(
    'Teste Zero: Infraestrutura Android e Patrol a funcionar',
        ($) async {
      // 1. O Patrol injeta a app no emulador e arranca-a
      app.main();

      // 2. Espera que a aplicação abra completamente e que as animações terminem
      await $.pumpAndSettle();

      // 3. Validação estrutural base:
      // O Scaffold é a fundação visual de 99% das apps Flutter.
      // Se o Patrol o encontrar, a ponte entre o Dart e o UIAutomator está perfeita.
      expect($(Scaffold), findsWidgets);
    },
  );
}