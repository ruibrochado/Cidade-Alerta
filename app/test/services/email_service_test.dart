import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/email_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockFunctionResponse extends Mock implements FunctionResponse {}

void main() {
  group('EmailService Tests', () {
    late EmailService emailService;
    late MockSupabaseClient mockSupabaseClient;
    late MockFunctionsClient mockFunctionsClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockFunctionsClient = MockFunctionsClient();

      when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);

      emailService = EmailService(client: mockSupabaseClient);
    });

    test('Should send email successfully to the Municipal Council', () async {
      final mockResponse = MockFunctionResponse();
      when(() => mockResponse.status).thenReturn(200);
      when(() => mockResponse.data).thenReturn({'success': true});

      when(
        () => mockFunctionsClient.invoke(
          'resend-email',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await emailService.sendEmail(
        to: 'geral@cm-porto.pt',
        subject: 'Alerta: Risco de Infraestrutura',
        html: '<p>Buraco na via pública.</p>',
      );

      expect(result, equals({'success': true}));
      verify(
        () => mockFunctionsClient.invoke(
          'resend-email',
          body: {
            'to': 'geral@cm-porto.pt',
            'subject': 'Alerta: Risco de Infraestrutura',
            'html': '<p>Buraco na via pública.</p>',
          },
        ),
      ).called(1);
    });

    test('Should throw exception when Edge Function fails', () async {
      final mockResponse = MockFunctionResponse();
      when(() => mockResponse.status).thenReturn(500);
      when(() => mockResponse.data).thenReturn('Internal Server Error');

      when(
        () => mockFunctionsClient.invoke(
          'resend-email',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      expect(
        () => emailService.sendEmail(
          to: 'geral@cm-porto.pt',
          subject: 'Alerta: Risco de Infraestrutura',
          html: '<p>Buraco na via pública.</p>',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Function failed. Status: 500'),
          ),
        ),
      );
    });
  });
}