import 'package:app/pages/report_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_data.dart';
import '../services/issue_service.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final IssueService _issueService = IssueService();
  late Future<List<Map<String, dynamic>>> _activityFuture;

  @override
  void initState() {
    super.initState();
    _activityFuture = _loadActivity();
  }

  // Carrega comentários + notificações de status e junta tudo por data
  Future<List<Map<String, dynamic>>> _loadActivity() async {
    final results = await Future.wait([
      _issueService.fetchUserActivity(),
      _fetchStatusNotifications(),
    ]);

    final comments = results[0].map((e) => {...e, '_type': 'comment'}).toList();

    final notifications = results[1]
        .map((e) => {...e, '_type': 'notification'})
        .toList();

    final all = [...comments, ...notifications]
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(0);
        final bDate = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

    return all;
  }

  Future<List<Map<String, dynamic>>> _fetchStatusNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await Supabase.instance.client
          .from('notifications')
          .select('id, created_at, issue_id, issue_title, new_status, is_read')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erro a buscar notificações: $e');
      return [];
    }
  }

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.day}/${date.month}/${date.year} às ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }

  void _openReportDetails(ReportData report, {String? highlightCommentId}) {
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
                    child: ReportDetailSheet(
                      report: report,
                      highlightCommentId: highlightCommentId,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 16.0),
            child: Text(
              'Atividade',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _activityFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar atividades.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                final activities = snapshot.data ?? [];

                if (activities.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    bottom: 100.0,
                  ),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    if (activity['_type'] == 'notification') {
                      return _buildNotificationCard(context, activity);
                    }
                    return _buildCommentCard(context, activity);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Card original de comentário — sem alterações
  Widget _buildCommentCard(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final profile = activity['profiles'] ?? {};
    final issue = activity['issues'] ?? {};

    final issueId = issue['id'];

    final firstName = profile['first_name'] ?? 'Utilizador';
    final lastName = profile['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final avatarUrl = profile['profile_photo'];

    final reportTitle = issue['title'] ?? 'Denúncia';
    final content = activity['content'] ?? '';
    final timeString = activity['created_at'] != null
        ? _formatDate(activity['created_at'])
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('activity_comment_card'),
          borderRadius: BorderRadius.circular(16.0),
          onTap: () async {
            setState(() {
              activity['is_read'] = true;
            });
            try {
              await Supabase.instance.client
                  .from('comments')
                  .update({'is_read': true})
                  .eq('id', activity['id']);
            } catch (e) {
              debugPrint('Erro ao marcar como lido: $e');
            }
            if (!mounted) return;
            if (issueId != null) {
              _openReportDetails(
                ReportData(id: issueId, title: '', category: ''),
                highlightCommentId: activity['id']?.toString(),
              );
            }
          },

          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: avatarUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(
                                  text: '$fullName ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'comentou na sua denúncia ',
                                ),
                                TextSpan(
                                  text: '"$reportTitle": ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"$content"',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeString,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!(activity['is_read'] ?? false))
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00D159),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    final issueId = activity['issue_id']?.toString();
    final issueTitle = activity['issue_title'] ?? 'Denúncia';
    final newStatus = activity['new_status'] ?? '';
    final timeString = activity['created_at'] != null
        ? _formatDate(activity['created_at'])
        : '';

    const statusLabels = {
      'submitted': 'Submetida',
      'in_progress': 'Em resolução',
      'resolved': 'Resolvida',
      'archived': 'Arquivada',
    };
    const statusColors = {
      'submitted': Color(0xFF6B7280),
      'in_progress': Color(0xFFF59E0B),
      'resolved': Color(0xFF16A34A),
      'archived': Color(0xFF9CA3AF),
    };
    const statusIcons = {
      'submitted': Icons.inbox_rounded,
      'in_progress': Icons.autorenew_rounded,
      'resolved': Icons.check_circle_rounded,
      'archived': Icons.archive_rounded,
    };

    final label = statusLabels[newStatus] ?? newStatus;
    final color = statusColors[newStatus] ?? const Color(0xFF6B7280);
    final icon = statusIcons[newStatus] ?? Icons.info_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () async {
            setState(() {
              activity['is_read'] = true;
            });
            try {
              await Supabase.instance.client
                  .from('notifications')
                  .update({'is_read': true})
                  .eq('id', activity['id']);
            } catch (e) {
              debugPrint('Erro ao marcar notificação como lida: $e');
            }
            if (!mounted || issueId == null) return;
            _openReportDetails(
              ReportData(id: issueId, title: '', category: ''),
            );
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'O estado da sua denúncia ',
                                ),
                                TextSpan(
                                  text: '"$issueTitle" ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: 'foi atualizado para '),
                                TextSpan(
                                  text: label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            timeString,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!(activity['is_read'] ?? false))
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00D159),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Sem atividades recentes.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
