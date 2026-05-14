import 'package:flutter/material.dart';

// ----------------------------------------------------------------------
// Modelos de Dados (Mocks) para simular as notificações
// Numa fase posterior, isto virá do teu backend/Firebase
// ----------------------------------------------------------------------
enum ActivityType { comment, statusUpdate }

class ActivityItem {
  final String id;
  final ActivityType type;
  final String? user;
  final String? avatarUrl;
  final String reportTitle;
  final String time;

  // Específico para status updates
  final String? entity;
  final String? oldStatus;
  final String? newStatus;
  final bool? isResolved;

  ActivityItem({
    required this.id,
    required this.type,
    required this.reportTitle,
    required this.time,
    this.user,
    this.avatarUrl,
    this.entity,
    this.oldStatus,
    this.newStatus,
    this.isResolved,
  });
}

// ----------------------------------------------------------------------
// Página Principal
// ----------------------------------------------------------------------
class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  // Simulação da lista de atividades recebida da API
  final List<ActivityItem> _activities = [
    ActivityItem(
      id: '1',
      type: ActivityType.comment,
      user: 'João Pedro',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      reportTitle: 'Buraco na via',
      time: 'Há 2 horas',
    ),
    ActivityItem(
      id: '2',
      type: ActivityType.statusUpdate,
      entity: 'Câmara Municipal do Porto',
      isResolved: false,
      reportTitle: 'Iluminação pública',
      oldStatus: 'Pendente',
      newStatus: 'Em Progresso',
      time: 'Há 5 horas',
    ),
    ActivityItem(
      id: '3',
      type: ActivityType.comment,
      user: 'Ana Costa',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      reportTitle: 'Buraco na via',
      time: 'Há 1 dia',
    ),
    ActivityItem(
      id: '4',
      type: ActivityType.statusUpdate,
      entity: 'Câmara Municipal do Porto',
      isResolved: true,
      reportTitle: 'Lixo acumulado',
      oldStatus: 'Em Progresso',
      newStatus: 'Resolvido',
      time: 'Há 2 dias',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Usamos bottom: false porque o extendBody no Scaffold pai lida com a nav bar,
      // mas precisamos de adicionar padding manual na ListView
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da Página
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

          // Lista de Atividades ou Empty State
          Expanded(
            child: _activities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      bottom:
                          100.0, // Padding para não ficar debaixo da BottomNavBar
                    ),
                    itemCount: _activities.length,
                    itemBuilder: (context, index) {
                      return _buildActivityCard(_activities[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // Componente: Card Individual de Atividade
  // ----------------------------------------------------------------------
  Widget _buildActivityCard(ActivityItem activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF0FDF4,
        ), // Fundo verde super claro (semelhante ao mockup)
        border: Border.all(color: Colors.green.shade100, width: 1.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar ou Ícone
          _buildLeadingIcon(activity),

          const SizedBox(width: 12),

          // Conteúdo de Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContentText(activity),
                const SizedBox(height: 6),
                Text(
                  activity.time,
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
    );
  }

  // Define se mostra a foto do utilizador ou o ícone de estado
  Widget _buildLeadingIcon(ActivityItem activity) {
    if (activity.type == ActivityType.comment) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(activity.avatarUrl ?? ''),
        backgroundColor: Colors.grey.shade300,
      );
    } else {
      final isResolved = activity.isResolved ?? false;
      return CircleAvatar(
        radius: 20,
        backgroundColor: isResolved
            ? Colors.green.shade500
            : Colors.blue.shade500,
        child: Icon(
          isResolved
              ? Icons.check
              : Icons.sync, // Ícones para resolvido / progresso
          color: Colors.white,
          size: 20,
        ),
      );
    }
  }

  // Constrói o texto formatado (RichText) para ter partes em Negrito/Cores
  Widget _buildContentText(ActivityItem activity) {
    if (activity.type == ActivityType.comment) {
      return RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '${activity.user} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: 'comentou na sua denúncia '),
            TextSpan(
              text: '"${activity.reportTitle}"',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      final isResolved = activity.isResolved ?? false;
      final statusColor = isResolved
          ? Colors.green.shade700
          : Colors.blue.shade700;

      return RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: 'A '),
            TextSpan(
              text: '${activity.entity} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: 'mudou o estado da sua denúncia '),
            TextSpan(
              text: '"${activity.reportTitle}" ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: 'de '),
            TextSpan(
              text: '${activity.oldStatus} ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: 'para '),
            TextSpan(
              text: '${activity.newStatus}',
              style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
            ),
          ],
        ),
      );
    }
  }

  // ----------------------------------------------------------------------
  // Componente: Estado Vazio (Nenhuma atividade)
  // ----------------------------------------------------------------------
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
          const SizedBox(height: 100), // Compensação visual
        ],
      ),
    );
  }
}
