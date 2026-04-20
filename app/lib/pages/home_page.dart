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

  // Lista começa VAZIA para a página estar sempre limpa ao entrar
  List<Map<String, dynamic>> sessionTests = [];
  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    // REMOVIDO: loadIssues() - Não carregamos nada da BD ao iniciar
    notificationService.initialize();
  }

  Future<void> logout() async {
    await authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // Função para criar o teste e adicionar LOGO à lista visível
  Future<void> createTestIssue() async {
    setState(() => isCreating = true);

    try {
      final String title = 'Test issue';
      final String category = 'road';

      // Cria na base de dados (para testar o fluxo do backend)
      final String ticket = await issueService.createIssue(
        title: title,
        description: 'Created from session test',
        category: category,
        latitude: 41.545,
        longitude: -8.426,
      );

      // Em vez de fazer fetch da BD, adicionamos manualmente à lista da sessão
      setState(() {
        sessionTests.insert(0, {
          'title': title,
          'category': category,
          'ticket': ticket,
          'time': DateTime.now().toString().substring(11, 16), // Só a hora
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teste criado com sucesso! Ticket: $ticket')),
      );
    } catch (e) {
      debugPrint('Error creating issue: $e');
    } finally {
      setState(() => isCreating = false);
    }
  }

  // --- NAVEGAÇÃO ---
  void goToScanner() => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecyclingScannerPage()));
  void sendEmail() => Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailTestPage()));
  void goToMap() => Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
  void createReport() => Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectCategory()));
  void goToFeed() => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedPage()));

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Testes'),
        actions: [
          IconButton(onPressed: goToScanner, icon: const Icon(Icons.camera_alt)),
          IconButton(onPressed: sendEmail, icon: const Icon(Icons.email)),
          IconButton(onPressed: goToMap, icon: const Icon(Icons.map)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // Indicadores de Status
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                _buildStatusRow('Base de Dados', Icons.check_circle, Colors.green),
                _buildStatusRow('Storage (Imagens)', Icons.cloud_done, Colors.blue),
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Sessão: ${user.email}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'TESTES DA SESSÃO ATUAL',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
            ),
          ),

          Expanded(
            child: sessionTests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text('Nenhum teste efetuado nesta sessão.', style: TextStyle(color: Colors.grey)),
                  const Text('Clique no + para começar.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: sessionTests.length,
              itemBuilder: (context, index) {
                final test = sessionTests[index];
                return ListTile(
                  // SEM IMAGENS, apenas ícone de lab
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.science, color: Colors.white),
                  ),
                  title: Text(test['title']),
                  subtitle: Text('Categoria: ${test['category']} • ID: ${test['ticket']}'),
                  trailing: Text(test['time'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: createReport,
              icon: const Icon(Icons.assignment),
              label: const Text('Ir para Report Real'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
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
            backgroundColor: const Color(0xFF00D159),
            child: const Icon(Icons.dynamic_feed, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'testIssueBtn',
            onPressed: isCreating ? null : createTestIssue,
            backgroundColor: Colors.orange,
            child: isCreating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}