import 'package:flutter/material.dart';

class LapCounter extends StatelessWidget {
  final int lapCount;
  final Animation<double> pulseAnimation;

  static const _gold = Color(0xFFD4AF37);
  static const _beige = Color(0xFFF5E6D3);
  static const _brown = Color(0xFF2C1810);

  const LapCounter({
    super.key,
    required this.lapCount,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: pulseAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _brown.withOpacity(0.9),
              const Color(0xFF3E2723).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: _gold.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Lap',
              style: TextStyle(color: _beige.withOpacity(0.8), fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${lapCount + 1}/7',
              style: TextStyle(
                color: _gold,
                fontSize: 52,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: _gold.withOpacity(0.4), blurRadius: 15),
                ],
              ),
            ),
            if (lapCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$lapCount completed',
                style: TextStyle(color: _beige.withOpacity(0.6), fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
