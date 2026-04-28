import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  final PatrolIntegrationTester $;

  HomeRobot(this.$);

  Future<void> tapHomeTab() async {
    await $('Inicio').tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> tapRecycleTab() async {
    await $('Reciclar').tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> tapMapTab() async {
    await $('Mapa').tap();
    // AVISO DE ARQUITETO: O mapa demora a renderizar e NUNCA usa pumpAndSettle!
    await Future.delayed(const Duration(seconds: 2));
    await $.pump();
  }

  Future<void> tapAddReport() async {
    await $(Icons.add).tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  // Agora é Future! E usa a inteligência do Patrol.
  Future<void> validateHomeLoaded() async {
    // Fica à espera ativamente até 10 segundos para ver se o texto aparece.
    // Assim que aparecer, passa logo ao próximo passo sem esperar mais!
    await $('Denúncias prioritárias').waitUntilVisible();
  }
}
