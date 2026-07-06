import 'dart:async';
import 'package:app_movile/core/ble/ble_connection_service.dart';
import 'package:app_movile/core/ble/ble_state_notifier.dart';
import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/route/data/ble_telemetry_repository.dart';
import 'package:app_movile/features/route/data/model/telemetry.dart';
import 'package:app_movile/features/route/data/model/trip_summary.dart';
import 'package:app_movile/features/route/data/thingsboard_service.dart';
import 'package:app_movile/features/route/presentation/widgets/route_content.dart';
import 'package:app_movile/core/widgets/top_bar.dart';
import 'package:app_movile/core/widgets/nav_bar.dart';
import 'package:app_movile/core/auth/auth_state_notifier.dart';
import 'package:app_movile/core/network/supabase_service.dart';
import 'package:flutter/material.dart';

class RouteView extends StatefulWidget {
  const RouteView({super.key});

  @override
  State<RouteView> createState() => _RouteViewState();
}

class _RouteViewState extends State<RouteView> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final TelemetryRepository _repo;
  StreamSubscription<Telemetry>? _telemetrySub;
  final ThingsBoardService _thingsBoard = ThingsBoardService();
  Timer? _clockTimer;

  Telemetry _telemetry = Telemetry.empty();
  double _maxSpeed = 0;
  double _speedSum = 0;
  int _sampleCount = 0;
  bool _isFinishing = false;
  bool _isBleConnected = false;

  final Stopwatch _stopwatch = Stopwatch()..start();
  final bool isWakelockActive = true;

  Timer? _disconnectionTimer;
  bool _disconnectionAlertShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_){
      if (mounted) setState(() {});
    });

    _isBleConnected = BleStateNotifier.instance.isConnected;
    BleStateNotifier.instance.addListener(_onBleStateChanged);

    if (!_isBleConnected) _startDisconnectionTimer();

    _repo = BleTelemetryRepository();
    _telemetrySub = _repo.telemetryStream.listen((data) {
      setState(() {
        _telemetry = data;
        if (data.speedKmh > _maxSpeed) _maxSpeed = data.speedKmh;
        _speedSum += data.speedKmh;
        _sampleCount++;
      });
    });
  }

  void _onBleStateChanged() {
    final isConnected = BleStateNotifier.instance.isConnected;
    if (mounted) setState(() => _isBleConnected = isConnected);

    if (isConnected) {
      _disconnectionTimer?.cancel();
      _disconnectionTimer = null;
      _disconnectionAlertShown = false;
    } else {
      _startDisconnectionTimer();
    }
  }

  void _startDisconnectionTimer() {
    if (_disconnectionAlertShown || _disconnectionTimer != null) return;

    _disconnectionTimer = Timer(const Duration(seconds: 5), () {
      _disconnectionTimer = null;
      _disconnectionAlertShown = true;
      _showDisconnectionAlert();
    });
  }

  void _showDisconnectionAlert() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.amber, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sensor desconectado',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'No se reciben datos del sensor por más de 5 segundos. '
          'Tu viaje puede estar perdiendo información.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Esperar',
                style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.softRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _onStopRide();
            },
            child: const Text(
              'Terminar viaje',
              style: TextStyle(
                  color: AppColors.darkRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    BleConnectionService.instance.notifyAppLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BleStateNotifier.instance.removeListener(_onBleStateChanged);
    _disconnectionTimer?.cancel();
    _telemetrySub?.cancel();
    _clockTimer?.cancel();
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

    unawaited(
      Future.wait([
        _thingsBoard.sendTripSummary(summary),
        _saveToSupabase(summary),
      ]).then((results) {
        if (!mounted) return;
        if (!results[0] && !results[1]) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Viaje finalizado. Sin conexión para sincronizar.')),
          );
        }
      }).catchError((_) {}),
    );
    Navigator.pop(context);
  }

  Future<bool> _saveToSupabase(TripSummary summary) async {
    final userId = AuthStateNotifier.instance.userId;
    if (userId == null) return true;
    try {
      await supabaseService.saveTrip(
        userId: userId, 
        totalDistance: summary.distanceKm, 
        maxSpeed: summary.maxSpeedKmh, 
        avgSpeed: summary.avgSpeedKmh, 
        duration: summary.durationSeconds
      );
      return true;
    } catch (_) {
      return false;
    }
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
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    progressInfo(
                        context,
                        isWakelockActive,
                        _isBleConnected,
                        _telemetry.distanceKm,
                        _formattedDuration,
                        _telemetry.speedKmh,
                        _maxSpeed),
                    const SizedBox(height: 32),
                    buttons(context,
                        onStop: _onStopRide, isLoading: _isFinishing),
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