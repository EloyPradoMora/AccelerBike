import 'dart:async';
import 'package:flutter/foundation.dart';
import 'ble_connection_service.dart';

class BleStateNotifier extends ChangeNotifier{
  BleConnectionStatus _status = BleConnectionService.instance.currentStatus;

  BleStateNotifier._internal(){
    _sub = BleConnectionService.instance.statusStream.listen((s) {
      _status = s;
      notifyListeners();
    });
  }

  static final BleStateNotifier instance = BleStateNotifier._internal();
  
  StreamSubscription<BleConnectionStatus>? _sub;

  BleConnectionStatus get status => _status;
  bool get isConnected => _status == BleConnectionStatus.connected;

  bool get isSearching =>
        _status == BleConnectionStatus.scanning ||
        _status == BleConnectionStatus.connected;

  @override
  void dispose(){
    _sub?.cancel();
    super.dispose();
  } 
}