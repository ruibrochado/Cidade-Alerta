import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A cor de fundo verde-menta do teu mockup
      backgroundColor: const Color(0xFFCDE5CB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER VERDE ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // Foto fake para teste
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Olá,', style: TextStyle(fontSize: 16)),
                      Text('Maria', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                'Viste algum problema\nna cidade?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
            const SizedBox(height: 20),

            // --- ÁREA BRANCA DAS DENÚNCIAS ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Denúncias recentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('Ver todas', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Text('12 denúncias ativas', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 20),

                      // Aqui dentro entrará o teu ListView.builder com os cartões!
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