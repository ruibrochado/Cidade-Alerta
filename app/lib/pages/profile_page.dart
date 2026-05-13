import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  bool _isDeleting = false;

  String _name = 'Utilizador';
  String _email = 'sem email';
  String? _profilePhotoUrl;

  int _reportedIssuesCount = 0;
  int _votedIssuesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final reportedIssues = await _supabase
          .from('issues')
          .select('id')
          .eq('user_id', user.id);

      final votedIssues = await _supabase
          .from('issue_votes')
          .select('id')
          .eq('user_id', user.id);

      final profile = await _supabase
          .from('profiles')
          .select('first_name, last_name, profile_photo')
          .eq('id', user.id)
          .maybeSingle();

      final firstName = profile?['first_name']?.toString() ?? '';
      final lastName = profile?['last_name']?.toString() ?? '';
      final fullName = '$firstName $lastName'.trim();

      if (!mounted) return;

      setState(() {
        _name = fullName.isEmpty ? 'Utilizador' : fullName;
        _email = user.email ?? 'sem email';
        _profilePhotoUrl = profile?['profile_photo']?.toString();
        _isLoading = false;
        _reportedIssuesCount = reportedIssues.length;
        _votedIssuesCount = votedIssues.length;
      });
    } catch (error) {
      debugPrint('LOAD PROFILE ERROR: $error');

      if (!mounted) return;

      setState(() {
        _email = _supabase.auth.currentUser?.email ?? 'sem email';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _goToEditProfile() async {
    await Navigator.pushNamed(context, '/edit-profile');

    if (!mounted) return;

    setState(() => _isLoading = true);
    await _loadProfile();
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar conta?'),
          content: const Text(
            'Esta ação é permanente. A tua conta e os dados associados serão eliminados.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    setState(() => _isDeleting = true);

    try {
      await _supabase.functions.invoke('delete-user');

      await _supabase.auth.signOut();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao eliminar conta: $error')));
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  ImageProvider? _getProfileImage() {
    if (_profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty) {
      return NetworkImage(_profilePhotoUrl!);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profileImage = _getProfileImage();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFCDE5CB),
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          color: const Color(0xFF0F172A),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              backgroundImage: profileImage,
                              child: profileImage == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 44,
                                      color: Color(0xFF98A2B3),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF475467),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: _StatsCard(
                                value: _reportedIssuesCount.toString(),
                                label: 'Denúncias reportadas',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatsCard(
                                value: _votedIssuesCount.toString(),
                                label: 'Denúncias votadas',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                      child: ListView(
                        children: [
                          const _SectionTitle('GERAL'),
                          _ProfileMenuItem(
                            icon: Icons.person_outline,
                            title: 'Editar perfil',
                            onTap: _goToEditProfile,
                          ),
                          _ProfileMenuItem(
                            icon: Icons.language,
                            title: 'Idioma',
                            trailingText: 'Português',
                            onTap: () {},
                          ),
                          _ProfileMenuItem(
                            icon: Icons.star_border,
                            title: 'Avalia-nos',
                            onTap: () {},
                          ),
                          _ProfileMenuItem(
                            icon: Icons.shield_outlined,
                            title: 'Privacidade e Termos',
                            onTap: () {
                              Navigator.pushNamed(context, '/privacy-terms');
                            },
                          ),
                          _ProfileMenuItem(
                            icon: Icons.chat_bubble_outline,
                            title: 'Feedback',
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle('CONTA'),
                          _ProfileMenuItem(
                            icon: Icons.delete_outline,
                            title: _isDeleting
                                ? 'A eliminar conta...'
                                : 'Eliminar conta',
                            onTap: _isDeleting ? () {} : _confirmDeleteAccount,
                          ),
                          _ProfileMenuItem(
                            icon: Icons.logout,
                            title: 'Terminar sessão',
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatsCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F3E4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475467)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF667085),
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleteAction = title.contains('Eliminar');

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDeleteAction ? Colors.red : const Color(0xFF00B84A),
                  size: 23,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: isDeleteAction
                          ? Colors.red
                          : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                if (trailingText != null) ...[
                  Text(
                    trailingText!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
      ],
    );
  }
}
