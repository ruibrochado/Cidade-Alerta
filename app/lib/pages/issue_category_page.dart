import 'package:app/pages/details_page.dart';
import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

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
    return AppScaffold(
      showLogo: true,
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Criar Denúncia',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecione a categoria da sua denúncia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                      builder: (_) => DetailsPage(category: category.name),
                    ),
                  );
                },
                child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
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
        ],
      ),
    );
  }
}