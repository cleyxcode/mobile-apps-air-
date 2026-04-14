import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../constants/app_colors.dart';
import '../../../models/sensor_data.dart';

class HumidityChartCard extends StatelessWidget {
  final List<HistoryRecord> history;

  const HumidityChartCard({super.key, required this.history});

  int get _chartPointCount {
    if (history.isEmpty) return 0;
    return history.length > 20 ? 20 : history.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.show_chart_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tren Kelembaban',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      history.isEmpty
                          ? 'Data dari server'
                          : '$_chartPointCount titik terakhir · ${history.length} rekaman',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Legend
              _LegendItem(color: AppColors.primary, label: 'Tanah'),
              const SizedBox(width: 12),
              _LegendItem(color: AppColors.info, label: 'Udara'),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          history.isEmpty
              ? _buildEmptyChart()
              : SizedBox(height: 160, child: _buildChart()),
          const SizedBox(height: 12),
          // Ideal range indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Batas ideal: 40 – 70%',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded, color: AppColors.textLight, size: 36),
            SizedBox(height: 10),
            Text(
              'Menunggu data sensor...',
              style: TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final records =
        history.length > 20 ? history.sublist(history.length - 20) : history;

    final soilSpots = <FlSpot>[];
    final airSpots = <FlSpot>[];

    for (int i = 0; i < records.length; i++) {
      soilSpots.add(FlSpot(i.toDouble(), records[i].soilMoisture));
      airSpots.add(FlSpot(i.toDouble(), records[i].airHumidity));
    }

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (_) => const Color(0xFF1E293B),
            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
              return lineBarsSpot.map((spot) {
                final label = spot.barIndex == 0 ? 'Tanah' : 'Udara';
                return LineTooltipItem(
                  '$label: ${spot.y.toStringAsFixed(0)}%',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              interval: 25,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: 100,
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 40,
              color: AppColors.warning.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [6, 4],
            ),
            HorizontalLine(
              y: 70,
              color: AppColors.warning.withValues(alpha: 0.4),
              strokeWidth: 1,
              dashArray: [6, 4],
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: soilSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          LineChartBarData(
            spots: airSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.info,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            dashArray: [6, 3],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
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
    );
  }
}
