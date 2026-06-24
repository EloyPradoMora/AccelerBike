import 'package:flutter/material.dart';

class TelemetryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color valueColor;
  final double? progress; 

  const TelemetryCard({
    super.key,
    required this.title,
    required this.value,
    this.unit = '',
    required this.icon,
    this.valueColor = Colors.white,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila Superior: Título e Icono
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(icon, color: const Color(0xFF00E676), size: 16),
            ],
          ),
          const SizedBox(height: 4),
          
          // Fila Central: Valor Principal y Unidad
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold, 
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ],
          ),
          
          if (progress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              color: const Color(0xFF00E676),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ],
      ),
    );
  }
}