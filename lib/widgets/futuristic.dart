import 'dart:ui';
import 'package:flutter/material.dart';

class FuturisticBackground extends StatelessWidget {
  const FuturisticBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.65, -0.8),
              radius: 1.35,
              colors: [Color(0xFF12204C), Color(0xFF070B1B), Color(0xFF03050D)],
            ),
          ),
        ),
        Positioned(
          top: -150,
          left: -90,
          child: _GlowOrb(size: 390, color: Color(0xFF00D9FF)),
        ),
        Positioned(
          bottom: -180,
          right: -90,
          child: _GlowOrb(size: 460, color: Color(0xFF7C4DFF)),
        ),
        Positioned(
          top: 170,
          right: 150,
          child: _GlowOrb(size: 220, color: Color(0xFF00FFA3)),
        ),
        IgnorePointer(child: CustomPaint(painter: _GridPainter())),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: .16),
      ),
    ),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF54D8FF).withValues(alpha: .035)
      ..strokeWidth = .8;
    const gap = 44.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
    this.glowColor = const Color(0xFF00D9FF),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color glowColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: .105),
                Colors.white.withValues(alpha: .035),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: glowColor.withValues(alpha: .34),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: .13),
                blurRadius: 28,
                spreadRadius: -4,
              ),
              const BoxShadow(
                color: Colors.black54,
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
    return onTap == null
        ? panel
        : InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: panel,
          );
  }
}

class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.color = const Color(0xFF00D9FF),
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: .42),
          blurRadius: 24,
          spreadRadius: -6,
        ),
      ],
    ),
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(label),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: color.withValues(alpha: .88),
        foregroundColor: const Color(0xFF031019),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: .45)),
        ),
      ),
    ),
  );
}

class HolographicTitle extends StatelessWidget {
  const HolographicTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF8CF7FF), Color(0xFF8A7DFF), Color(0xFFFF6FD8)],
        ).createShader(bounds),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: .3,
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: const TextStyle(color: Color(0xFFA8B8D8), fontSize: 14),
      ),
    ],
  );
}

class PulsingStatusDot extends StatefulWidget {
  const PulsingStatusDot({
    super.key,
    this.color = const Color(0xFF00FFA3),
    this.size = 10,
  });
  final Color color;
  final double size;

  @override
  State<PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: .35 + controller.value * .45),
            blurRadius: 8 + controller.value * 10,
            spreadRadius: controller.value * 2,
          ),
        ],
      ),
    ),
  );
}
