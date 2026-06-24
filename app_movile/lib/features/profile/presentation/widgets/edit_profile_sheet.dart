import 'package:flutter/material.dart';
import 'package:app_movile/core/theme/app_colors.dart';

class EditProfileSheet extends StatefulWidget {
  final String currentName;
  final int currentDistance;
  final String hourDuration;
  final String minDuration;
  final double _avgSpeed;

  const EditProfileSheet({
    super.key,
    required this.currentName,
    required this.currentDistance,
    required this.hourDuration,
    required this.minDuration,
    required this._avgSpeed
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _distanceController;
  late TextEditingController _hoursController;
  late TextEditingController _minController;
  late TextEditingController _avgSpeedController;

  bool _enableDistance = true;
  bool _enableDuration = true;
  bool _enableAverageSpeed = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _distanceController = TextEditingController(text: widget.currentDistance.toString());
    _hoursController = TextEditingController(text: widget.hourDuration.toString());
    _minController = TextEditingController(text: widget.minDuration.toString());
    _avgSpeedController = TextEditingController (text: widget._avgSpeed.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Evita que el teclado virtual tape los campos de texto al escribir
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.black, // Fondo oscuro integrado
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Línea estética superior que indica que se puede deslizar para cerrar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Editar Perfil',
              style: TextStyle(color: AppColors.grey200, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Campo Nombre de Usuario
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.grey200),
              decoration: InputDecoration(
                labelText: 'Nombre de usuario',
                labelStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.grey300)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.green)),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Expectativa Semanal',
              style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Switch + Input para Distancia
            _buildExpectationRow(
              title: 'Distancia (km)',
              value: _enableDistance,
              onChanged: (val) => setState(() => _enableDistance = val),
              controller: _distanceController,
            ),

            const SizedBox(height: 16),
            // Switch + Input para Tiempo de Viaje
            _buildTravelRow(
              title: 'Tiempo de viaje (hrs/min)',
              value: _enableDuration,
              onChanged: (val) => setState(() => _enableDuration = val),
              hour: _hoursController,
              min: _minController
            ),

            const SizedBox(height: 16),
            // Switch para Velocidad Promedio
            _buildExpectationRow(
              title: 'Velocidad Promedio (km/h)', 
              value: _enableAverageSpeed, 
              onChanged: ((value) => setState(() => _enableAverageSpeed = value)), 
              controller: _avgSpeedController
            ),
            const SizedBox(height: 32),
            // Botones de Acción Internos
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Cancelar', style: TextStyle(color: AppColors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      // Aquí enviarás los nuevos datos de vuelta o a la base de datos
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirmar', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildExpectationRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TextEditingController controller,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.grey200, fontSize: 14, fontWeight: FontWeight.w500
          ),
        ),
        SizedBox(
          width: 130,
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(),
            controller: controller,
            enabled: value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: value ? AppColors.grey200 : AppColors.grey300,
              fontSize: 14
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.green)
              ),
              hintText: '--',
              hintStyle: TextStyle(color: AppColors.grey500, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required TextEditingController hour,
    required TextEditingController min
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.grey200, fontSize: 14, fontWeight: FontWeight.w500
          ),
        ),
        // Incrementamos el ancho para dar espacio a los inputs de horas y minutos de forma paralela
        SizedBox(
          width: 130, 
          child: _buildOptions(hour, min, value),
        ),
      ],
    );
  }

  Widget _buildOptions(
    TextEditingController hour,
    TextEditingController min,
    bool value
  ){
    return Row(
      children: [
        // Primer campo: Horas
        Expanded(
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(),
            controller: hour,
            enabled: value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: value ? AppColors.grey200 : AppColors.grey300,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              isDense: true, // Reduce el padding vertical nativo para que sea más compacto
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.green)
              ),
              hintText: '00',
              hintStyle: TextStyle(color: AppColors.grey500, fontSize: 14)
            ),
          ),
        ),
        
        // Separador de tiempo
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(':', style: TextStyle(color: AppColors.grey200, fontWeight: FontWeight.bold)),
        ),
        
        // Segundo campo: Minutos
        Expanded(
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(),
            controller: min,
            enabled: value, // No olvides vincular el estado de activación aquí también
            textAlign: TextAlign.center,
            style: TextStyle(
              color: value ? AppColors.grey200 : AppColors.grey300,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.green)
              ),
              hintText: '00',
              hintStyle: TextStyle(color: AppColors.grey500, fontSize: 14)
            ),
          ),
        ),
      ],
    );
  }
}
