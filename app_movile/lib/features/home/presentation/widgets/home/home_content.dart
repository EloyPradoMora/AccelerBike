import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/home/presentation/widgets/home/metric_card.dart';
import 'package:flutter/material.dart';

Widget welcomeMessage(BuildContext context, bool isConnected) {
  return Text.rich(
    TextSpan(
      style: const TextStyle(
        fontSize: 16, 
        color: Colors.white70, 
        height: 1.4 // Esto mejora el interlineado si el texto se divide en dos líneas
      ),
      children: [
        const TextSpan(text: 'Dispositivo '),
        TextSpan(
          text: isConnected ? 'CONECTADO ' : 'DESCONECTADO ',
          style: TextStyle(
            color: isConnected ? AppColors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: isConnected ? 'y listo para un nuevo viaje.': 'comprueba la conexion del dispositivo.'),
      ],
    ),
  );
}

Widget metrics(BuildContext context, String weeklyDistance) {
  return Column(
    children: [
     MetricCard(
      title: 'Distancia Semanal',
      value: weeklyDistance,
      unit: 'km',
      icon: Icons.route, 
    ),
    const SizedBox(height: 16),
    ]
  );
}

Widget startTravel(BuildContext context){
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF00E676)),
      color: const Color(0xFF1A1A1A),
    ),
    child: Row(
      children: [
        const Icon(Icons.explore_outlined, color: Color(0xFF00E676), size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
              '¿Te gustaría empezar\nun Recorrido?',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Hoy es un excelente día para salir a pedalear.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}