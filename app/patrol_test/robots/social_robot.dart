import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SocialRobot {
  final PatrolIntegrationTester $;
  SocialRobot(this.$);

  Future<void> toggleUpvote() async {
    // Tap the upvote icon (arrow upward)
    await $(Icons.arrow_upward).first.tap();
    await $.pumpAndSettle();
  }

  Future<void> openComments() async {
    // Tap the comment icon (chat bubble)
    await $(
      Icons.chat_bubble_outline,
    ).first.tap(); // Or Icons.chat if it's filled
    await $.pumpAndSettle();
  }

  Future<void> writeAndSubmitComment(String commentText) async {
    // Enter text in the comment field
    await $(TextField).enterText(commentText);

    // Tap the send button (send icon)
    await $(Icons.send).tap();
    await $.pumpAndSettle();
  }

  void verifyCommentAdded(String commentText) {
    // Verify the comment appears in the list
    expect($(commentText), findsOneWidget);
  }
}
