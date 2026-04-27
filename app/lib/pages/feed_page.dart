import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../services/auth_service.dart';
import '../services/issue_service.dart';
import '../pages/report_detail_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final AuthService authService = AuthService();
  final IssueService issueService = IssueService();

  final ScrollController _scrollController = ScrollController();
  final List<ReportData> _reports = [];

  int _totalCount = 0;
  int _currentPage = 0;
  bool _isLoading = false;
  bool _isFetching = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchTotalCount();
    _loadMore();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _fetchTotalCount() async {
    final int count = await issueService.fetchIssuesCount();
    if (!mounted) return;

    setState(() {
      _totalCount = count;
    });
  }

  Future<void> _loadMore() async {
    if (_isFetching || !_hasMore) return;

    _isFetching = true;
    setState(() => _isLoading = true);

    final newData = await issueService.fetchIssues(page: _currentPage);
    final List<ReportData> newReports = newData
        .map((item) => ReportData.fromMap(item))
        .toList();

    if (!mounted) return;

    setState(() {
      _reports.addAll(newReports);
      _currentPage++;
      _hasMore = newReports.length == IssueService.pageSize;
      _isLoading = false;
    });

    _isFetching = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();
    final String userName =
        user?.userMetadata?['first_name']?.toString() ??
        user?.email?.split('@').first ??
        'Utilizador';

    return Scaffold(
      backgroundColor: const Color(0xFFCDE5CB),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          Navigator.pushNamed(context, '/categories');
        },
        backgroundColor: const Color(0xFF00D159),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(userName),
            const SizedBox(height: 20),
            _buildSearchAndFilter(),
            const SizedBox(height: 26),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(),
                      const SizedBox(height: 20),
                      if (_reports.isEmpty && _isLoading)
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00D159),
                            ),
                          ),
                        )
                      else if (_reports.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text('Nenhuma denúncia encontrada.'),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: _reports.length + (_hasMore ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              if (index == _reports.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF00D159),
                                    ),
                                  ),
                                );
                              }

                              return _buildReportCard(_reports[index]);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 28, color: Color(0xFFB0B0B0)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withValues(alpha: 0.55),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Viste algum problema\nna cidade?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, color: Color(0xFF98A2B3)),
                  SizedBox(width: 10),
                  Text(
                    'Buscar denúncias...',
                    style: TextStyle(fontSize: 16, color: Color(0xFF98A2B3)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.tune, color: Color(0xFF98A2B3)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Denúncias prioritárias',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$_totalCount denúncias ativas',
              style: const TextStyle(fontSize: 14, color: Color(0xFF98A2B3)),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD0D5DD)),
          ),
          child: const Icon(Icons.swap_vert, color: Color(0xFF667085)),
        ),
      ],
    );
  }

  Widget _buildReportCard(ReportData report) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Detalhes da denúncia',
          barrierColor: Colors.black.withValues(alpha: 0.12),
          transitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, animation, secondaryAnimation) {
            final Size size = MediaQuery.of(context).size;
            final double dialogWidth = size.width > 700 ? 640 : size.width - 24;
            final double dialogHeight = size.height * 0.88;

            return SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: dialogWidth,
                      height: dialogHeight,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: ReportDetailSheet(report: report),
                    ),
                  ),
                ),
              ),
            );
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEAEA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportImage(report),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF475467),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF667085),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.address ?? 'Localização registada',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      VoteWidget(
                        issueId: report.id,
                        issueService: issueService,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Color(0xFF667085),
                      ),
                      const SizedBox(width: 6),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: issueService.fetchComments(report.id),
                        builder: (context, snapshot) {
                          final count = snapshot.hasData
                              ? snapshot.data!.length
                              : 0;
                          return Text(
                            count.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF344054),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportImage(ReportData report) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(
        height: 170,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: report.photos.isNotEmpty
                  ? Image.network(
                      report.photos.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder(
                          icon: Icons.broken_image_outlined,
                          message: 'Erro ao carregar imagem',
                        );
                      },
                    )
                  : _buildImagePlaceholder(
                      icon: Icons.image_not_supported_outlined,
                      message: 'Sem imagem disponível',
                    ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Pendente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEC6A00),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({required IconData icon, String? message}) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: const Color(0xFF98A2B3)),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
            ),
          ],
        ],
      ),
    );
  }
}

class VoteWidget extends StatefulWidget {
  final String issueId;
  final IssueService issueService;

  const VoteWidget({
    super.key,
    required this.issueId,
    required this.issueService,
  });

  @override
  State<VoteWidget> createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  int _score = 0;
  int _userVote = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVotes();
  }

  Future<void> _loadVotes() async {
    final voteInfo = await widget.issueService.fetchVoteInfo(widget.issueId);
    if (mounted) {
      setState(() {
        _score = voteInfo['score'];
        _userVote = voteInfo['userVote'];
        _isLoading = false;
      });
    }
  }

  Future<void> _handleVote(int voteType) async {
    final int previousScore = _score;
    final int previousUserVote = _userVote;

    setState(() {
      if (_userVote == voteType) {
        _score -= voteType;
        _userVote = 0;
      } else {
        if (_userVote != 0) {
          _score -= _userVote;
        }
        _score += voteType;
        _userVote = voteType;
      }
    });

    try {
      await widget.issueService.castVote(widget.issueId, voteType);
    } catch (e) {
      if (mounted) {
        setState(() {
          _score = previousScore;
          _userVote = previousUserVote;
        });
      }
      debugPrint('Falha ao votar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 60,
        height: 24,
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF00D159),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        GestureDetector(
          key: Key('upvote_${widget.issueId}'),
          onTap: () => _handleVote(1),
          child: Icon(
            Icons.arrow_upward,
            size: 22,
            color: _userVote == 1
                ? const Color(0xFF00D159)
                : const Color(0xFF667085),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          _score.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _userVote == 1
                ? const Color(0xFF00D159)
                : (_userVote == -1
                      ? const Color(0xFFEC6A00)
                      : const Color(0xFF344054)),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          key: Key('downvote_${widget.issueId}'),
          onTap: () => _handleVote(-1),
          child: Icon(
            Icons.arrow_downward,
            size: 22,
            color: _userVote == -1
                ? const Color(0xFFEC6A00)
                : const Color(0xFF667085),
          ),
        ),
      ],
    );
  }
}
