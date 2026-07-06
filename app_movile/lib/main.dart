import 'dart:async';
import 'package:app_movile/core/auth/auth_state_notifier.dart';
import 'package:app_movile/core/ble/ble_connection_service.dart';
import 'package:app_movile/core/ble/ble_state_notifier.dart';
import 'package:app_movile/features/home/presentation/home_view.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
 
const _supabaseUrl = String.fromEnvironment("SUPABASE_URL");
const _supabaseAnonKey = String.fromEnvironment("SUPABASE_KEY");

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  BleStateNotifier.instance;
  unawaited(BleConnectionService.instance.connect());
  try {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    if(Supabase.instance.client.auth.currentUser == null) {
      await Supabase.instance.client.auth.signInAnonymously();
    }
    AuthStateNotifier.instance;
  } catch (e){
    debugPrint('Supabase init error: $e');
  }
  runApp(const AccelerBike());
}

class AccelerBike extends StatelessWidget {
  const AccelerBike({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AccelerBike',
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
    );
  }
}
