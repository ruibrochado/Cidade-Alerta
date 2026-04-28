import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class SocialRobot {
  final PatrolIntegrationTester $;
  SocialRobot(this.$);

  // --- LIKES (UPVOTES) ---
  Future<void> tapUpvote() async {
    // Serve tanto para dar Like como para Tirar (toggle)
    await $(Icons.arrow_upward).first.tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  // --- DISLIKES (DOWNVOTES) ---
  Future<void> tapDownvote() async {
    // Serve tanto para dar Dislike como para Tirar (toggle)
    // NOTA: Confirma se o teu ícone na UI é mesmo o arrow_downward
    await $(Icons.arrow_downward).first.tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  // --- COMENTÁRIOS ---
  Future<void> openComments() async {
    await $(Icons.chat_bubble_outline).first.tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> writeAndSubmitComment(String commentText) async {
    await $(TextField).enterText(commentText);

    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();

    await $(Icons.send_rounded).tap();

    // Dá apenas tempo para enviar antes de fechar
    await Future.delayed(const Duration(seconds: 2));
    await $.pump();
  }

  // NOVA FUNÇÃO: Fechar a janela no "X"
  Future<void> closeComments() async {
    await $(Icons.close).tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }
}