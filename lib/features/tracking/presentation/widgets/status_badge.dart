import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final bool isTestMode;
  final double? accuracyMeters;
  final Animation<double> breatheAnimation;

  static const _gold = Color(0xFFD4AF37);
  static const _beige = Color(0xFFF5E6D3);
  static const _brown = Color(0xFF2C1810);

  const StatusBadge({
    super.key,
    required this.isTestMode,
    required this.accuracyMeters,
    required this.breatheAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final ready = (accuracyMeters != null && accuracyMeters! <= 25.0);
    final color =
        isTestMode ? _gold : (ready ? _gold : const Color(0xFFFFC107));
    final label = isTestMode ? 'Test Mode' : (ready ? 'Ready' : 'Waiting...');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _brown.withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: ready ? const AlwaysStoppedAnimation(1.0) : breatheAnimation,
            child: Icon(
              ready ? Icons.check_circle : Icons.schedule,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: _beige,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
