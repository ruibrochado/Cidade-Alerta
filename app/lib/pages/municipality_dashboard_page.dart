import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'signin_page.dart';

class MunicipalityDashboardPage extends StatefulWidget {
  final bool showLoginConfirmation;

  const MunicipalityDashboardPage({
    super.key,
    this.showLoginConfirmation = false,
  });

  @override
  State<MunicipalityDashboardPage> createState() =>
      _MunicipalityDashboardPageState();
}

class _MunicipalityDashboardPageState extends State<MunicipalityDashboardPage> {
  final ProfileService profileService = ProfileService();
  final AuthService authService = AuthService();

  UserProfile? profile;
  bool isLoading = true;
  String? errorMessage;
  bool hasShownConfirmation = false;

  @override
  void initState() {
    super.initState();
    loadAndValidateProfile();
  }

  Future<void> loadAndValidateProfile() async {
    try {
      final loadedProfile = await profileService.getCurrentUserProfile();

      if (!mounted) return;

      if (loadedProfile == null) {
        setState(() {
          errorMessage = 'Unable to load user profile.';
          isLoading = false;
        });
        return;
      }

      if (!loadedProfile.isMunicipalityWorker) {
        setState(() {
          errorMessage = 'You do not have permission to access this page.';
          isLoading = false;
        });
        return;
      }

      if (!loadedProfile.hasAssignedMunicipality) {
        setState(() {
          errorMessage = 'No municipality is assigned to this account.';
          isLoading = false;
        });
        return;
      }

      setState(() {
        profile = loadedProfile;
        isLoading = false;
      });

      if (widget.showLoginConfirmation && !hasShownConfirmation) {
        hasShownConfirmation = true;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Municipality dashboard loaded')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Error loading municipality dashboard.';
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await authService.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Access denied')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      );
    }

    final municipalityLabel =
        profile?.municipalityName ??
        profile?.municipalityCity ??
        'Assigned Municipality';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Municipality Dashboard'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFCDE5CB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Managing reports for $municipalityLabel',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Municipality reports feed will be added in the next issue.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
