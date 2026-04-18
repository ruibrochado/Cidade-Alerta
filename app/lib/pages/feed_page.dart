import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class FeedPage extends StatelessWidget {
  FeedPage({super.key});

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();
    final userEmail = user?.email ?? 'Utilizador';

    return Scaffold(
      backgroundColor: const Color(0xFFCDE5CB),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Botão + clicado');
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
                    child: Icon(Icons.person, size: 35, color: Colors.grey[400]),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Olá,',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54, // Um cinza escuro suave
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800, // Bem gordinha
                            letterSpacing: 0, // Letras mais juntinhas
                            color: Colors.black87,
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
                  fontSize: 28, // Aumentei um bocadinho para dar impacto
                  fontWeight: FontWeight.w900, // O máximo de negrito possível!
                  height: 1.15, // Aproximar as duas linhas de texto
                  letterSpacing: -1.0, // Este é o grande truque para parecer fonte de mockup
                  color: Color(0xFF1A1A1A), // Quase preto
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                                letterSpacing: -0.3,
                              )
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
            ),
            const SizedBox(height: 25),

            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                              'Denúncias recentes',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                                color: Color(0xFF1A1A1A),
                              )
                          ),
                          Text(
                              'Ver todas',
                              style: TextStyle(
                                color: Color(0xFF00D159), // Verde do teu mockup
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              )
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text(
                          '12 denúncias ativas',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          )
                      ),
                      const SizedBox(height: 20),

                      const Expanded(
                        child: Center(
                          child: Text('Lista de cartões entra aqui...'),
                        ),
                      )
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
}