import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/chat_room_controller.dart';

/// ແຖບພິມຂໍ້ຄວາມ + emoji + ຮູບພາບ
class ChatInputBar extends GetView<ChatRoomController> {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: controller.toggleEmojiPicker,
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    size: 24.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                IconButton(
                  onPressed: () => controller.sendImage(),
                  icon: Icon(Icons.image_outlined,
                      size: 24.sp, color: AppColors.textSecondary),
                ),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(maxHeight: 120.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: controller.textController,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      style: TextStyle(fontSize: 14.sp),
                      onTap: () => controller.showEmojiPicker.value = false,
                      decoration: InputDecoration(
                        hintText: 'ພິມຂໍ້ຄວາມ...',
                        hintStyle: TextStyle(
                            fontSize: 13.5.sp, color: AppColors.textHint),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Obx(
                  () => GestureDetector(
                    onTap: controller.isSending.value
                        ? null
                        : controller.sendMessage,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: controller.isSending.value
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Icon(Icons.send_rounded,
                              size: 20.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => controller.showEmojiPicker.value
                ? SizedBox(
                    height: 260.h,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) =>
                          controller.onEmojiSelected(emoji.emoji),
                      config: Config(
                        height: 256.h,
                        // bgColor: Colors.white,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          emojiSizeMax: 24.sp,
                        ),
                        categoryViewConfig: CategoryViewConfig(
                          backgroundColor: Colors.white,
                          indicatorColor: AppColors.primary,
                          iconColor: AppColors.textHint,
                          iconColorSelected: AppColors.primary,
                        ),
                        skinToneConfig: const SkinToneConfig(enabled: false),
                        bottomActionBarConfig:
                            const BottomActionBarConfig(enabled: false),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
