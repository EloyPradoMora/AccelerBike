import 'package:app_movile/core/theme/app_colors.dart';
import 'package:app_movile/features/profile/presentation/widgets/edit_profile_sheet.dart';
import 'package:flutter/material.dart';



Widget cardProfile(BuildContext context, String nombre) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      color: AppColors.darkGreen,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.grey700),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(nombre,
                style: const TextStyle(
                    color: AppColors.grey200,
                    fontSize: 24,
                    fontWeight: FontWeight.bold
                )
            ),
          ],
        ),
      ],
    ),
  );
}

Widget cardProfilePlus(BuildContext context, String nombre, int distancia,
    String tiempo, double avgSpeed) {
  var duracion = tiempo.split(':');
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      color: AppColors.darkGreen,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.grey700),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(nombre,
                style: const TextStyle(
                    color: AppColors.grey200,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => EditProfileSheet(
                    currentName: nombre,
                    currentDistance: distancia,
                    hourDuration: duracion[0],
                    minDuration: duracion[1],
                    avgSpeed: avgSpeed,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: AppColors.green, shape: BoxShape.circle),
                child: const Icon(Icons.edit_rounded,
                    color: Colors.black, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Expectativa Semanal',
            style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        const SizedBox(height: 12),
        _buildDataRow('Distancia esperada', '$distancia km'),
        const SizedBox(height: 8),
        _buildDataRow('Tiempo de viaje', '$tiempo hrs'),
      ],
    ),
  );
}

Widget cardDevice(String deviceName, bool isConnected) {
  final Color statusColor = isConnected ? AppColors.green : Colors.red;
  final String statusLabel = isConnected ? 'CONECTADO' : 'DESCONECTADO';
  final IconData deviceIcon = isConnected
      ? Icons.bluetooth_connected
      : Icons.bluetooth_disabled;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Dispositivo',
        style: TextStyle(
            color: AppColors.grey200,
            fontSize: 22,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey500),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? AppColors.green
                        : AppColors.grey500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    deviceIcon,
                    color: isConnected
                        ? AppColors.darkGreen
                        : Colors.white38,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceName,
                        style: const TextStyle(
                            color: AppColors.grey200,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.circle,
                              color: statusColor, size: 10),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildHardwareMetric(
                    'PROTOCOLO',
                    'BLE 4.x',
                    Icons.settings_input_antenna,
                    AppColors.grey200,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHardwareMetric(
                    'ESTADO',
                    isConnected ? 'Activo' : 'Sin señal',
                    isConnected
                        ? Icons.wifi_tethering
                        : Icons.wifi_tethering_off,
                    statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}


Widget _buildDataRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style:
              const TextStyle(color: AppColors.grey300, fontSize: 16)),
      Text(value,
          style: const TextStyle(
              color: AppColors.grey200,
              fontSize: 16,
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold)),
    ],
  );
}


Widget _buildHardwareMetric(
    String title, String value, IconData icon, Color valueColor) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF13151A),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey, size: 14),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ],
    ),
  );
}