import 'package:flutter/material.dart';
import 'package:app_movile/core/theme/app_colors.dart';

class EditProfile extends StatefulWidget {
  final String currentName;
  final double wheelRadius;

  const EditProfile({
    super.key,
    required this.currentName,
    required this.wheelRadius
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _nameController;
  late TextEditingController _wheelRadiusController;
  bool _enableAverageSpeed = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _wheelRadiusController = TextEditingController(text: widget.wheelRadius.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wheelRadiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.black, 
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const SizedBox(height: 16),
            _buildExpectationRow(
              title: 'Radio de la Rueda (cm)', 
              value: _enableAverageSpeed, 
              onChanged: ((value) => setState(() => _enableAverageSpeed = value)), 
              controller: _wheelRadiusController
            ),
            const SizedBox(height: 32),
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
}
