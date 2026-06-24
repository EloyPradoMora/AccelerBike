import 'dart:async';
import 'model/telemetry.dart';

// DEFINIR AQUI COMO SE PROCESAN LOS DATOS
// Ver como detectar cuando el dispositivo esta conectado, 
// para ver como integrarlo a las pantallas
// Home, Route, Profile 
abstract class TelemetryRepository {
  Stream<Telemetry> get telemetryStream;
  void dispose();
}

/// IMPLEMENTACION DE PRUEBA: emite valores simulados cada segundo
class MockTelemetryRepository implements TelemetryRepository {
  final _controller = StreamController<Telemetry>.broadcast();
  Timer? _timer;
  double _distance = 0;

  MockTelemetryRepository() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _distance += 0.05;
      _controller.add(Telemetry(
        speedKmh: 18 + (DateTime.now().second % 10),
        distanceKm: _distance,
      ));
    });
  }

  @override
  Stream<Telemetry> get telemetryStream => _controller.stream;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}