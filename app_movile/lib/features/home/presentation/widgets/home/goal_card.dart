import 'package:app_movile/core/theme/app_text.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class GoalCard extends StatelessWidget {
  final int percentage;

  const GoalCard({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.grey500,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flag, color: AppColors.green, size: 16),
              SizedBox(width: 8),
              Text(
                'OBJETIVO', 
                style: AppText.litleBold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$percentage%',
            style: AppText.metricScale,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white12,
            color: AppColors.green,
            minHeight: 8,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}