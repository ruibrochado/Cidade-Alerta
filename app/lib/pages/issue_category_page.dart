import 'package:app/pages/details_page.dart';
import 'package:flutter/material.dart';

class CategoryItem {
  const CategoryItem({
    required this.name,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String name;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

const List<CategoryItem> _categories = <CategoryItem>[
  CategoryItem(
    name: 'Infraestrutura',
    icon: Icons.construction,
    backgroundColor: Color(0xFFFFEDD5),
    iconColor: Color(0xFFEA580C),
  ),
  CategoryItem(
    name: 'Iluminação Pública',
    icon: Icons.lightbulb,
    backgroundColor: Color(0xFFFEF9C3),
    iconColor: Color(0xFFCA8A04),
  ),
  CategoryItem(
    name: 'Sinalização',
    icon: Icons.traffic,
    backgroundColor: Color(0xFFFEE2E2),
    iconColor: Color(0xFFDC2626),
  ),
  CategoryItem(
    name: 'Meio Ambiente',
    icon: Icons.park,
    backgroundColor: Color(0xFFDCFCE7),
    iconColor: Color(0xFF16A34A),
  ),
  CategoryItem(
    name: 'Lixo e Limpeza',
    icon: Icons.delete_outline,
    backgroundColor: Color(0xFFF3F4F6),
    iconColor: Color(0xFF4B5563),
  ),
  CategoryItem(
    name: 'Outros',
    icon: Icons.error_outline,
    backgroundColor: Color(0xFFDBEAFE),
    iconColor: Color(0xFF2563EB),
  ),
];

class SelectCategory extends StatelessWidget {
  const SelectCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 235,
                  width: double.infinity,
                  color: const Color(0xFFCDE5CB),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),

            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 14,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2E7D32),
                          width: 4,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 150,
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Criar Denúncia',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selecione a categoria da sua denúncia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: GridView.builder(
                        itemCount: _categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (BuildContext context, int index) {
                          final CategoryItem category = _categories[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailsPage(category: category.name),
                                ),
                              );
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: category.backgroundColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        category.icon,
                                        size: 32,
                                        color: category.iconColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      category.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}