import 'package:app_movile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppText {
  static final TextStyle litleBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.grey300
  );

  static final TextStyle metricNumbers = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.grey200
  );
  static final TextStyle metricScale = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.grey200
  );

  static final TextStyle title = TextStyle(
    fontSize: 28, 
    fontWeight: FontWeight.bold,
    color: AppColors.grey200, 
  );
}
