import 'package:flutter/material.dart';
import 'futuristic.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.note,
  });
  final String label;
  final String value;
  final IconData icon;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .94, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: GlassPanel(
        glowColor: const Color(0xFF00D9FF),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D9FF), Color(0xFF7C4DFF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D9FF).withValues(alpha: .45),
                    blurRadius: 22,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF9FB5D7),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (note != null)
                    Text(
                      note!,
                      style: const TextStyle(
                        color: Color(0xFF00FFA3),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) =>
      GlassPanel(padding: padding, child: child);
}

String money(num value) => '\$${value.toStringAsFixed(2)}';
