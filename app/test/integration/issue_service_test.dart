import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/services/issue_service.dart';

void main() {
  late IssueService issueService;

  setUpAll(() async {
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    );

    issueService = IssueService();
  });

  test('Database Integration: Should create and then verify record exists in DB', () async {
    final String uniqueTitle = 'Integration Test ${DateTime.now().millisecondsSinceEpoch}';

    final String ticket = await issueService.createIssue(
      title: uniqueTitle,
      description: 'Testing direct database persistence without mocks',
      category: 'road',
      latitude: 38.7223,
      longitude: -9.1393,
    );

    expect(ticket, isNotEmpty);

    final response = await Supabase.instance.client
        .from('issues')
        .select()
        .eq('title', uniqueTitle)
        .single();

    expect(response, isNotNull);
    expect(response['title'], equals(uniqueTitle));
    expect(response['ticket_number'], equals(ticket));

    await Supabase.instance.client
        .from('issues')
        .delete()
        .eq('title', uniqueTitle);
  });
}