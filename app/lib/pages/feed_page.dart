import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/issue_service.dart';
import '../models/report_data.dart';
import '../pages/report_detail_page.dart'; // <-- AJUSTA O CAMINHO SE NECESSÁRIO (ex: '../pages/report_detail_page.dart')

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final authService = AuthService();
  final issueService = IssueService();

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
    final count = await issueService
        .fetchIssuesCount(); // Garante que este método existe no teu IssueService
    if (mounted) {
      setState(() => _totalCount = count);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isFetching || !_hasMore) return;
    _isFetching = true;
    setState(() => _isLoading = true);

    // Assumindo que criaste a variável estática pageSize no IssueService
    final newData = await issueService.fetchIssues(page: _currentPage);
    final newReports = newData.map((m) => ReportData.fromMap(m)).toList();

    if (mounted) {
      setState(() {
        _reports.addAll(newReports);
        _currentPage++;
        // Se a quantidade de itens devolvidos for menor que o limite, não há mais
        _hasMore =
            newReports.length ==
            10; // Usando 10 em vez de IssueService.pageSize para garantir que não dá erro se não o criaste
        _isLoading = false;
      });
    }
    _isFetching = false;
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();
    final userEmail = user?.email ?? 'Utilizador';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Olá,',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Viste algum problema\nna cidade?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: 0,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 25),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Denúncias recentes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Text(
                            'Ver todas',
                            style: TextStyle(
                              color: Color(0xFF00D159),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$_totalCount denúncias ativas',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
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
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: _reports.length + (_hasMore ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 20),
                            itemBuilder: (context, index) {
                              if (index == _reports.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF00D159),
                                    ),
                                  ),
                                );
                              }
                              return _buildCard(_reports[index]);
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: const [
                  SizedBox(width: 15),
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    'Buscar denúncias...',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.tune, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder({required IconData icon, String? message}) {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.grey[400]),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(ReportData report) {
    // AQUI ESTÁ A GRANDE MUDANÇA: GestureDetector à volta do cartão!
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailPage(report: report),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: report.photos.isNotEmpty
                  ? Image.network(
                      report.photos.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(
                            icon: Icons.broken_image,
                            message: 'Erro ao carregar imagem',
                          ),
                    )
                  : _buildImagePlaceholder(
                      icon: Icons.image_not_supported,
                      message: 'Sem imagem disponível',
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    report.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF00D159),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.address ?? 'Localização registada',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.arrow_upward,
                            size: 20,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '0',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_downward,
                            size: 20,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 5),
                          Text(
                            '0', // No futuro podes ligar este zero ao número real de comentários!
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
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
}
