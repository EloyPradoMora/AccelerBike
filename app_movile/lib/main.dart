import 'dart:async';
import 'package:app_movile/core/ble/ble_connection_service.dart';
import 'package:app_movile/core/ble/ble_state_notifier.dart';
import 'package:app_movile/features/home/presentation/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  BleStateNotifier.instance;
  unawaited(BleConnectionService.instance.connect());

  runApp(const AccelerBike());
}

class AccelerBike extends StatelessWidget {
  const AccelerBike({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AccelerBike',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      routes: {
          '/home': (context) => const HomeView()
      },
    );
  }
}
