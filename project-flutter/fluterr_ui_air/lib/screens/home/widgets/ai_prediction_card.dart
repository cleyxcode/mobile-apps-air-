import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../models/sensor_data.dart';

class AIPredictionCard extends StatelessWidget {
  final SensorData? data;
  final VoidCallback? onWaterNow;
  final double? modelAccuracy;

  const AIPredictionCard({
    super.key,
    this.data,
    this.onWaterNow,
    this.modelAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = modelAccuracy != null
        ? '${modelAccuracy!.toStringAsFixed(1)}%'
        : '...';
    final confidence = data != null
        ? '${data!.confidence.toStringAsFixed(1)}%'
        : '--';
    final pumpOn = data?.pumpStatus ?? false;
    final isAuto = (data?.mode ?? 'auto') == 'auto';

    return Column(
      children: [
        // AI Info Card
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
            border: Border.all(color: AppColors.purpleBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with gradient
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.purple.withValues(alpha: 0.06),
                      AppColors.primary.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.psychology_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Prediksi AI (KNN)',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.purpleSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Akurasi $accuracy',
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Algorithm + Confidence row
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBlock(
                            label: 'Algoritma',
                            value: 'K-Nearest Neighbor',
                            icon: Icons.memory_rounded,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.border,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        _InfoBlock(
                          label: 'Kepercayaan',
                          value: confidence,
                          icon: Icons.speed_rounded,
                          color: AppColors.purple,
                          crossAxisAlignment: CrossAxisAlignment.end,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Pump status bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pumpOn ? AppColors.primary : AppColors.textLight,
                              boxShadow: pumpOn
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.5),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Pompa: ${pumpOn ? "AKTIF" : "MATI"}',
                            style: TextStyle(
                              color: pumpOn
                                  ? AppColors.primary
                                  : AppColors.textMedium,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAuto
                                  ? AppColors.purpleSurface
                                  : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isAuto
                                      ? Icons.auto_awesome_rounded
                                      : Icons.touch_app_rounded,
                                  color: isAuto
                                      ? AppColors.purple
                                      : AppColors.warning,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isAuto ? 'Mode AI' : 'Manual',
                                  style: TextStyle(
                                    color: isAuto
                                        ? AppColors.purple
                                        : AppColors.warning,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Action card based on mode
        isAuto ? _buildAutoInfo() : _buildManualButton(pumpOn),
      ],
    );
  }

  Widget _buildAutoInfo() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.purpleBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Mengambil Alih',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'KNN memantau sensor & memutuskan\npenyiraman secara otomatis.',
                  style: TextStyle(
                    color: AppColors.textMedium,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualButton(bool pumpOn) {
    return GestureDetector(
      onTap: onWaterNow,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: pumpOn
                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          boxShadow: [
            BoxShadow(
              color: (pumpOn ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              pumpOn
                  ? Icons.stop_circle_rounded
                  : Icons.water_drop_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              pumpOn ? 'MATIKAN POMPA' : 'SIRAM SEKARANG',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final CrossAxisAlignment crossAxisAlignment;

  const _InfoBlock({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textDark;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textLight),
            const SizedBox(width: 4),
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: c,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
