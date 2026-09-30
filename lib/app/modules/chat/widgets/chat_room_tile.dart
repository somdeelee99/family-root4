import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/chat_room.dart';

/// ລາຍການຫ້ອງສົນທະນາ
class ChatRoomTile extends StatelessWidget {
  const ChatRoomTile({
    super.key,
    required this.room,
    required this.other,
    required this.myUid,
    required this.onTap,
    this.onLongPress,
  });

  final ChatRoom room;
  final AppUser? other;
  final String myUid;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final unread = room.unreadFor(myUid);
    final name = other?.displayName ?? 'ສະມາຊິກ';
    final isMine = room.lastSenderId == myUid;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: unread > 0 ? AppColors.primary.withValues(alpha: 0.35) : AppColors.divider),
          ),
          child: Row(
            children: [
              AppAvatar(
                imageUrl: other?.avatarUrl,
                name: name,
                size: 52,
                isAdmin: other?.isAdmin ?? false,
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
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (other != null) ...[
                          SizedBox(width: 6.w),
                          RoleBadge(role: other!.role, compact: true),
                        ],
                        const Spacer(),
                        Text(
                          AppDateUtils.chatStamp(room.lastMessageAt),
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: unread > 0 ? AppColors.primary : AppColors.textHint,
                            fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        if (isMine)
                          Text(
                            'ທ່ານ: ',
                            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                          ),
                        Expanded(
                          child: Text(
                            room.lastMessage.isEmpty ? 'ເລີ່ມການສົນທະນາໃໝ່' : room.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (unread > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                            constraints: BoxConstraints(minWidth: 20.w),
                            decoration: BoxDecoration(
                              color: AppColors.danger,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ລາຍການສະມາຊິກສຳລັບເລີ່ມການສົນທະນາໃໝ່
class StartChatTile extends StatelessWidget {
  const StartChatTile({
    super.key,
    required this.user,
    required this.onChat,
    required this.onTapDetail,
  });

  final AppUser user;
  final VoidCallback onChat;
  final VoidCallback onTapDetail;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapDetail,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(11.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              AppAvatar(
                imageUrl: user.avatarUrl,
                name: user.displayName,
                size: 44,
                isAdmin: user.isAdmin,
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      user.phone?.isNotEmpty == true ? user.phone! : (user.email ?? ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onChat,
                tooltip: 'ແຊັດຫາ',
                icon: Container(
                  padding: EdgeInsets.all(9.w),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chat_bubble_rounded, size: 17.sp, color: AppColors.primary),
                ),
              ),
              IconButton(
                onPressed: onTapDetail,
                tooltip: 'ລາຍລະອຽດ',
                icon: Icon(Icons.info_outline_rounded, size: 19.sp, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
