import 'package:app_movile/core/network/supabase_service.dart';
import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/statistics/presentation/widgets/statistics_content.dart';
import 'package:flutter/material.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});
  
  @override
  State<StatisticsView> createState() => _StatisticsView();
}

class _StatisticsView extends State<StatisticsView> {
  bool isLoading = true; 
  double totalDistance = 0.0;
  int totalDurationSeconds = 0;
  double avgSpeed = 0.0;
  String dateRange = "Calculando...";

  @override
  void initState() {
    super.initState();
    _fetchAndCalculateStatistics();
  }

  Future<void> _fetchAndCalculateStatistics() async {
    final trips = await supabaseService.getUserTrips();

    if (trips.isEmpty) {
      setState(() {
        isLoading = false;
        dateRange = "Sin datos aún";
      });
      return;
    }

    double tempDistance = 0;
    int tempDuration = 0;
    double sumAvgSpeeds = 0;

    for (var trip in trips) {
      tempDistance += (trip['total_distance_km'] ?? 0);
      tempDuration += (trip['duration_seconds'] ?? 0) as int;
      sumAvgSpeeds += (trip['avg_speed_kmh'] ?? 0);
    }

    setState(() {
      totalDistance = tempDistance;
      totalDurationSeconds = tempDuration;
      avgSpeed = sumAvgSpeeds / trips.length; 
      dateRange = "Estadísticas Globales"; 
      isLoading = false;
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = ((seconds % 3600) ~/ 60);
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), 
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : LayoutBuilder(
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
                      Text(
                        'Análisis Global',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold,
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

                      metricCard(
                        title: 'DISTANCIA RECORRIDA',
                        value: totalDistance.toStringAsFixed(1), 
                        unit: 'kms',
                        icon: Icons.alt_route_rounded,
                      ),
                      const SizedBox(height: 16),
                      metricCard(
                        title: 'TIEMPO DE VIAJE',
                        value: _formatDuration(totalDurationSeconds), 
                        unit: 'hrs',
                        icon: Icons.access_time_rounded,
                      ),
                      const SizedBox(height: 16),
                      metricCard(
                        title: 'VELOCIDAD PROMEDIO',
                        value: avgSpeed.toStringAsFixed(1), 
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