import 'dart:async';

import 'package:app_movile/features/route/data/model/telemetry.dart';
import 'package:app_movile/features/route/data/telemetry_repository.dart';
import 'package:app_movile/features/route/presentation/widgets/route_content.dart';
import 'package:app_movile/core/widgets/top_bar.dart';
import 'package:app_movile/core/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class RouteView extends StatefulWidget {
  const RouteView({super.key});

  @override
  State<RouteView> createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> {
  int _selectedIndex = 0;
  late final TelemetryRepository _repo;
  StreamSubscription<Telemetry>? _sub;

  Telemetry _telemetry = Telemetry.empty();
  double _maxSpeed = 0;
  // Implementar cuando se integre
  // final Stopwatch _stopwatch = Stopwatch()..start();

  final bool isConnected = true;       
  final bool isWakelockActive = true;

  @override
  void initState() {
    super.initState();
    _repo = MockTelemetryRepository(); 
    _sub = _repo.telemetryStream.listen((data) {
      setState(() {
        _telemetry = data;
        if (data.speedKmh > _maxSpeed) _maxSpeed = data.speedKmh;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _repo.dispose();
    super.dispose();
  }

  // Variables de ruta simuladas (en el futuro vendrán de tu telemetry_service y cronómetro)
  final String duration = "00:32:15";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: topBar(context, isConnected),
      
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Grupo Superior: Banner de estados y Tarjetas de Telemetría
                      progressInfo(context, isWakelockActive, isConnected, _telemetry.distanceKm, duration, _telemetry.speedKmh, _maxSpeed),
                      
                      const SizedBox(height: 32), // Separación mínima antes de los botones

                      // Grupo Inferior: Botones de Acción de la Ruta
                      buttons(context)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}