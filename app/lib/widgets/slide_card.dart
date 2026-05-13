import 'package:flutter/material.dart';

class SlideCard extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final bool isActive;
  final double borderRadius;

  final IconData? icon;
  final double? width;
  final double? height;

  const SlideCard({
    super.key,
    this.child,
    this.onTap,
    this.isActive = false,
    this.borderRadius = 20,
    this.icon,
    this.width,
    this.height,
  });

  @override
  State<SlideCard> createState() => _SlideCardState();
}

class _SlideCardState extends State<SlideCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Widget content =
        widget.child ??
        Container(
          width: widget.width ?? 44,
          height: widget.height ?? 44,
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFFD6EED6)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: widget.isActive
                ? const Color(0xFF1A6B3A)
                : const Color(0xFF344054),
          ),
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      child: AnimatedSlide(
        offset: _isPressed ? const Offset(0.03, 0) : Offset.zero,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: content,
        ),
      ),
    );
  }
}
