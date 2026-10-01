import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// ຈັດກາດສະຖິຕິເປັນຕາຕະລາງ (ປົກກະຕິ 2 ຖັນ)
///
/// ຄວາມສູງຂອງແຕ່ລະແຖວມາຈາກເນື້ອໃນຂອງກາດ (ກາດທີ່ສູງທີ່ສຸດກຳນົດແຖວ)
/// ຈຶ່ງບໍ່ໃຊ້ `childAspectRatio` ຄົງທີ່ - ດັ່ງນັ້ນຈຶ່ງບໍ່ເກີດ overflow
/// ເມື່ອຂໍ້ຄວາມຍາວຂຶ້ນ ຫຼື ຜູ້ໃຊ້ເພີ່ມຂະໜາດຕົວອັກສອນ
class StatCardGrid extends StatelessWidget {
  const StatCardGrid({
    super.key,
    required this.cards,
    this.columns = 2,
    this.spacing = 12,
  });

  final List<Widget> cards;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var start = 0; start < cards.length; start += columns) ...[
          if (start > 0) SizedBox(height: spacing.h),
          // IntrinsicHeight ຈຳເປັນເພື່ອໃຫ້ຄວາມສູງຂອງແຖວຖືກກຳນົດຈາກເນື້ອໃນ
          // (Row ໃນ scroll view ມີຄວາມສູງບໍ່ຈຳກັດ ຈຶ່ງໃຊ້ stretch ໂດຍກົງບໍ່ໄດ້)
          IntrinsicHeight(
            child: Row(
              // stretch ເພື່ອໃຫ້ກາດໃນແຖວດຽວກັນສູງເທົ່າກັນ
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < columns; col++) ...[
                  if (col > 0) SizedBox(width: spacing.w),
                  Expanded(
                    child: start + col < cards.length
                        ? cards[start + col]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// ກາດສະຖິຕິ (ໜ້າຫຼັກ) ພ້ອມ animation ນັບເລກ
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.index = 0,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String? trend;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppSizes.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(icon, size: 18.sp, color: color),
                      ),
                      const Spacer(),
                      if (trend != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            trend!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: value.toDouble()),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) => Text(
                      val.toInt().toString(),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: AppColors.textSecondary,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(delay: (index * 70).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.18, end: 0, curve: Curves.easeOutCubic);
  }
}
