import 'package:flutter/material.dart'; // IMPORT ADICIONADO
import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart' as app;

void main() {
  patrolTest('Jornada Completa do Cidadão Ativo', ($) async {
    await app.main();
    await $.pumpAndSettle();

    // --- LOGIN ---
    await $('Email').enterText('uat@gmail.com');
    await $('Password').enterText('uatuat');
    await $('Login').tap();

    // ignore: deprecated_member_use
    if (await $.native.isPermissionDialogVisible()) {
      // ignore: deprecated_member_use
      await $.native.grantPermissionWhenInUse();
    }

    await $.pumpAndSettle();
    expect($('Viste algum problema na cidade?'), findsOneWidget);

    // --- CRIAR DENÚNCIA ---
    await $('Denunciar').tap();
    await $('infraestrutura').tap();
    await $.pumpAndSettle();

    // --- RECICLAGEM ---
    await $('Reciclar').tap();
    await $('scan object').tap();

    // ignore: deprecated_member_use
    if (await $.native.isPermissionDialogVisible()) {
      // ignore: deprecated_member_use
      await $.native.grantPermissionWhenInUse();
    }
    // ignore: deprecated_member_use
    await $.native.pressBack();
    await $.pumpAndSettle();

    // --- VOTOS (Simplificado pelo Ícone) ---
    await $('Início').tap();
    await $.pumpAndSettle();

    // Clica na primeira seta de "Upward" (Upvote) que encontrar
    await $(Icons.arrow_upward).first.tap();
    await $.pumpAndSettle();

    // Clica na primeira seta de "Downward" (Downvote) que encontrar
    await $(Icons.arrow_downward).first.tap();
    await $.pumpAndSettle();

    // --- MAPA ---
    await $('Mapa').tap();
    await $.pumpAndSettle();
  });
}
