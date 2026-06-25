import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/route/presentation/widgets/status_banner.dart';
import 'package:app_movile/features/route/presentation/widgets/telemetry_card.dart';
import 'package:flutter/material.dart';

Widget progressInfo(
    BuildContext context, 
    bool isWakelockActive, bool isConnected, 
    double distance, String duration, 
    double currentSpeed, double maxSpeed
  ){
  return Column(
    children: [
      StatusBanner(
        isWakelockActive: isWakelockActive,
        isConnected: isConnected,
      ),
      const SizedBox(height: 24),
      TelemetryCard(
        title: 'Distancia',
        value: '$distance',
        unit: 'km',
        icon: Icons.route,
      ),
      const SizedBox(height: 16),
      TelemetryCard(
        title: 'Tiempo',
        value: duration,
        icon: Icons.timer_outlined,
      ),
      const SizedBox(height: 16),
      TelemetryCard(
        title: 'Velocidad',
        value: '$currentSpeed',
        unit: 'km/h',
        icon: Icons.speed,
        valueColor: const Color(0xFF00E676),
        progress: 0.6, 
      ),
      const SizedBox(height: 16),                
      TelemetryCard(
        title: 'Velocidad Máxima',
        value: '$maxSpeed',
        unit: 'km/h',
        icon: Icons.speed,
        valueColor: const Color(0xFFE65100), 
      ),
    ],
  );
}


Widget buttons(BuildContext context, {required VoidCallback onStop, bool isLoading = false}) {
  // Hacer que ambos botones al momento de hacer clic den alguna señal de si funciono o no, puede ser un snack bar o algo similar
  return Row(
    children: [
      Expanded(
        child: FilledButton.icon(
          // Cuando se hace clic en pausar despues ya no se puede hacer que vuelva a funcionar el cronometro
          onPressed: () {},
          icon: const Icon(Icons.pause, color: Colors.black),
          label: const Text('Pause',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF00E676),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: FilledButton.icon(
          onPressed: isLoading ? null : onStop,
          icon: isLoading
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.stop, color: AppColors.darkRed),
          label: Text(isLoading ? 'Enviando...' : 'Stop Ride',
              style: const TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.bold, fontSize: 18)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.softRed,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ],
  );
}