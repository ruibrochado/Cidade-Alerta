import 'package:flutter/material.dart';

class SlideCard extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double borderRadius;

  const SlideCard({
    super.key,
    required this.isActive,
    required this.onTap,
    this.width = 52,
    this.height = 52,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00D159) : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.tune,
          color: isActive ? Colors.white : const Color(0xFF98A2B3),
        ),
      ),
    );
  }
}
