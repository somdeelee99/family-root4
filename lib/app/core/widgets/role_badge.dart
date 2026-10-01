import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/enums.dart';
import '../constants/app_colors.dart';

/// ປ້າຍສະແດງບົດບາດ (Admin / Member) ແລະ ສະຖານະ
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role, this.compact = false});

  final UserRole role;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.isAdmin;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.w : 10.w,
        vertical: compact ? 3.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: isAdmin ? AppColors.accentSoft : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: isAdmin
              ? AppColors.accent.withValues(alpha: 0.4)
              : AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.verified_rounded : Icons.person_rounded,
            size: compact ? 11.sp : 13.sp,
            color: isAdmin ? AppColors.accent : AppColors.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            isAdmin ? 'Admin' : 'Member',
            style: TextStyle(
              fontSize: compact ? 10.sp : 11.5.sp,
              fontWeight: FontWeight.w700,
              color: isAdmin ? const Color(0xFF9A6A11) : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// ປ້າຍສະຖານະສະມາຊິກ
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final MemberStatus status;

  Color get _color {
    switch (status) {
      case MemberStatus.alive:
        return AppColors.alive;
      case MemberStatus.deceased:
        return AppColors.deceased;
      case MemberStatus.divorced:
        return AppColors.divorced;
    }
  }

  IconData get _icon {
    switch (status) {
      case MemberStatus.alive:
        return Icons.favorite_rounded;
      case MemberStatus.deceased:
        return Icons.spa_rounded;
      case MemberStatus.divorced:
        return Icons.heart_broken_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11.sp, color: _color),
          SizedBox(width: 4.w),
          Text(
            status.shortLabel,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ຫຸ້ມປ້າຍເພດ
class GenderBadge extends StatelessWidget {
  const GenderBadge({super.key, required this.gender});

  final Gender gender;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forGender(gender.value);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            gender == Gender.female ? Icons.female_rounded : Icons.male_rounded,
            size: 12.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            gender.label,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
