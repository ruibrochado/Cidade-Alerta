import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';
import '../robots/nav_robot.dart';

void main() {
  patrolTest(
    'UAT 11: User starts a report, corrects information, and successfully submits',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);
      final nav = NavRobot($);

      await auth.login('teste@cidadealerta.pt', '123456');

      await $(Icons.add).tap();
      await $.pumpAndSettle();

      await $('Estradas').tap();
      await $.pumpAndSettle();

      await $(TextField).at(0).enterText('Buraco');
      await $(TextField).at(1).enterText('Um buraco pequeno.');

      await $('Buraco').enterText('Buraco Enorme e Perigoso');
      await $('Um buraco pequeno.').enterText('Este buraco está a ocupar a faixa de rodagem toda!');

      await $(Icons.camera_alt).tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await $.native.tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));
      await $.native.tap(Selector(resourceId: 'com.android.camera2:id/done_button'));
      await $.pumpAndSettle();

      await $('Submeter Denúncia').tap();

      await $.waitUntilVisible($('Denúncia Enviada'));
      expect($('Ticket #'), findsOneWidget);

      await $('Voltar ao Início').tap();
      expect($(Icons.home), findsOneWidget);
    },
  );
}