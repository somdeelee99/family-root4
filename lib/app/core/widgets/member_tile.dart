import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/family_member.dart';
import '../constants/app_colors.dart';
import '../utils/date_utils.dart';
import 'app_avatar.dart';
import 'role_badge.dart';

/// ລາຍການສະມາຊິກໃນຜັງໄມ້ຄອບຄົວ
class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.trailing,
    this.compact = false,
  });

  final FamilyMember member;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(compact ? 10.w : 12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              AppAvatar(
                imageUrl: member.avatarUrl,
                name: member.fullName,
                size: compact ? 42 : 50,
                gender: member.gender,
                status: member.status,
                showStatusBadge: true,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        decoration: member.isDeceased
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            member.generationLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        if (member.birthDate != null)
                          Text(
                            '${AppDateUtils.age(member.birthDate, deathDate: member.deathDate)} ປີ',
                            style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.textSecondary),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!compact) ...[
                SizedBox(width: 8.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GenderBadge(gender: member.gender),
                    SizedBox(height: 5.h),
                    StatusBadge(status: member.status),
                  ],
                ),
              ],
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
