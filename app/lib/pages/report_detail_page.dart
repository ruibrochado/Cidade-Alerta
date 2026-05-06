import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_data.dart';
import '../services/issue_service.dart';

class ReportDetailSheet extends StatefulWidget {
  final ReportData report;

  const ReportDetailSheet({super.key, required this.report});

  @override
  State<ReportDetailSheet> createState() => _ReportDetailSheetState();
}

class _ReportDetailSheetState extends State<ReportDetailSheet> {
  final IssueService _issueService = IssueService();
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  String? _currentUserPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserPhoto();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserPhoto() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select('profile_photo')
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        _currentUserPhotoUrl = profile?['profile_photo']?.toString();
      });
    } catch (e) {
      debugPrint('Error loading current user photo: $e');
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _issueService.fetchComments(widget.report.id);

      if (!mounted) return;

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading comments: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final String text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUser = Supabase.instance.client.auth.currentUser;
    final String? currentUserId = currentUser?.id;

    setState(() {
      _isSending = true;
      _comments.add({
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
        'user_id': currentUserId,
        'profiles': {
          'first_name': 'Tu',
          'last_name': '',
          'profile_photo': _currentUserPhotoUrl,
        },
      });
    });

    _commentController.clear();

    try {
      await _issueService.addComment(widget.report.id, text);
    } catch (e) {
      debugPrint('Error posting comment: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar o comentário. Tenta novamente.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _getUserName(Map<String, dynamic> comment) {
    final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final String? commentUserId = comment['user_id']?.toString();

    if (currentUserId != null && currentUserId == commentUserId) {
      return 'Tu';
    }

    final profile = comment['profiles'];
    final String firstName = profile?['first_name']?.toString() ?? '';
    final String lastName = profile?['last_name']?.toString() ?? '';
    final String fullName = '$firstName $lastName'.trim();

    return fullName.isEmpty ? 'Utilizador' : fullName;
  }

  String _formatRelativeTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';

    try {
      final DateTime created = DateTime.parse(createdAt).toLocal();
      final Duration diff = DateTime.now().difference(created);

      if (diff.inMinutes < 1) return 'Agora';
      if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}m';
      if (diff.inHours < 24) return 'Há ${diff.inHours}h';
      if (diff.inDays < 7) return 'Há ${diff.inDays}d';

      return '${created.day.toString().padLeft(2, '0')}/${created.month.toString().padLeft(2, '0')}/${created.year}';
    } catch (_) {
      return '';
    }
  }

  ImageProvider? _getCommentAvatar(Map<String, dynamic> comment) {
    final profile = comment['profiles'];
    final String? avatarUrl =
        profile?['profile_photo']?.toString() ??
        profile?['avatar_url']?.toString();

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return NetworkImage(avatarUrl);
    }

    return null;
  }

  Widget _buildAvatar({ImageProvider? image}) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: image,
      child: image == null
          ? const Icon(Icons.person, size: 18, color: Color(0xFF98A2B3))
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          _buildTopBar(context),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                _buildReportImage(),
                const SizedBox(height: 18),
                _buildTitleAndStatus(),
                const SizedBox(height: 10),
                _buildDescription(),
                const SizedBox(height: 12),
                _buildLocation(),
                const SizedBox(height: 22),
                const Text(
                  'Comentários',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 16),
                _buildCommentsSection(),
              ],
            ),
          ),
          _buildCommentInputBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Detalhes da Denúncia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildReportImage() {
    if (widget.report.photos.isEmpty) {
      return Container(
        height: 185,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 42,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        widget.report.photos.first,
        width: double.infinity,
        height: 185,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 185,
            color: const Color(0xFFE5E7EB),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 42,
                color: Color(0xFF9CA3AF),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleAndStatus() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.report.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBD8),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Pendente',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEC6A00),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.report.description,
      style: const TextStyle(
        fontSize: 16,
        height: 1.45,
        color: Color(0xFF475467),
      ),
    );
  }

  Widget _buildLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.location_on_outlined,
            size: 18,
            color: Color(0xFF667085),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            widget.report.address ?? 'Localização registada',
            style: const TextStyle(fontSize: 15, color: Color(0xFF667085)),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00D159)),
        ),
      );
    }

    if (_comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Ainda sem comentários. Sê o primeiro!',
          style: TextStyle(fontSize: 15, color: Color(0xFF98A2B3)),
        ),
      );
    }

    return Column(
      children: _comments.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map<String, dynamic> comment = entry.value;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _comments.length - 1 ? 0 : 18,
          ),
          child: _buildCommentItem(comment),
        );
      }).toList(),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final String userName = _getUserName(comment);
    final String relativeTime = _formatRelativeTime(comment['created_at']);
    final ImageProvider? avatar = _getCommentAvatar(comment);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(image: avatar),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (relativeTime.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          relativeTime,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF98A2B3),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment['content']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: Color(0xFF344054),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInputBar() {
    final ImageProvider? currentUserAvatar =
        _currentUserPhotoUrl != null && _currentUserPhotoUrl!.isNotEmpty
        ? NetworkImage(_currentUserPhotoUrl!)
        : null;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          _buildAvatar(image: currentUserAvatar),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: TextField(
                controller: _commentController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _submitComment(),
                decoration: const InputDecoration(
                  hintText: 'Adicionar comentário...',
                  hintStyle: TextStyle(color: Color(0xFF98A2B3), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF00D159),
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
