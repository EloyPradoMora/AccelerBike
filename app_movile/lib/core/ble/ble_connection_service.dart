import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BleConnectionStatus { disconnected, scanning, connecting, connected, error }

class BleConnectionService {
  BleConnectionService._internal();
  static final BleConnectionService instance = BleConnectionService._internal();

  static final Guid serviceUuid = Guid("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  static final Guid characteristicUuid = Guid("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  final _statusController = StreamController<BleConnectionStatus>.broadcast();
  final _rawDataController = StreamController<String>.broadcast();

  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _valueSub;
  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<List<ScanResult>>? _scanSub;
  Timer? _reconnectTimer;

  bool _shouldStayConnected = false;
  int _reconnectAttempt = 0;
  BleConnectionStatus _currentStatus = BleConnectionStatus.disconnected;

  Stream<BleConnectionStatus> get statusStream => _statusController.stream;
  Stream<String> get rawDataStream => _rawDataController.stream;
  BleConnectionStatus get currentStatus => _currentStatus;

  void _updateStatus(BleConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  Future<void> connect() async {
    if (_shouldStayConnected) return;
    _shouldStayConnected = true;
    await _requestPermissions();
    await _scanAndConnect();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    if (Platform.isAndroid) await Permission.locationWhenInUse.request();
  }

  Future<void> _scanAndConnect() async {
    if (!_shouldStayConnected) return;
    try {
      _updateStatus(BleConnectionStatus.scanning);

      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(const Duration(seconds: 5), onTimeout: () => BluetoothAdapterState.on);

      bool matched = false;

      await _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        if (matched || results.isEmpty) return;
        matched = true;
        _scanSub?.cancel();
        FlutterBluePlus.stopScan();
        _establishConnection(results.first.device);
      });

      await FlutterBluePlus.startScan(
        withServices: [serviceUuid],
        timeout: const Duration(seconds: 10),
      );

      await FlutterBluePlus.isScanning.where((scanning) => scanning == false).first;

      if (!matched && _shouldStayConnected) {
        _scheduleReconnect();
      }
    } catch (_) {
      _updateStatus(BleConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  Future<void> _establishConnection(BluetoothDevice device) async {
    try {
      await _connectAndSubscribe(device);
    } catch (_) {
      _updateStatus(BleConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  Future<void> _connectAndSubscribe(BluetoothDevice device) async {
    _device = device;
    _updateStatus(BleConnectionStatus.connecting);

    await _connSub?.cancel();
    _connSub = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        _valueSub?.cancel();
        _updateStatus(BleConnectionStatus.disconnected);
        if (_shouldStayConnected) _scheduleReconnect();
      }
    });

    await device.connect(license: License.nonprofit ,timeout: const Duration(seconds: 10));
    if (!kIsWeb && Platform.isAndroid) {
      await device.requestMtu(247);
    }

    await device.discoverServices();
    final service = device.servicesList.firstWhere((s) => s.uuid == serviceUuid);
    final characteristic =
        service.characteristics.firstWhere((c) => c.uuid == characteristicUuid);

    await characteristic.setNotifyValue(true);
    await _valueSub?.cancel();

    _valueSub = characteristic.onValueReceived.listen((bytes) async {
      if (bytes.isEmpty) return;

      try {
        final receivedString = utf8.decode(bytes);

        if (receivedString.contains('"request":"send_aro"')) {
          final prefs = await SharedPreferences.getInstance();
          final savedRadius = prefs.getDouble('wheel_radius') ?? 29.0;

          final rxChar = service.characteristics.firstWhere(
            (c) => c.uuid == Guid('beb5483e-36e1-4688-b7f5-ea07361b26a9'),
            orElse: () => throw StateError('RX characteristic no encontrada'),
          );

          await rxChar.write(
            utf8.encode(savedRadius.toString()),
            withoutResponse: false,
          );
          return;
        }
        _rawDataController.add(receivedString);
      } catch (_) { }
    });

    _reconnectAttempt = 0;
    _updateStatus(BleConnectionStatus.connected);
  }


  void _scheduleReconnect() {
    if (!_shouldStayConnected) return;
    _reconnectTimer?.cancel();
    _reconnectAttempt++;
    final seconds = (2 << (_reconnectAttempt - 1)).clamp(2, 30);
    _reconnectTimer = Timer(Duration(seconds: seconds), _attemptReconnect);
  }

  Future<void> _attemptReconnect() async {
    if (!_shouldStayConnected) return;

    final knownDevice = _device;
    if (knownDevice != null && _reconnectAttempt <= 2) {
      try {
        await _connectAndSubscribe(knownDevice);
        return;
      } catch (_) { }
    }
    await _scanAndConnect();
  }

  void notifyAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _shouldStayConnected &&
        _currentStatus != BleConnectionStatus.connected) {
      _reconnectTimer?.cancel();
      _attemptReconnect();
    }
  }

  Future<void> disconnect() async {
    _shouldStayConnected = false;
    _reconnectTimer?.cancel();
    await _valueSub?.cancel();
    await _connSub?.cancel();
    await _scanSub?.cancel();
    await _device?.disconnect();
    _device = null;
    _updateStatus(BleConnectionStatus.disconnected);
  }
}