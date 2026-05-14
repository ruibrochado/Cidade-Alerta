import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_data.dart';
import '../services/issue_service.dart';

class ReportDetailSheet extends StatefulWidget {
  final ReportData report;
  final String? highlightCommentId;

  const ReportDetailSheet({
    super.key,
    required this.report,
    this.highlightCommentId,
  });

  @override
  State<ReportDetailSheet> createState() => _ReportDetailSheetState();
}

class _ReportDetailSheetState extends State<ReportDetailSheet> {
  final IssueService _issueService = IssueService();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _activeHighlightId;

  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _activeHighlightId = widget.highlightCommentId;
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
        profile?['profile_photo']?.toString();
      });
    } catch (e) {
      debugPrint('Error loading current user photo: $e');
    }
  }

  Future<void> _loadComments() async {
    try {
      // 1. Vai buscar os comentários e os dados da denúncia
      final comments = await _issueService.fetchComments(widget.report.id);

      final issueData = await Supabase.instance.client
          .from('issues')
          .select('photo_url, address, description, title, category')
          .eq('id', widget.report.id)
          .single();

      if (!mounted) return;

      // 2. Atualiza a interface com os dados novos
      setState(() {
        _comments = comments;
        widget.report.address =
            issueData['address'] ?? 'Localização não disponível';
        widget.report.description = issueData['description'] ?? '';
        widget.report.title = issueData['title'] ?? widget.report.title;

        if (issueData['photo_url'] != null) {
          widget.report.photos = [issueData['photo_url']];
        }
        _isLoading = false;
      });

      // 3. Se viermos de uma notificação (tem ID para destacar)
      if (_activeHighlightId != null) {
        // A - Faz o Scroll automático após um pequeno delay para a lista carregar
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            final index = _comments.indexWhere(
              (c) => c['id'].toString() == _activeHighlightId,
            );
            if (index != -1) {
              // 400.0 é a altura estimada do cabeçalho (foto + descrição)
              double targetScroll = 400.0 + (index * 90.0);
              _scrollController.animateTo(
                targetScroll,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOutQuart,
              );
            }
          }
        });

        // B - Faz o destaque desaparecer sozinho após 5 segundos
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _activeHighlightId = null; // Remove a cor de destaque
            });
          }
        });
      } // <-- Aqui faltava fechar o IF
    } catch (e) {
      debugPrint('Erro ao carregar detalhes: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final String text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    //final currentUser = Supabase.instance.client.auth.currentUser;
    //final String? currentUserId = currentUser?.id;

    setState(() {
      _isSending = true;
    });

    try {
      await _issueService.addComment(widget.report.id, text);
      _commentController.clear();
      // Recarrega os comentários para mostrar o novo com o ID real da DB
      final updatedComments = await _issueService.fetchComments(
        widget.report.id,
      );
      if (mounted) {
        setState(() {
          _comments = updatedComments;
          _isSending = false;
        });
      }
    } catch (e) {
      debugPrint('Error posting comment: $e');
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar o comentário.')),
        );
      }
    }
  }

  // --- MÉTODOS DE UI ---

  void _openImageViewer(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: 'report_image_${widget.report.id}',
        ),
      ),
    );
  }

  String _getUserName(Map<String, dynamic> comment) {
    final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final String? commentUserId = comment['user_id']?.toString();

    if (currentUserId != null && currentUserId == commentUserId) return 'Tu';

    final profile = comment['profiles'];
    final String firstName = profile?['first_name']?.toString() ?? '';
    final String lastName = profile?['last_name']?.toString() ?? '';
    return '$firstName $lastName'.trim().isEmpty
        ? 'Utilizador'
        : '$firstName $lastName'.trim();
  }

  String _formatRelativeTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return '';
    try {
      final DateTime created = DateTime.parse(createdAt).toLocal();
      final Duration diff = DateTime.now().difference(created);
      if (diff.inMinutes < 1) return 'Agora';
      if (diff.inMinutes < 60) return 'Há ${diff.inMinutes}m';
      if (diff.inHours < 24) return 'Há ${diff.inHours}h';
      return '${created.day}/${created.month}/${created.year}';
    } catch (_) {
      return '';
    }
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
    return Material(
      // Adicionado Material para evitar o erro de TextField
      color: Colors.white,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              _buildTopBar(context),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00D159),
                        ),
                      )
                    : ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
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
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          _buildCommentsSection(),
                        ],
                      ),
              ),
              _buildCommentInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Detalhes da Denúncia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
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
    return GestureDetector(
      onTap: () => _openImageViewer(widget.report.photos.first),
      child: Hero(
        tag: 'report_image_${widget.report.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            widget.report.photos.first,
            height: 185,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndStatus() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.report.title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBD8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Pendente',
            style: TextStyle(
              color: Color(0xFFEC6A00),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() => Text(
    widget.report.description,
    style: const TextStyle(fontSize: 16, color: Color(0xFF475467)),
  );

  Widget _buildLocation() {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: Color(0xFF667085),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.report.address ?? 'Localização não disponível',
            style: const TextStyle(color: Color(0xFF667085)),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    if (_comments.isEmpty) return const Text('Sem comentários ainda.');
    return Column(
      children: _comments.map((c) => _buildCommentItem(c)).toList(),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final bool isHighlighted = comment['id']?.toString() == _activeHighlightId;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0), // Margem consistente
      decoration: BoxDecoration(
        // Se estiver destacado, mostra o verde, senão fica transparente
        color: isHighlighted ? const Color(0xFFF0FDF4) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Mantemos uma borda sempre, mas transparente quando não destacado
          // para o texto não "mexer" 1px quando a borda sumir
          color: isHighlighted ? const Color(0xFFBBF7D0) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(
            image: comment['profiles']?['profile_photo'] != null
                ? NetworkImage(comment['profiles']?['profile_photo'])
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getUserName(comment),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      _formatRelativeTime(comment['created_at']),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['content'] ?? '',
                  style: const TextStyle(color: Color(0xFF4B5563), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Adicionar comentário...',
                filled: true,
                fillColor: const Color(0xFFF2F4F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _submitComment,
            icon: const Icon(Icons.send, color: Color(0xFF00D159)),
          ),
        ],
      ),
    );
  }
}

// Viewer de Imagem Full Screen
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  const _FullScreenImageViewer({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(child: Image.network(imageUrl)),
        ),
      ),
    );
  }
}
