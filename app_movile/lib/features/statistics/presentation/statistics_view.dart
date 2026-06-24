import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/statistics/presentation/widgets/statistics_content.dart';
import 'package:flutter/material.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});
  
  @override
  State<StatisticsView> createState() => _StatisticsView();
}

class _StatisticsView extends State<StatisticsView> {
  final bool isConnected = true;

  // Información de estadísticas provista
  final int targetDistance = 200;
  final String targetDuration = "02:45";
  final double avgSpeed = 26.4;
  
  // Rango de fechas simulado acorde a tu diseño de Figma
  final String dateRange = "Oct 16 - Oct 22";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantenemos consistencia con el fondo oscuro profundo de la app
      backgroundColor: const Color(0xFF0F1115), 

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabecera Principal
                      Text(
                        'Análisis Semanal',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace'
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateRange,
                        style: const TextStyle(
                          color: AppColors.grey300, 
                          fontSize: 14, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      const SizedBox(height: 24),

                      visualDashboard(),
                      const SizedBox(height: 24),

                      // --- SECCIÓN DE TARJETAS DETALLADAS ---
                      metricCard(
                        title: 'DISTANCIA RECORRIDA',
                        value: '$targetDistance',
                        unit: 'kms',
                        icon: Icons.alt_route_rounded,
                      ),
                      const SizedBox(height: 16),
                      metricCard(
                        title: 'TIEMPO DE VIAJE',
                        value: targetDuration,
                        unit: 'hrs',
                        icon: Icons.access_time_rounded,
                      ),
                      const SizedBox(height: 16),
                      metricCard(
                        title: 'VELOCIDAD PROMEDIO',
                        value: '$avgSpeed',
                        unit: 'km/h',
                        icon: Icons.speed_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        )
      ),
    );
  }
}