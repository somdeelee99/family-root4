import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../data/models/chat_message.dart';

/// ຟອງຂໍ້ຄວາມໃນການສົນທະນາ
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showAvatar,
  });

  final ChatMessage message;
  final bool isMine;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: 0.72.sw),
      padding: message.type == 'image'
          ? const EdgeInsets.all(4)
          : EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isMine ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMine ? 16 : 4),
          bottomRight: Radius.circular(isMine ? 4 : 16),
        ),
        border: isMine ? null : Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: message.type == 'image' && message.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: GestureDetector(
                onTap: () => _openImage(context, message.imageUrl!),
                child: CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  width: 200.w,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 200.w,
                    height: 150.h,
                    color: AppColors.surfaceAlt,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 200.w,
                    height: 120.h,
                    color: AppColors.surfaceAlt,
                    child: Icon(Icons.broken_image_rounded, color: AppColors.textHint, size: 30.sp),
                  ),
                ),
              ),
            )
          : Text(
              message.text,
              style: TextStyle(
                fontSize: 13.5.sp,
                color: isMine ? Colors.white : AppColors.textPrimary,
                height: 1.35,
              ),
            ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            SizedBox(
              width: 34.w,
              child: showAvatar
                  ? AppAvatar(
                      imageUrl: message.senderAvatar,
                      name: message.senderName,
                      size: 30,
                    )
                  : null,
            ),
            SizedBox(width: 6.w),
          ],
          Column(
            crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              bubble,
              Padding(
                padding: EdgeInsets.only(top: 2.h, left: 4.w, right: 4.w),
                child: Text(
                  AppDateUtils.timeOnly.format(message.createdAt ?? DateTime.now()),
                  style: TextStyle(fontSize: 9.5.sp, color: AppColors.textHint),
                ),
              ),
            ],
          ),
          if (isMine) SizedBox(width: 6.w),
        ],
      ),
    );
  }

  void _openImage(BuildContext context, String url) {
    PhotoViewer.open(context, url);
  }
}

/// ຕົວຊ່ວຍເປີດຮູບແບບເຕັມຈໍ (photo_view)
class PhotoViewer {
  static void open(BuildContext context, String url) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, __) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoView(
            imageProvider: CachedNetworkImageProvider(url),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.5,
          ),
        ),
      ),
    );
  }
}

/// ຕົວແບ່ງວັນທີໃນການສົນທະນາ
class ChatDateDivider extends StatelessWidget {
  const ChatDateDivider({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text(
                AppDateUtils.displayDate.format(date),
                style: TextStyle(fontSize: 10.5.sp, color: AppColors.textSecondary),
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.divider)),
        ],
      ),
    );
  }
}
