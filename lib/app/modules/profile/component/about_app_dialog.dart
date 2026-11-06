import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

/// ສະແດງຂໍ້ມູນກ່ຽວກັບແອັບ ແລະ ເວີຊັນປັດຈຸບັນ
Future<void> showAboutAppDialog() async {
  final info = await PackageInfo.fromPlatform();

  Get.dialog(
    AlertDialog(
      icon: Icon(Icons.park_rounded, color: AppColors.primary, size: 40),
      title: const Text(AppStrings.appName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.appTagline,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          Text(
            '${AppStrings.version} ${info.version} (${info.buildNumber})',
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'ແອັບຈັດການຜັງໄມ້ຄອບຄົວສຳລັບຄອບຄົວລາວ\n'
            'Admin ຈັດການຂໍ້ມູນ • Member ເຂົ້າຮ່ວມ ແລະ ສື່ສານ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(onPressed: () => Get.back(), child: const Text('ຕົກລົງ')),
      ],
    ),
  );
}
