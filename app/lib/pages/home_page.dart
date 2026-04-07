import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/issue_service.dart';
import '../services/notification_service.dart';
import 'email_test_page.dart';
import 'recycling_scanner_page.dart';
import 'login_page.dart';
import 'map_page.dart';
import 'issue_category_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authService = AuthService();
  final issueService = IssueService();
  final notificationService = NotificationService();

  List<Map<String, dynamic>> issues = [];
  bool isLoading = true;
  String? errorMessage;
  bool isDatabaseConnected = false;

  @override
  void initState() {
    super.initState();
    loadIssues();
    notificationService.initialize();
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
      debugPrint('Error loading issues: $e');

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
      debugPrint('Error creating issue: $e');
    }
  }

  void goToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RecyclingScannerPage(),
      ),
    );
  }

  void sendEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmailTestPage(),
      ),
    );
  }

  void goToMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPage(),
      ),
    );
  }

  void createReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SelectCategory(),
      ),
    );
  }

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
          IconButton(
            onPressed: sendEmail,
            icon: const Icon(Icons.email),
          ),
          IconButton(
            onPressed: goToMap,
            icon: const Icon(Icons.map),
          ),
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
                            final String? photoUrl = issue['photo_url'] as String?;

                            return ListTile(
                              leading: photoUrl != null && photoUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        photoUrl,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.broken_image);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.location_on),
                              title: Text(issue['title'] ?? 'No title'),
                              subtitle: Text(issue['category'] ?? 'No category'),
                            );
                          },
                        )
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
      floatingActionButton: FloatingActionButton(
        onPressed: createTestIssue,
        child: const Icon(Icons.add),
      ),
    );
  }
}