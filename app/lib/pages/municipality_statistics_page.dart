import 'package:flutter/material.dart';
import '../services/issue_service.dart';

class MunicipalityStatisticsPage extends StatefulWidget {
  final String municipalityCity;
  final String municipalityLabel;

  const MunicipalityStatisticsPage({
    super.key,
    required this.municipalityCity,
    required this.municipalityLabel,
  });

  @override
  State<MunicipalityStatisticsPage> createState() =>
      _MunicipalityStatisticsPageState();
}

class _MunicipalityStatisticsPageState
    extends State<MunicipalityStatisticsPage> {
  final IssueService issueService = IssueService();
  late Future<MunicipalityStatisticsData> _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _statisticsFuture = _fetchStatistics();
  }

  Future<MunicipalityStatisticsData> _fetchStatistics() {
    return issueService.fetchMunicipalityStatistics(
      municipalityCity: widget.municipalityCity,
    );
  }

  Future<void> _refreshStatistics() async {
    setState(() {
      _statisticsFuture = _fetchStatistics();
    });

    await _statisticsFuture;
  }

  String _formatPercentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MunicipalityStatisticsData>(
      future: _statisticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF16A34A)),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final MunicipalityStatisticsData statistics = snapshot.data!;
        final String topCategory = statistics.categoryCounts.isEmpty
            ? 'Sem dados'
            : statistics.categoryCounts.entries.first.key;

        return RefreshIndicator(
          onRefresh: _refreshStatistics,
          color: const Color(0xFF16A34A),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
            children: [
              Text(
                'Estatísticas municipais',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.municipalityLabel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF667085),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final int crossAxisCount = constraints.maxWidth > 640 ? 3 : 2;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _buildStatCard(
                        title: 'Total',
                        value: statistics.totalReports.toString(),
                        icon: Icons.assignment_outlined,
                      ),
                      _buildStatCard(
                        title: 'Pendentes',
                        value: statistics.openReports.toString(),
                        icon: Icons.hourglass_empty_outlined,
                      ),
                      _buildStatCard(
                        title: 'Em resolução',
                        value: statistics.inProgressReports.toString(),
                        icon: Icons.engineering_outlined,
                      ),
                      _buildStatCard(
                        title: 'Resolvidas',
                        value: statistics.resolvedReports.toString(),
                        icon: Icons.check_circle_outline,
                      ),
                      _buildStatCard(
                        title: 'Arquivadas',
                        value: statistics.archivedReports.toString(),
                        icon: Icons.archive_outlined,
                      ),
                      _buildStatCard(
                        title: 'Este mês',
                        value: statistics.reportsThisMonth.toString(),
                        icon: Icons.calendar_month_outlined,
                      ),
                      _buildStatCard(
                        title: 'Taxa de resolução',
                        value: _formatPercentage(statistics.resolutionRate),
                        icon: Icons.trending_up_outlined,
                      ),
                      _buildStatCard(
                        title: 'Categoria principal',
                        value: topCategory,
                        icon: Icons.category_outlined,
                        isTextValue: true,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildDistributionCard(
                title: 'Denúncias por estado',
                data: statistics.statusCounts,
              ),
              const SizedBox(height: 16),
              _buildDistributionCard(
                title: 'Denúncias por categoria',
                data: statistics.categoryCounts,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    bool isTextValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1A6B3A), size: 21),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: isTextValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isTextValue ? 18 : 26,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              height: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCard({
    required String title,
    required Map<String, int> data,
  }) {
    final entries = data.entries.where((entry) => entry.value > 0).toList();
    final int maxCount = entries.isEmpty
        ? 0
        : entries.map((entry) => entry.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            const Text(
              'Ainda não existem dados suficientes.',
              style: TextStyle(fontSize: 14, color: Color(0xFF667085)),
            )
          else
            ...entries.map((entry) {
              final double progress = maxCount == 0
                  ? 0
                  : entry.value / maxCount;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF344054),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFEFF4EF),
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
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
            const Text(
              'Erro ao carregar estatísticas municipais.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF344054),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _statisticsFuture = _fetchStatistics();
                });
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
