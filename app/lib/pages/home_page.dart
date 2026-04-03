import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/issue_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final issueService = IssueService();

  List<Map<String, dynamic>> issues = [];
  bool isLoading = true;
  String? errorMessage;
  bool isDatabaseConnected = false;

  bool isStorageLoading = true;
  bool isStorageConnected = false;

  @override
  void initState() {
    super.initState();
    loadIssues();
    testStorageConnection();
  }

  Future<void> loadIssues() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      isDatabaseConnected = false;
    });

    try {
      final data = await issueService.fetchIssues();

      if (!mounted) return;
      setState(() {
        issues = data;
        isDatabaseConnected = true;
      });
    } catch (e) {
      print('Error loading issues: $e');

      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load issues';
        isDatabaseConnected = false;
      });
    }

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> testStorageConnection() async {
    setState(() {
      isStorageLoading = true;
      isStorageConnected = false;
    });

    try {
      final supabase = Supabase.instance.client;

      await supabase.storage.from('issue-images').list();

      if (!mounted) return;
      setState(() {
        isStorageConnected = true;
      });
    } catch (e) {
      print('Storage error: $e');

      if (!mounted) return;
      setState(() {
        isStorageConnected = false;
      });
    }

    if (!mounted) return;
    setState(() {
      isStorageLoading = false;
    });
  }

  Future<void> logout() async {
    await authService.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> createTestIssue() async {
    try {
      await issueService.createIssue(
        title: 'Test issue',
        description: 'Created from app',
        category: 'road',
        latitude: 41.545,
        longitude: -8.426,
      );

      loadIssues();
    } catch (e) {
      print('Error creating issue: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              isLoading
                  ? 'Checking database connection...'
                  : isDatabaseConnected
                      ? 'Database connected'
                      : 'Database connection failed',
              style: TextStyle(
                color: isLoading
                    ? Colors.orange
                    : isDatabaseConnected
                        ? Colors.green
                        : Colors.red,
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

          if (user != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Logged in as: ${user.email}',
                style: const TextStyle(fontSize: 12),
              ),
            ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: loadIssues,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : issues.isEmpty
                        ? const Center(child: Text('No issues found'))
                        : ListView.builder(
                            itemCount: issues.length,
                            itemBuilder: (context, index) {
                              final issue = issues[index];

                              return ListTile(
                                leading: const Icon(Icons.location_on),
                                title: Text(issue['title'] ?? 'No title'),
                                subtitle:
                                    Text(issue['category'] ?? 'No category'),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createTestIssue,
        child: const Icon(Icons.add),
      ),
    );
  }
}