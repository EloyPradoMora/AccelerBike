import 'package:flutter/material.dart';

class StatusBanner extends StatelessWidget {
  final bool isWakelockActive;
  final bool isConnected;

  const StatusBanner({
    super.key,
    required this.isWakelockActive,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF13151A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Estado Wakelock
          Row(
            children: [
              Icon(
                Icons.wb_incandescent_outlined,
                color: isWakelockActive ? const Color(0xFF00E676) : Colors.grey,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'WAKELOCK ${isWakelockActive ? "ACTIVE" : "INACTIVE"}',
                style: TextStyle(
                  color: isWakelockActive ? const Color(0xFF00E676) : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Estado de Conexión del sensor
          Row(
            children: [
              Icon(
                Icons.rss_feed,
                color: isConnected ? const Color(0xFF00E676) : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'CONECTADO' : 'DESCONECTADO',
                style: TextStyle(
                  color: isConnected ? const Color(0xFF00E676) : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}