import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart' as app;

void main() {
  patrolTest(
    'Full Report  ',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      await $(Icons.add).tap();
      await $('Lixo e Limpeza').tap();
      await $.pumpAndSettle();

      await $(Icons.arrow_back).tap();
      await $.pumpAndSettle();

      await $('Infraestrutura').tap();
      await $.pumpAndSettle();

      await $(TextField).at(0).enterText('Cano Partido');
      await $(TextField).at(1).enterText('Água a jorrar na Rua Principal desde as 8h.');
      await $('Continuar').tap();
      await $.pumpAndSettle();

      await $(Icons.camera_alt).tap();
      await $.native.tap(Selector(text: 'Shutter'));
      await $.native.tap(Selector(text: 'Done'));
      await $.pumpAndSettle();

      expect($('Confirmar Denúncia'), findsOneWidget);
      expect($('Cano Partido'), findsOneWidget);

      await $('Enviar Denúncia').tap();

      await $.waitUntilVisible($('Sucesso!'));
      expect($('Ticket Number'), findsOneWidget);
    },
  );
}