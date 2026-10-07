import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/role_badge.dart';
import '../../../routes/app_routes.dart';
import '../controllers/chat_room_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';

/// ຫ້ອງສົນທະນາ 1:1 (ເຫັນປະຫວັດທັງໝົດ ແລະ ບໍ່ສາມາດລຶບຂໍ້ຄວາມໄດ້)
class ChatRoomView extends GetView<ChatRoomController> {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(
          () => InkWell(
            onTap: () {
              final user = controller.otherUser.value;
              if (user != null) {
                Get.toNamed(
                  Routes.MEMBER_DETAIL,
                  arguments: {'uid': user.uid, 'type': 'account'},
                );
              }
            },
            child: Row(
              children: [
                AppAvatar(
                  imageUrl: controller.otherUser.value?.avatarUrl,
                  name: controller.otherUser.value?.displayName ?? 'ສະມາຊິກ',
                  size: 40,
                  isAdmin: controller.otherUser.value?.isAdmin ?? false,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.otherUser.value?.displayName ?? 'ສະມາຊິກ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'ກົດເພື່ອເບິ່ງລາຍລະອຽດ',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.otherUser.value != null)
                  RoleBadge(
                    role: controller.otherUser.value!.role,
                    compact: true,
                  ),
                SizedBox(width: 10.w),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ແຈ້ງເຕືອນວ່າບໍ່ສາມາດລຶບຂໍ້ຄວາມໄດ້
          Container(
            width: double.infinity,
            color: AppColors.accentSoft,
            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13.sp,
                  color: const Color(0xFF9A6A11),
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    'ປະຫວັດການສົນທະນາຖືກເກັບຮັກສາໄວ້ ແລະ ບໍ່ສາມາດລຶບໄດ້',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: const Color(0xFF9A6A11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return const EmptyState(
                  title: 'ຍັງບໍ່ມີຂໍ້ຄວາມ',
                  description: 'ເລີ່ມສົນທະນາໂດຍການພິມຂໍ້ຄວາມທຳອິດ',
                  icon: Icons.chat_bubble_outline_rounded,
                );
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final previous = index > 0
                      ? controller.messages[index - 1]
                      : null;
                  final isMine = message.senderId == controller.myUid;

                  final showDivider =
                      previous == null ||
                      previous.createdAt == null ||
                      message.createdAt == null ||
                      !_sameDay(previous.createdAt!, message.createdAt!);
                  final showAvatar =
                      previous == null ||
                      previous.senderId != message.senderId ||
                      showDivider;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDivider && message.createdAt != null)
                        ChatDateDivider(date: message.createdAt!),
                      MessageBubble(
                        message: message,
                        isMine: isMine,
                        showAvatar: showAvatar,
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          const ChatInputBar(),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
