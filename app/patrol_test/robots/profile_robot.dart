// ignore_for_file: deprecated_member_use
import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class ProfileRobot {
  final PatrolIntegrationTester $;

  ProfileRobot(this.$);

  Future<void> tapProfileIcon() async {
    await $(Icons.person).tap();
    await $.pumpAndSettle();
  }

  Future<void> openAndCloseTerms() async {
    await $('Termos e Privacidade').scrollTo().tap();
    await $.pumpAndSettle();

    await $('Termos e Privacidade').waitUntilVisible();

    await $.native.pressBack();
    await $.pumpAndSettle();
  }

  Future<void> editProfileAndSave(
    String novoPrimeiroNome,
    String novoApelido,
  ) async {
    await $('Editar perfil').scrollTo().tap();
    await $.pumpAndSettle();

    await $(TextField).at(0).enterText(novoPrimeiroNome);
    await $(TextField).at(1).enterText(novoApelido);

    await $.pumpAndSettle();

    await $('Guardar Alterações').tap();
    await $.pumpAndSettle();
  }

  Future<void> deleteAccount() async {
    await $('Eliminar conta').scrollTo().tap();
    await $.pumpAndSettle();

    await $('Eliminar').tap();
    await $.pumpAndSettle();
  }
}
