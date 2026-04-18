import 'package:flutter/material.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A cor de fundo verde-menta
      backgroundColor: const Color(0xFFCDE5CB),

      // O NOSSO BOTÃO '+' FLUTUANTE (Ainda sem ação)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Futuramente vai abrir a página de criar denúncia
          debugPrint('Botão + clicado');
        },
        backgroundColor: const Color(0xFFCDE5CB), // Verde vivo do teu mockup
        shape: const CircleBorder(), // Para garantir que é redondinho
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

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
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=5'), // Foto fake
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
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Viste algum problema\nna cidade?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
            const SizedBox(height: 20),

            // --- BARRA DE PESQUISA E FILTRO (Visuais apenas) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  // Barra de pesquisa (Container a imitar um TextField)
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25), // Formato de pílula
                      ),
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

                  // Botão de Filtro
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15), // Quadrado com cantos redondos
                    ),
                    child: const Icon(Icons.tune, color: Colors.grey), // Ícone de sliders
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25), // Espaço antes de começar a área branca

            // --- ÁREA BRANCA DAS DENÚNCIAS ---
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white, // LIMITES RETOS: Usar apenas cor sem o BoxDecoration com radius
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

                      // Aqui dentro entrará o teu ListView.builder com os cartões
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