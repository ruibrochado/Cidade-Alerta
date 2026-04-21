import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/issue_service.dart';
import '../services/notification_service.dart';
import 'email_test_page.dart';
import 'recycling_scanner_page.dart';
import 'login_page.dart';
import 'map_page.dart';
import 'issue_category_page.dart';
import 'feed_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final issueService = IssueService();
  final notificationService = NotificationService();

  // LISTA VAZIA AO INÍCIO DA SESSÃO
  List<Map<String, dynamic>> sessionTests = [];
  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    notificationService.initialize();
    // A página já não faz loadIssues() ao entrar! Fica limpa.
  }

  Future<void> logout() async {
    await authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // CRIA O TESTE E METE NA LISTA DA HOME
  Future<void> createTestIssue() async {
    setState(() => isCreating = true);

    try {
      final String title = 'Test issue';
      final String category = 'road';

      // Envia para o Supabase
      final String ticket = await issueService.createIssue(
        title: title,
        description: 'Created from session test',
        category: category,
        latitude: 41.545,
        longitude: -8.426,
      );

      // Atualiza a UI imediatamente (sem imagens)
      setState(() {
        sessionTests.insert(0, {
          'title': title,
          'category': category,
          'ticket': ticket,
        });
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Teste criado: $ticket')));
    } catch (e) {
      debugPrint('Error creating issue: $e');
    } finally {
      setState(() => isCreating = false);
    }
  }

  void goToScanner() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const RecyclingScannerPage()),
  );
  void sendEmail() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const EmailTestPage()),
  );
  void goToMap() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const MapPage()),
  );
  void createReport() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const SelectCategory()),
  );
  void goToFeed() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const FeedPage()),
  );

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: goToScanner,
            icon: const Icon(Icons.camera_alt),
          ),
          IconButton(onPressed: sendEmail, icon: const Icon(Icons.email)),
          IconButton(onPressed: goToMap, icon: const Icon(Icons.map)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // TEXTOS VERDES ORIGINAIS RECUPERADOS
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Database connected',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Storage available',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Map available',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Push notifications available',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          if (user != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Logged in as: ${user.email}',
                style: const TextStyle(fontSize: 12),
              ),
            ),

          const Divider(),
          const Text(
            'TESTES DA SESSÃO',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),

          // ÁREA LIMPA SEM IMAGENS, SÓ COM ÍCONE DE TESTE
          Expanded(
            child: sessionTests.isEmpty
                ? const Center(
                    child: Text('Nenhum teste efetuado nesta sessão.'),
                  )
                : ListView.builder(
                    itemCount: sessionTests.length,
                    itemBuilder: (context, index) {
                      final test = sessionTests[index];
                      return ListTile(
                        leading: const Icon(
                          Icons.science,
                          color: Colors.orange,
                        ), // Ícone em vez de foto nula
                        title: Text(test['title']),
                        subtitle: Text(
                          '${test['category']} - ${test['ticket']}',
                        ),
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: createReport,
              child: const Text('Create a Report'),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'feedBtn',
            onPressed: goToFeed,
            child: const Icon(Icons.dynamic_feed),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'testIssueBtn',
            onPressed: isCreating ? null : createTestIssue,
            child: isCreating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
