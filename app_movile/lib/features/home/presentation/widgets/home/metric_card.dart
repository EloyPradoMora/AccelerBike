import 'package:app_movile/core/theme/app_text.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.grey700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey500)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.green, size: 16,),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: AppText.litleBold,
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: AppText.metricNumbers,
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppText.metricScale,
              )
            ],
          )
        ],
      ),
    );
  }
}