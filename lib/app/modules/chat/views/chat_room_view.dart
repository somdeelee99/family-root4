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
        actions: [
          Obx(() {
            // ອ່ານ observable ຢູ່ນີ້ ເພື່ອໃຫ້ Obx ຈົດຈຳ dependency
            // (ບໍ່ຄວນອ່ານພາຍໃນ itemBuilder ເພາະມັນເຮັດວຽກນອກ scope ຂອງ Obx)
            final isBlocked = controller.isOtherBlocked.value;
            return PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'ຕົວເລືອກ',
              onSelected: (value) {
                switch (value) {
                  case 'report':
                    _showReportDialog(context);
                  case 'block':
                    controller.blockOtherUser();
                  case 'unblock':
                    controller.unblockOtherUser();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'report',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.flag_outlined, size: 20),
                    title: Text(
                      'ລາຍງານຜູ້ໃຊ້',
                      style: TextStyle(fontSize: 13.5),
                    ),
                  ),
                ),
                if (isBlocked)
                  const PopupMenuItem(
                    value: 'unblock',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.lock_open_rounded, size: 20),
                      title: Text(
                        'ຍົກເລີກການບລັອກ',
                        style: TextStyle(fontSize: 13.5),
                      ),
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'block',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.block_rounded, size: 20),
                      title: Text(
                        'ບລັອກຜູ້ໃຊ້',
                        style: TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ແຈ້ງເຕືອນວ່າຜູ້ໃຊ້ນີ້ຖືກບລັອກ
          Obx(
            () => controller.isOtherBlocked.value
                ? Container(
                    width: double.infinity,
                    color: AppColors.danger.withValues(alpha: 0.08),
                    padding: EdgeInsets.symmetric(
                      vertical: 7.h,
                      horizontal: 16.w,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_rounded,
                          size: 13.sp,
                          color: AppColors.danger,
                        ),
                        SizedBox(width: 7.w),
                        Expanded(
                          child: Text(
                            'ທ່ານໄດ້ບລັອກຜູ້ໃຊ້ນີ້ - ຂໍ້ຄວາມຈະຖືກເຊື່ອງໄວ້',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
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
          Obx(
            () => controller.isOtherBlocked.value
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 16.w,
                    ),
                    color: Colors.white,
                    child: Text(
                      'ຍົກເລີກການບລັອກເພື່ອສົ່ງຂໍ້ຄວາມຫາຜູ້ນີ້',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : const ChatInputBar(),
          ),
        ],
      ),
    );
  }

  Future<void> _showReportDialog(BuildContext context) async {
    const reasons = <String>[
      'ຂໍ້ຄວາມຫຍາບຄາຍ / ບໍ່ເໝາະສົມ',
      'ການຂົ່ມເຫັງ ຫຼື ຂົ່ມຂູ່',
      'ສະແປມ / ຫຼອກລວງ',
      'ເນື້ອຫາຜູ້ໃຫຍ່',
      'ອື່ນໆ',
    ];
    var selected = reasons.first;
    final detailsController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text(
            'ລາຍງານຜູ້ໃຊ້',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...reasons.map(
                  (reason) => InkWell(
                    onTap: () => setState(() => selected = reason),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            selected == reason
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: selected == reason
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              reason,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: detailsController,
                  maxLines: 3,
                  maxLength: 500,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: const InputDecoration(
                    hintText: 'ລາຍລະອຽດເພີ່ມເຕີມ (ບໍ່ບັງຄັບ)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ຍົກເລີກ'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('ສົ່ງລາຍງານ'),
            ),
          ],
        ),
      ),
    );

    if (submitted == true) {
      await controller.reportOtherUser(
        selected,
        details: detailsController.text,
      );
    }
    detailsController.dispose();
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
