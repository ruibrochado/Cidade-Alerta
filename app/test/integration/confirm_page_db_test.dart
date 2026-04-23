import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/issue_service.dart';

void main() {
  test('DATABASE: Create issue and verify ticket_number format directly from DB', () async {
    final service = IssueService();

    final ticket = await service.createIssue(
      title: 'Teste DB Real',
      description: 'Verificação de integridade',
      category: 'Outros',
      latitude: 41.15,
      longitude: -8.61,
    );

    final dbRecord = await Supabase.instance.client
        .from('issues')
        .select()
        .eq('title', 'Teste DB Real')
        .single();

    expect(dbRecord['ticket_number'], equals(ticket));
    expect(dbRecord['category'], equals('Outros'));

    print('Sucesso: Ticket ${dbRecord['ticket_number']} confirmado na base de dados.');
  });
}