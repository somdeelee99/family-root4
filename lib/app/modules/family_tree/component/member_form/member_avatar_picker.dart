import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../controllers/member_form_controller.dart';

/// ຮູບໂປຣໄຟລ໌ + ປຸ່ມເລືອກ/ປ່ຽນຮູບ
class MemberAvatarPicker extends GetView<MemberFormController> {
  const MemberAvatarPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: controller.chooseImageSource,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (controller.pickedImage.value != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: Image.file(
                        controller.pickedImage.value!,
                        width: 104.w,
                        height: 104.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    AppAvatar(
                      imageUrl: controller.avatarUrl.value,
                      name: controller.nameController.text.isEmpty
                          ? '?'
                          : controller.nameController.text,
                      size: 104,
                      gender: controller.gender.value,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  Positioned(
                    right: -4.w,
                    bottom: -4.h,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextButton.icon(
            onPressed: controller.chooseImageSource,
            icon: const Icon(Icons.image_outlined, size: 17),
            label: const Text(AppStrings.changePhoto),
          ),
        ],
      ),
    );
  }
}
