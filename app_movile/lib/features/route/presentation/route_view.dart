import 'dart:async';
import 'package:app_movile/core/ble/ble_connection_service.dart';
import 'package:app_movile/features/route/data/ble_telemetry_repository.dart';
import 'package:app_movile/features/route/data/model/telemetry.dart';
import 'package:app_movile/features/route/data/model/trip_summary.dart';
import 'package:app_movile/features/route/data/thingsboard_service.dart';
import 'package:app_movile/features/route/presentation/widgets/route_content.dart';
import 'package:app_movile/core/widgets/top_bar.dart';
import 'package:app_movile/core/widgets/nav_bar.dart';
import 'package:flutter/material.dart';

class RouteView extends StatefulWidget {
  const RouteView({super.key});
  @override
  State<RouteView> createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> with WidgetsBindingObserver{
  // Buscar la forma de hacer que el permiso de conexion de dispositivo se muestre desde el home para que no sea tan molesto
  // ademas buscar forma de hacer que el permiso quede registrado para no tener que solicitarlo repetidamente.
  int _selectedIndex = 0;
  late final TelemetryRepository _repo;
  StreamSubscription<Telemetry>? _sub;
  StreamSubscription<BleConnectionStatus>? _statusSub;
  final ThingsBoardService _thingsBoard = ThingsBoardService();

  Telemetry _telemetry = Telemetry.empty();
  double _maxSpeed = 0;
  double _speedSum = 0;
  int _sampleCount = 0;
  bool _isFinishing = false;
  bool _isBleConnected = false;

  final Stopwatch _stopwatch = Stopwatch()..start();
  final bool isWakelockActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repo = BleTelemetryRepository(); 
    _sub = _repo.telemetryStream.listen((data) {
      setState(() {
        _telemetry = data;
        if (data.speedKmh > _maxSpeed) _maxSpeed = data.speedKmh;
        _speedSum += data.speedKmh;
        _sampleCount++;
      });
    });
    _statusSub = BleConnectionService.instance.statusStream.listen((status) {
      setState(() => _isBleConnected = status == BleConnectionStatus.connected);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    BleConnectionService.instance.notifyAppLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _statusSub?.cancel();
    _repo.dispose();
    super.dispose();
  }

  String get _formattedDuration {
    final d = _stopwatch.elapsed;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  Future<void> _onStopRide() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    _stopwatch.stop();

    final summary = TripSummary(
      maxSpeedKmh: _maxSpeed,
      avgSpeedKmh: _sampleCount == 0 ? 0 : _speedSum / _sampleCount,
      distanceKm: _telemetry.distanceKm,
      durationSeconds: _stopwatch.elapsed.inSeconds,
    );

    final success = await _thingsBoard.sendTripSummary(summary);
    if (!mounted) return;

    if (!success) {
      setState(() => _isFinishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        // Hacerle un refactor para que este apartado sea un pop up, para que un usuario lo pueda notar
        const SnackBar(content: Text('No se pudo enviar el resumen a ThingsBoard. Reintenta.')),
      );
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: topBar(context, _isBleConnected),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    progressInfo(context, isWakelockActive, _isBleConnected,
                        _telemetry.distanceKm, _formattedDuration, _telemetry.speedKmh, _maxSpeed),
                    const SizedBox(height: 32),
                    buttons(context, onStop: _onStopRide, isLoading: _isFinishing),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}