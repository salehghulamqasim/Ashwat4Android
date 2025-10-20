import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String status;

  static const _gold = Color(0xFFD4AF37);
  static const _beige = Color(0xFFF5E6D3);
  static const _brown = Color(0xFF2C1810);

  const StatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _brown.withOpacity(0.95),
                const Color(0xFF3E2723).withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _gold.withOpacity(0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _beige,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
