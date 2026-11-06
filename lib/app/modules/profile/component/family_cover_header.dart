import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/models/family.dart';

/// ປົກຄອບຄົວ: ສະແດງຮູບປົກ, ຊື່ຄອບຄົວ ແລະ ປຸ່ມປ່ຽນຮູບ
class FamilyCoverHeader extends StatelessWidget {
  const FamilyCoverHeader({
    super.key,
    required this.family,
    required this.isEditing,
    required this.pickedCover,
    required this.onPickCover,
  });

  final Family family;
  final bool isEditing;
  final File? pickedCover;
  final VoidCallback onPickCover;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
        image: _coverDecoration(),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.park_rounded,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 34.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  family.displayName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ນາມສະກຸນ ${family.surname}',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          if (isEditing)
            Positioned(
              right: 12.w,
              bottom: 12.h,
              child: _ChangeCoverButton(onTap: onPickCover),
            ),
        ],
      ),
    );
  }

  DecorationImage? _coverDecoration() {
    final picked = pickedCover;
    final coverUrl = family.coverUrl;

    if (picked != null) {
      return DecorationImage(
        image: FileImage(picked),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.35),
          BlendMode.darken,
        ),
      );
    }
    if (coverUrl != null && coverUrl.isNotEmpty) {
      return DecorationImage(
        image: CachedNetworkImageProvider(coverUrl),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.4),
          BlendMode.darken,
        ),
      );
    }
    return null;
  }
}

class _ChangeCoverButton extends StatelessWidget {
  const _ChangeCoverButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          children: [
            Icon(
              Icons.image_outlined,
              size: 14.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 5.w),
            Text(
              'ປ່ຽນຮູບປົກ',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
