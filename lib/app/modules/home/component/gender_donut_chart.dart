import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/section_header.dart';
import '../controllers/home_controller.dart';

/// ກາຟວົງມົນສະແດງອັດຕາສ່ວນ ຊາຍ/ຍິງ
class GenderDonutChart extends GetView<HomeController> {
  const GenderDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.stats.value;
      final total = s.total;
      final sections = <PieChartSectionData>[];

      if (total > 0) {
        sections.addAll([
          PieChartSectionData(
            value: s.male.toDouble(),
            color: AppColors.male,
            radius: 22.w,
            showTitle: false,
          ),
          PieChartSectionData(
            value: s.female.toDouble(),
            color: AppColors.female,
            radius: 22.w,
            showTitle: false,
          ),
        ]);
        if (s.total - s.male - s.female > 0) {
          sections.add(
            PieChartSectionData(
              value: (s.total - s.male - s.female).toDouble(),
              color: AppColors.textHint,
              radius: 22.w,
              showTitle: false,
            ),
          );
        }
      } else {
        sections.add(
          PieChartSectionData(
            value: 1,
            color: AppColors.divider,
            radius: 22.w,
            showTitle: false,
          ),
        );
      }

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.divider),
          boxShadow: AppSizesShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'ອັດຕາສ່ວນ ຊາຍ - ຍິງ',
              icon: Icons.pie_chart_outline_rounded,
            ),
            Row(
              children: [
                SizedBox(
                  height: 116.h,
                  width: 116.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 34.w,
                          sectionsSpace: 3,
                          startDegreeOffset: -90,
                          borderData: FlBorderData(show: false),
                        ),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'ຄົນ',
                            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Column(
                    children: [
                      _legend(AppStrings.male, s.male, total, AppColors.male),
                      SizedBox(height: 10.h),
                      _legend(AppStrings.female, s.female, total, AppColors.female),
                      SizedBox(height: 10.h),
                      _legend(AppStrings.deceased, s.deceased, total, AppColors.deceased),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _legend(String label, int value, int total, Color color) {
    final percent = total == 0 ? 0 : (value / total * 100).round();
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3.r)),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ),
        Text(
          '$value ຄົນ',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        SizedBox(width: 6.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '$percent%',
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    );
  }
}

/// ເງົາມາດຕະຖານ
class AppSizesShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0F10513F), blurRadius: 18, offset: Offset(0, 8)),
  ];
}
