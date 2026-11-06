import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/family_member.dart';

/// ຫົວບັດຂໍ້ມູນສະມາຊິກ (ຮູບ, ຊື່, ບົດບາດ ແລະ ລຸ້ນ)
class MemberProfileHeader extends StatelessWidget {
  const MemberProfileHeader({super.key, this.account, this.person});

  final AppUser? account;
  final FamilyMember? person;

  @override
  Widget build(BuildContext context) {
    final name = account?.displayName ?? person?.fullName ?? '';
    final avatar = account?.avatarUrl ?? person?.avatarUrl;
    final subtitle =
        account?.email ?? (person != null ? person!.generationLabel : '');
    final gender = person?.gender ??
        (account?.gender == null
            ? null
            : Gender.fromString(account!.gender!));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl.r),
        boxShadow: AppSizes.cardShadow,
      ),
      child: Column(
        children: [
          AppAvatar(
            imageUrl: avatar,
            name: name,
            size: 92,
            gender: gender,
            status: person?.status,
            showStatusBadge: person != null,
            isAdmin: account?.isAdmin ?? false,
            borderRadius: BorderRadius.circular(28.r),
          ),
          SizedBox(height: 14.h),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            SizedBox(height: 5.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              if (account != null) RoleBadge(role: account!.role),
              if (person != null) GenderBadge(gender: person!.gender),
              if (person != null) StatusBadge(status: person!.status),
              if (person != null) _generationChip(person!.generationLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _generationChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
