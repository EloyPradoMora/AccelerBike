import 'package:app_movile/features/profile/presentation/widgets/profile_content.dart'; // Importante importar tu archivo de widgets
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  
  @override
  State<ProfileView> createState() => _ProfileView();
}

class _ProfileView extends State<ProfileView> {
  final bool isConnected = true;

  // Información simulada del perfil
  final String profileName = "Alessandro Duarte";
  final int targetDistance = 200;
  final String targetDuration = "02:45";
  final double avgSpeed = 26.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      body: SafeArea(
        child: LayoutBuilder(
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
                      const Text(
                        'Perfil',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // Render de la tarjeta del perfil de usuario
                      cardProfile(context, profileName, targetDistance, targetDuration, avgSpeed),
                      const SizedBox(height: 24),
                      
                      // Render del estado del hardware (ESP32)
                      cardDevice('ESP32 Telemetry Hub', 100, -42),
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