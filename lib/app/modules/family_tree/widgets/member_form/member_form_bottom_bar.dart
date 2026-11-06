import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../controllers/member_form_controller.dart';

/// ແຖບປຸ່ມ ຍົກເລີກ / ບັນທຶກ ຢູ່ລຸ່ມຟອມ
class MemberFormBottomBar extends GetView<MemberFormController> {
  const MemberFormBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.isLoading.value
          ? const SizedBox.shrink()
          : Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.fromHeight(52.h),
                        ),
                        child: const Text(AppStrings.cancel),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: controller.isSaving.value
                            ? null
                            : controller.save,
                        icon: controller.isSaving.value
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 20),
                        label: Text(
                          controller.isEdit
                              ? AppStrings.update
                              : AppStrings.save,
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: Size.fromHeight(52.h),
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
