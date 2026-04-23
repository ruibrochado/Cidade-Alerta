import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  final PatrolIntegrationTester $;

  HomeRobot(this.$);

  Future<void> tapHomeTab() async {
    await $('Inicio').tap();
    await $.pumpAndSettle();
  }

  Future<void> tapRecycleTab() async {
    await $('Reciclar').tap();
    await $.pumpAndSettle();
  }

  Future<void> tapMapTab() async {
    await $('Mapa').tap();
    await $.pumpAndSettle();
  }

  Future<void> tapAddReport() async {
    await $(Icons.add).tap();
    await $.pumpAndSettle();
  }

  void validateHomeLoaded() {
    expect($('Viste algum problema na cidade?'), findsOneWidget);
  }
}