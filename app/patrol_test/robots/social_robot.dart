import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class SocialRobot {
  final PatrolIntegrationTester $;
  SocialRobot(this.$);

  Future<void> tapUpvote() async {
    await $(Icons.arrow_upward).first.tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> tapDownvote() async {
    await $(Icons.arrow_downward).first.tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

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

    await Future.delayed(const Duration(seconds: 2));
    await $.pump();
  }

  Future<void> closeComments() async {
    await $(Icons.close).tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> verifyReportDetailsVisible() async {
    await $('Detalhes da Denúncia').waitUntilVisible();
  }
}
