import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/report_data.dart'; // Importa o teu modelo

class FeedPage extends StatelessWidget {
  FeedPage({super.key});

  final authService = AuthService();


  final List<ReportData> reportsDeTeste = [
    const ReportData(
      category: 'Infraestrutura',
      title: 'Buraco na via',
      description: 'Grande buraco no asfalto causando risco para motoristas e pedestres na zona central.',
      photos: ['https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&q=80&w=500'],
      latitude: 41.1579,
      longitude: -8.6291,
    ),
    const ReportData(
      category: 'Iluminação',
      title: 'Poste avariado',
      description: 'Rua completamente às escuras devido a falha no poste principal.',
      photos: ['https://images.unsplash.com/photo-1509391366360-120000000000?auto=format&fit=crop&q=80&w=500'],
      latitude: 41.1496,
      longitude: -8.6109,
    ),
    const ReportData(
      category: 'Sinalização',
      title: 'Stop derrubado',
      description: 'O sinal de stop no cruzamento foi derrubado após um acidente.',
      photos: ['https://images.unsplash.com/photo-1596450514735-24d607983692?auto=format&fit=crop&q=80&w=500'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();
    final userEmail = user?.email ?? 'Utilizador';

    return Scaffold(
      backgroundColor: const Color(0xFFCDE5CB),
      floatingActionButton: FloatingActionButton(
        onPressed: () => debugPrint('Botão + clicado'),
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
                    child: Icon(Icons.person, size: 35, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Olá,', style: TextStyle(fontSize: 16, color: Colors.black54)),
                        Text(
                          userEmail,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
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
                  letterSpacing: -0.8,
                  color: Color(0xFF333333),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                      child: Row(
                        children: const [
                          SizedBox(width: 15),
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text('Buscar denúncias...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.tune, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),


            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Denúncias recentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                          Text('Ver todas', style: TextStyle(color: Color(0xFF00D159), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text('${reportsDeTeste.length} denúncias ativas', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 20),


                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: reportsDeTeste.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 20),
                          itemBuilder: (context, index) => _buildCard(reportsDeTeste[index]),
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


  Widget _buildCard(ReportData report) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              report.photos.isNotEmpty ? report.photos.first : 'https://via.placeholder.com/400x200',
              height: 160, width: double.infinity, fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                const SizedBox(height: 5),
                Text(report.description, style: const TextStyle(fontSize: 14, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Icon(Icons.location_on, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Vila Nova de Gaia', style: TextStyle(fontSize: 12, color: Colors.grey)), // Fixa por enquanto
                  ],
                ),
                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward, size: 20, color: Colors.black54),
                        const SizedBox(width: 5),
                        const Text('12', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_downward, size: 20, color: Colors.black54),
                      ],
                    ),
                    Row(
                      children: const [
                        Icon(Icons.chat_bubble_outline, size: 20, color: Colors.black54),
                        SizedBox(width: 5),
                        Text('4', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}