import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../controllers/account_form_controller.dart';

/// ສະວິດເປີດ / ປິດ ການໃຊ້ງານບັນຊີ (ສະເພາະຕອນແກ້ໄຂ)
class AccountActiveSwitch extends StatelessWidget {
  const AccountActiveSwitch({super.key, required this.controller});

  final AccountFormController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeThumbColor: AppColors.primary,
            value: controller.isActive.value,
            onChanged: (value) => controller.isActive.value = value,
            title: Text(
              'ເປີດໃຊ້ງານບັນຊີ',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'ຖ້າປິດ ສະມາຊິກຈະບໍ່ສາມາດເຂົ້າລະບົບໄດ້',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
