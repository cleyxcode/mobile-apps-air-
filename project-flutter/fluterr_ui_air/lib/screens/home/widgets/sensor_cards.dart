import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/sensor_data.dart';

class SensorCards extends StatelessWidget {
  final SensorData? data;

  const SensorCards({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SensorCard(
            icon: Icons.water_drop_rounded,
            value: data != null ? data!.soilMoisture.toStringAsFixed(1) : '--',
            unit: '%',
            label: 'Kelembaban Tanah',
            color: AppColors.primary,
            bgColor: AppColors.primarySurface,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SensorCard(
            icon: Icons.thermostat_rounded,
            value: data != null ? data!.temperature.toStringAsFixed(1) : '--',
            unit: '°C',
            label: 'Suhu',
            color: AppColors.warning,
            bgColor: const Color(0xFFFFFBEB),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SensorCard(
            icon: Icons.air_rounded,
            value: data != null ? data!.airHumidity.toStringAsFixed(0) : '--',
            unit: '%',
            label: 'Udara',
            color: AppColors.info,
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;
  final Color bgColor;

  const _SensorCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
