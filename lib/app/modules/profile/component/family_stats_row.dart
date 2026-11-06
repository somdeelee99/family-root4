import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

/// ສະຖິຕິຫຍໍ້ຂອງຄອບຄົວ: ຈຳນວນສະມາຊິກ, ລຸ້ນ ແລະ ຊາຍ/ຍິງ
class FamilyStatsRow extends StatelessWidget {
  const FamilyStatsRow({
    super.key,
    required this.totalMembers,
    required this.generationCount,
    required this.maleCount,
    required this.femaleCount,
  });

  final int totalMembers;
  final int generationCount;
  final int maleCount;
  final int femaleCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _stat('ສະມາຊິກ', '$totalMembers', AppColors.primary),
        SizedBox(width: 10.w),
        _stat('ລຸ້ນ', '$generationCount', AppColors.info),
        SizedBox(width: 10.w),
        _stat('ຊາຍ/ຍິງ', '$maleCount/$femaleCount', AppColors.accent),
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
