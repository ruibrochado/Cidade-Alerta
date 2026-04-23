import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onReportTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onReportTap,
  });

  static const Color activeColor = Color(0xFF00D159);
  static const Color inactiveColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height: 105 + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 12,
            right: 12,
            bottom: bottomInset > 0 ? bottomInset : 12,
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_outlined,
                      label: 'Início',
                      isActive: currentIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.recycling_outlined,
                      label: 'Reciclar',
                      isActive: currentIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  const SizedBox(width: 76),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.map_outlined,
                      label: 'Mapa',
                      isActive: currentIndex == 2,
                      onTap: () => onTabSelected(2),
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'Atividade',
                      isActive: currentIndex == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onReportTap,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x2200D159),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Denunciar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: activeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const Color activeColor = AppBottomNavBar.activeColor;
  static const Color inactiveColor = AppBottomNavBar.inactiveColor;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
