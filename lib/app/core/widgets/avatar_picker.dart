import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/enums.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'app_avatar.dart';

/// ຕົວເລືອກຮູບໂປຣໄຟລ໌: ສະແດງຮູບທີ່ເລືອກ ຫຼື ຮູບປັດຈຸບັນ
/// ພ້ອມປຸ່ມກ້ອງຖ່າຍຮູບ ແລະ ຂໍ້ຄວາມ "ປ່ຽນຮູບພາບ".
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.onPick,
    this.localImage,
    this.imageUrl,
    this.name = '',
    this.size = 104,
    this.gender,
    this.isAdmin = false,
    this.showChangeLabel = true,
    this.changeLabel = AppStrings.changePhoto,
  });

  final VoidCallback onPick;
  final File? localImage;
  final String? imageUrl;
  final String name;
  final double size;
  final Gender? gender;
  final bool isAdmin;
  final bool showChangeLabel;
  final String changeLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: onPick,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (localImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: Image.file(
                      localImage!,
                      width: size.w,
                      height: size.w,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  AppAvatar(
                    imageUrl: imageUrl,
                    name: name.isEmpty ? '?' : name,
                    size: size,
                    gender: gender,
                    isAdmin: isAdmin,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                Positioned(
                  right: -3.w,
                  bottom: -3.h,
                  child: Container(
                    padding: EdgeInsets.all(9.w),
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
          if (showChangeLabel) ...[
            SizedBox(height: 6.h),
            TextButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.image_outlined, size: 17),
              label: Text(changeLabel),
            ),
          ],
        ],
      ),
    );
  }
}
