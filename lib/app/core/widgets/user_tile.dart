import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/app_user.dart';
import '../../data/models/enums.dart';
import '../constants/app_colors.dart';
import '../utils/date_utils.dart';
import 'app_avatar.dart';
import 'role_badge.dart';

/// ລາຍການບັນຊີສະມາຊິກ (ມີບັນຊີເຂົ້າລະບົບ)
class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.user,
    this.onTap,
    this.onChat,
    this.trailing,
  });

  final AppUser user;
  final VoidCallback? onTap;
  final VoidCallback? onChat;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              AppAvatar(
                imageUrl: user.avatarUrl,
                name: user.displayName,
                size: 52,
                gender: user.gender == null
                    ? null
                    : Gender.fromString(user.gender),
                isAdmin: user.isAdmin,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName.isEmpty
                                ? '(ບໍ່ມີຊື່)'
                                : user.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        RoleBadge(role: user.role, compact: true),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      user.phone?.isNotEmpty == true
                          ? user.phone!
                          : (user.email ?? '-'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (user.lastSeenAt != null) ...[
                      SizedBox(height: 3.h),
                      Text(
                        'ເຂົ້າໃຊ້ຫຼ້າສຸດ ${AppDateUtils.relative(user.lastSeenAt)}',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onChat != null)
                IconButton(
                  tooltip: 'ແຊັດຫາ',
                  onPressed: onChat,
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 17.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
