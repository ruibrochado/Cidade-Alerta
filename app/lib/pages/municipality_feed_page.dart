import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../services/issue_service.dart';
import '../widgets/slide_card.dart';
import 'report_detail_page.dart';
import '../widgets/navbar.dart';
import '../widgets/choice.dart';
import '../widgets/options_dialog.dart';
import '../widgets/success_banner.dart';
import 'municipality_statistics_page.dart';

class MunicipalityIssueFeedPage extends StatefulWidget {
  final String workerName;
  final String municipalityLabel;
  final String municipalityCity;
  final VoidCallback onLogout;

  const MunicipalityIssueFeedPage({
    super.key,
    required this.workerName,
    required this.municipalityLabel,
    required this.municipalityCity,
    required this.onLogout,
  });

  @override
  State<MunicipalityIssueFeedPage> createState() =>
      _MunicipalityIssueFeedPageState();
}

class _MunicipalityIssueFeedPageState extends State<MunicipalityIssueFeedPage> {
  String? _bannerMessage;
  bool _bannerIsError = false;

  void _showCustomBanner(String message, {bool isError = false}) {
    setState(() {
      _bannerMessage = message;
      _bannerIsError = isError;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _bannerMessage = null;
      });
    });
  }

  final IssueService issueService = IssueService();
  final ScrollController _scrollController = ScrollController();
  final List<ReportData> _reports = [];

  int _totalCount = 0;
  int _currentPage = 0;
  int _selectedTabIndex = 0;

  bool _isLoading = true;
  bool _isFetching = false;
  bool _hasMore = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTotalCount();
    _loadMoreReports();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreReports();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTotalCount() async {
    try {
      final count = await issueService.fetchMunicipalityReportsCount(
        municipalityCity: widget.municipalityCity,
      );

      if (!mounted) return;

      setState(() {
        _totalCount = count;
      });
    } catch (error) {
      debugPrint('Error fetching municipality reports count: $error');
    }
  }

  Future<void> _loadMoreReports() async {
    if (_isFetching || !_hasMore) return;

    setState(() {
      _isFetching = true;
      if (_reports.isEmpty) {
        _isLoading = true;
      }
    });

    try {
      final data = await issueService.fetchMunicipalityReports(
        page: _currentPage,
        municipalityCity: widget.municipalityCity,
      );

      final newReports = data.map((item) => ReportData.fromMap(item)).toList();

      if (!mounted) return;

      setState(() {
        _reports.addAll(newReports);
        _currentPage++;
        _hasMore = newReports.length == IssueService.pageSize;
        _isLoading = false;
        _isFetching = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Erro ao carregar denúncias municipais.';
        _isLoading = false;
        _isFetching = false;
      });
    }
  }

  Future<void> _refreshReports() async {
    setState(() {
      _reports.clear();
      _currentPage = 0;
      _hasMore = true;
      _isFetching = false;
      _isLoading = true;
      _errorMessage = null;
    });

    await _fetchTotalCount();
    await _loadMoreReports();
  }

  String _formatStatus(String status) {
    final normalizedStatus = status.trim().toLowerCase();

    switch (normalizedStatus) {
      case 'submitted':
      case 'pending':
      case 'pendente':
        return 'Pendente';
      case 'in_progress':
      case 'em progresso':
      case 'em resolução':
      case 'em resolucao':
        return 'Em resolução';
      case 'resolved':
      case 'resolvido':
        return 'Resolvido';
      case 'archived':
      case 'arquivado':
        return 'Arquivado';
      default:
        return status.isEmpty ? 'Pendente' : status;
    }
  }

  Color _getStatusBackgroundColor(String status) {
    final normalizedStatus = status.trim().toLowerCase();

    switch (normalizedStatus) {
      case 'resolved':
      case 'resolvido':
        return const Color(0xFFEFF8F1);
      case 'in_progress':
      case 'em progresso':
      case 'em resolução':
      case 'em resolucao':
        return const Color(0xFFEAF2FF);
      case 'archived':
      case 'arquivado':
        return const Color(0xFFF2F4F7);
      case 'submitted':
      case 'pending':
      case 'pendente':
      default:
        return const Color(0xFFFFF3E8);
    }
  }

  Color _getStatusTextColor(String status) {
    final normalizedStatus = status.trim().toLowerCase();

    switch (normalizedStatus) {
      case 'resolved':
      case 'resolvido':
        return const Color(0xFF1A6B3A);
      case 'in_progress':
      case 'em progresso':
      case 'em resolução':
      case 'em resolucao':
        return const Color(0xFF2563EB);
      case 'archived':
      case 'arquivado':
        return const Color(0xFF667085);
      case 'submitted':
      case 'pending':
      case 'pendente':
      default:
        return const Color(0xFFEC6A00);
    }
  }

  void _openReportDetails(ReportData report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D5DD),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ReportDetailSheet(report: report),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditStatusDialog(ReportData report) async {
    String currentStatus = report.status.trim().toLowerCase();
    if (currentStatus == 'pending' || currentStatus == 'pendente') {
      currentStatus = 'submitted';
    } else if (currentStatus == 'em progresso' ||
        currentStatus == 'em resolução' ||
        currentStatus == 'em resolucao') {
      currentStatus = 'in_progress';
    } else if (currentStatus == 'resolvido') {
      currentStatus = 'resolved';
    }

    final selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) {
        return OptionsDialogWidget(
          title: 'Editar estado',
          subtitle: 'Escolhe o novo estado para esta denúncia:',
          initialSelectedId: currentStatus,
          primaryButtonText: 'Confirmar',
          secondaryButtonText: 'Cancelar',
          options: const [
            OptionItem(
              id: 'submitted',
              label: 'Pendente',
              icon: Icons.schedule_outlined,
            ),
            OptionItem(
              id: 'in_progress',
              label: 'Em resolução',
              icon: Icons.engineering_outlined,
            ),
            OptionItem(
              id: 'resolved',
              label: 'Resolvido',
              icon: Icons.check_circle_outline,
            ),
          ],
          onCancel: () => Navigator.pop(context),
          onConfirm: (status) => Navigator.pop(context, status),
        );
      },
    );

    if (selectedStatus == null) return;

    try {
      final updatedStatus = await issueService.updateIssueStatus(
        issueId: report.id,
        status: selectedStatus,
      );

      if (!mounted) return;

      setState(() {
        final index = _reports.indexWhere((item) => item.id == report.id);

        if (index != -1) {
          _reports[index] = _reports[index].copyWith(status: updatedStatus);
        }
      });

      _showCustomBanner('Estado atualizado com sucesso.');
    } catch (error) {
      if (!mounted) return;

      _showCustomBanner('Erro ao atualizar o estado.', isError: true);
    }
  }

  bool _isResolved(String status) {
    final s = status.trim().toLowerCase();
    return s == 'resolved' || s == 'resolvido';
  }

  Future<void> _confirmArchiveIssue(ReportData report) async {
    if (!_isResolved(report.status)) {
      _showCustomBanner(
        'Apenas denúncias resolvidas podem ser arquivadas.',
        isError: true,
      );
      return;
    }

    final shouldArchive = await showDialog<bool>(
      context: context,
      builder: (context) {
        return ChoiceWidget(
          title: 'Arquivar denúncia',
          emoji: '🗂️',
          message:
              'Tens a certeza que queres arquivar esta denúncia? Ela deixará de aparecer no feed municipal, mas continuará guardada na base de dados.',
          secondaryButtonText: 'Cancelar',
          primaryButtonText: 'Arquivar',
          onSecondaryPressed: () => Navigator.pop(context, false),
          onPrimaryPressed: () => Navigator.pop(context, true),
        );
      },
    );

    if (shouldArchive != true) return;

    try {
      await issueService.archiveIssue(report.id);

      if (!mounted) return;

      setState(() {
        _reports.removeWhere((item) => item.id == report.id);
        _totalCount = _totalCount > 0 ? _totalCount - 1 : 0;
      });

      _showCustomBanner('Denúncia arquivada com sucesso.');
    } catch (error) {
      if (!mounted) return;

      _showCustomBanner('Erro ao arquivar denúncia.', isError: true);
    }
  }

  Widget _buildReportCard(ReportData report) {
    return SlideCard(
      isActive: false,
      onTap: () => _openReportDetails(report),
      borderRadius: 20,
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
                    report.title.isEmpty ? 'Denúncia sem título' : report.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.description.isEmpty
                        ? 'Sem descrição disponível.'
                        : report.description,
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
                          report.address ??
                              report.city ??
                              'Localização registada',
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 18,
                        color: Color(0xFF344054),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.score.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF344054),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'score',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF667085),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Color(0xFF344054),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF344054),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditStatusDialog(report),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Editar estado'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF1A6B3A),
                            side: const BorderSide(color: Color(0xFF98D6AC)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () => _confirmArchiveIssue(report),
                        icon: const Icon(Icons.archive_outlined),
                        color: const Color(0xFF667085),
                        tooltip: 'Arquivar denúncia',
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
              child: _buildStatusBadge(report.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusBackgroundColor(status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusTextColor(status),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({
    required IconData icon,
    required String message,
  }) {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: const Color(0xFF98A2B3)),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: Color(0xFF98A2B3)),
            SizedBox(height: 14),
            Text(
              'Nenhuma denúncia disponível.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF344054),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'As denúncias municipais aparecerão aqui quando estiverem disponíveis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFF667085),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFEC6A00)),
            const SizedBox(height: 14),
            Text(
              _errorMessage ?? 'Erro inesperado.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshReports,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent() {
    if (_isLoading && _reports.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF16A34A)),
      );
    }

    if (_errorMessage != null && _reports.isEmpty) {
      return _buildErrorState();
    }

    if (_reports.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshReports,
      color: const Color(0xFF16A34A),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        itemCount: _reports.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          if (index == _reports.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF16A34A)),
              ),
            );
          }

          return _buildReportCard(_reports[index]);
        },
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      bottomNavigationBar: MunicipalityBottomNavBar(
        currentIndex: _selectedTabIndex,
        onTabSelected: _handleBottomNavigation,
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFFCDE5CB),
                  padding: const EdgeInsets.fromLTRB(24, 22, 18, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Câmara Municipal',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedTabIndex == 1
                                  ? 'Estatísticas das denúncias'
                                  : 'Denúncias da comunidade',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF475467),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${widget.workerName} · ${widget.municipalityLabel}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF667085),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onLogout,
                        icon: const Icon(Icons.logout),
                        color: const Color(0xFF0F172A),
                        tooltip: 'Logout',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedTabIndex == 0)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                            child: Text(
                              '$_totalCount denúncias disponíveis',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF667085),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        Expanded(
                          child: _selectedTabIndex == 1
                              ? MunicipalityStatisticsPage(
                                  municipalityCity: widget.municipalityCity,
                                  municipalityLabel: widget.municipalityLabel,
                                )
                              : _buildFeedContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_bannerMessage != null)
            SuccessBanner(
              message: _bannerMessage!,
              icon: _bannerIsError ? Icons.error_outline : Icons.check_circle,
              backgroundColor: _bannerIsError
                  ? const Color(0xFFDC2626)
                  : const Color(0xFF16A34A),
            ),
        ],
      ),
    );
  }
}
