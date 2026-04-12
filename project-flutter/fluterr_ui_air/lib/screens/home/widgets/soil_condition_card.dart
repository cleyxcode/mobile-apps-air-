import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/sensor_data.dart';

class SoilConditionCard extends StatelessWidget {
  final SensorData? data;

  const SoilConditionCard({super.key, this.data});

  Color get _labelColor {
    switch (data?.label) {
      case 'Kering':
        return AppColors.warning;
      case 'Lembab':
        return AppColors.primary;
      case 'Basah':
        return AppColors.info;
      default:
        return AppColors.textMedium;
    }
  }

  Color get _labelBg {
    switch (data?.label) {
      case 'Kering':
        return const Color(0xFFFFFBEB);
      case 'Lembab':
        return AppColors.primarySurface;
      case 'Basah':
        return const Color(0xFFEFF6FF);
      default:
        return AppColors.surfaceVariant;
    }
  }

  IconData get _conditionIcon {
    switch (data?.label) {
      case 'Kering':
        return Icons.wb_sunny_rounded;
      case 'Lembab':
        return Icons.check_circle_rounded;
      case 'Basah':
        return Icons.water_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = data?.labelDisplay ?? '---';
    final emoji = data?.labelEmoji ?? '🌿';
    final desc = data?.description ?? 'Menunggu data sensor...';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Left: visual indicator
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: _labelBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 2),
                Icon(_conditionIcon, color: _labelColor, size: 16),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right: text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kondisi Tanah',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _labelBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _labelColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: _labelColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
