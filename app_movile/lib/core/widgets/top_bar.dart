import 'package:app_movile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// PreferredSizeWidget
PreferredSizeWidget topBar(BuildContext context, bool isConnected) {
  return AppBar(
    backgroundColor: const Color(0xFF0F1115),
    elevation: 0,
    leading: Icon(Icons.sensors, color: AppColors.green),
    title: const Text(
      'AccelerBike',
      style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    ),
    centerTitle: true,
    actions: [
      Icon(
        Icons.bluetooth, 
        color: isConnected ? AppColors.green : AppColors.grey200
      ),
      const SizedBox(width: 16),
    ],
  );
}