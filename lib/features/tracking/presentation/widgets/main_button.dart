import 'package:flutter/material.dart';

class MainButton extends StatelessWidget {
  final bool isTracking;
  final bool canStart;
  final Animation<double> pulseAnimation;
  final Animation<double> glowAnimation;
  final bool isTestMode;
  final VoidCallback onTap;

  static const _gold = Color(0xFFD4AF37);
  static const _gold2 = Color(0xFFB8860B);
  static const _beige = Color(0xFFF5E6D3);

  const MainButton({
    super.key,
    required this.isTracking,
    required this.canStart,
    required this.pulseAnimation,
    required this.glowAnimation,
    required this.isTestMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ScaleTransition(
        scale: pulseAnimation,
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isTracking
                      ? [const Color(0xFF8B4513), const Color(0xFF654321)]
                      : (canStart
                          ? [_gold, _gold2]
                          : [Colors.grey, Colors.grey]),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  isTracking
                      ? const Color(0xFF654321)
                      : (canStart ? _gold : Colors.grey.shade500),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isTracking
                        ? const Color(0xFF8B4513)
                        : (canStart ? _gold : Colors.grey))
                    .withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 6,
              ),
              BoxShadow(
                color: (isTracking
                        ? const Color(0xFF8B4513)
                        : (canStart ? _gold : Colors.grey))
                    .withOpacity(0.2),
                blurRadius: 45,
                spreadRadius: 12,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isTracking)
                ScaleTransition(
                  scale: glowAnimation,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF8B4513).withOpacity(0.3),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isTracking ? Icons.stop : Icons.directions_walk,
                    size: 45,
                    color:
                        isTracking
                            ? _beige
                            : (canStart ? Colors.black : Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTracking ? 'STOP' : 'START',
                    style: TextStyle(
                      color:
                          isTracking
                              ? _beige
                              : (canStart ? Colors.black : Colors.white70),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
