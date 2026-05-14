import 'package:app/pages/report_detail_page.dart';
import 'package:flutter/material.dart';
// Ajusta este import para o caminho correto do teu IssueService
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
    // Inicia a chamada à BD quando a página carrega
    _activityFuture = _issueService.fetchUserActivity();
  }

  // Função auxiliar para formatar a data
  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.day}/${date.month}/${date.year} às ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
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

  Widget _buildCommentCard(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    // Extrair os dados de forma segura com base na query do Supabase
    final profile = activity['profiles'] ?? {};
    final issue = activity['issues'] ?? {};

    // O ID da denúncia que precisamos para abrir os detalhes
    final issueId = issue['id'];
    //final bool isRead = activity['is_read'] ?? false;

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
      // Usamos o Material com cor transparente para que o InkWell funcione bem com o border radius
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            setState(() {
              activity['is_read'] = true;
            });
            if (issueId != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white, // Força o fundo branco aqui
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, scrollController) => ReportDetailSheet(
                    // Passamos o ID. A página vai carregar o resto sozinha.
                    report: ReportData(id: issueId, title: '', category: ''),
                    highlightCommentId: activity['id']?.toString(),
                  ),
                ),
              );
            }
          },

          // SUBSTITUI O TEU BLOCO "child: Padding(...)" POR ESTE:
          child: Stack(
            children: [
              // 1. O teu Padding original (NÃO MEXEMOS EM NADA AQUI DENTRO)
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

              // 2. A BOLINHA VERDE (ADICIONADA AQUI)
              // Ela aparece no canto, sem empurrar o resto do código
              if (!(activity['is_read'] ?? false)) // Só aparece se não foi lido
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00D159), // Verde dos teus botões
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
