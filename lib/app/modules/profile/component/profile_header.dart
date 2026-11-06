import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../data/models/app_user.dart';

/// ຫົວໜ້າໂປຣໄຟລ໌: ຮູບ, ຊື່, ອີແມວ, ບົດບາດ ແລະ ນາມສະກຸນຄອບຄົວ
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
    required this.familySurname,
    required this.roleDescription,
  });

  final AppUser? user;
  final String familySurname;
  final String roleDescription;

  @override
  Widget build(BuildContext context) {
    final contact = user?.email ?? user?.phone ?? '';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 26.h),
          child: Column(
            children: [
              AppAvatar(
                imageUrl: user?.avatarUrl,
                name: user?.displayName ?? '',
                size: 96,
                isAdmin: user?.isAdmin ?? false,
                borderRadius: BorderRadius.circular(30.r),
              ),
              SizedBox(height: 14.h),
              Text(
                user?.displayName ?? AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (contact.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  contact,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: [
                  if (user != null) _RoleChip(isAdmin: user!.isAdmin),
                  _HeaderChip(label: familySurname.isEmpty ? '-' : familySurname),
                ],
              ),
              if (roleDescription.isNotEmpty) ...[
                SizedBox(height: 14.h),
                Text(
                  roleDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final color = isAdmin ? AppColors.accent : Colors.white;

    return _HeaderChip(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.verified_rounded : Icons.person_rounded,
            size: 12.sp,
            color: color,
          ),
          SizedBox(width: 5.w),
          Text(
            isAdmin ? 'ADMIN' : 'MEMBER',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({this.child, this.label});

  final Widget? child;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child:
          child ??
          Text(
            label ?? '',
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
    );
  }
}
