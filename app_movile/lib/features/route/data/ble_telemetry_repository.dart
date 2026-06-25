import 'dart:async';
import 'dart:convert';

import 'package:app_movile/core/ble/ble_connection_service.dart';

import 'model/telemetry.dart';

/// Implementación real de TelemetryRepository.
/// Traduce el stream crudo (JSON) del BleConnectionService en Telemetry tipado.
abstract class TelemetryRepository {
  Stream<Telemetry> get telemetryStream;
  void dispose();
}

class BleTelemetryRepository implements TelemetryRepository {
  final BleConnectionService _bleService;
  final _controller = StreamController<Telemetry>.broadcast();
  StreamSubscription<String>? _rawSub;

  BleTelemetryRepository({BleConnectionService? bleService})
      : _bleService = bleService ?? BleConnectionService.instance {
    _bleService.connect();
    _rawSub = _bleService.rawDataStream.listen(_handleRawData);
  }

  void _handleRawData(String jsonStr) {
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      _controller.add(Telemetry.fromJson(map));
    } catch (_) {
      // Si el JSON es inválido: se ignora el frame para no romper el stream.
    }
  }

  @override
  Stream<Telemetry> get telemetryStream => _controller.stream;

  @override
  void dispose() {
    _rawSub?.cancel();
    _controller.close();
  }
}