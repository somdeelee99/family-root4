import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/section_header.dart';
import '../controllers/home_controller.dart';

/// ກາຟແທ່ງສະແດງຈຳນວນສະມາຊິກໃນແຕ່ລະລຸ້ນ
class GenerationBarChart extends GetView<HomeController> {
  const GenerationBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.generationChart;
      final maxValue = data.isEmpty
          ? 4.0
          : (data.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 1).toDouble();

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(color: Color(0x0F10513F), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: AppStrings.generationChart,
              icon: Icons.bar_chart_rounded,
            ),
            SizedBox(
              height: 168.h,
              child: data.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.noData,
                        style: TextStyle(fontSize: 12.5.sp, color: AppColors.textHint),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        maxY: maxValue,
                        alignment: BarChartAlignment.spaceAround,
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxValue > 4 ? (maxValue / 4).ceilToDouble() : 1,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: AppColors.divider,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: EdgeInsets.only(top: 6.h),
                                child: Text(
                                  'ລຸ້ນ ${value.toInt()}',
                                  style: TextStyle(
                                    fontSize: 10.5.sp,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => AppColors.primary,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                              '${rod.toY.toInt()} ຄົນ',
                              TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        barGroups: [
                          for (final entry in data)
                            BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  width: 20.w,
                                  borderRadius: BorderRadius.circular(8.r),
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primaryLight, AppColors.primary],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}
