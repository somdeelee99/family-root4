import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/section_header.dart';
import '../../../routes/app_routes.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_room_tile.dart';

/// ໜ້າສົນທະນາ - ທັງ admin ແລະ member ໃຊ້ UI ດຽວກັນ
/// ເຫັນລາຍລະອຽດຂອງສະມາຊິກຄົນອື່ນທັງໝົດ (ບໍ່ລວມຕົນເອງ), ກົດແຊັດ ແລະ ເຫັນປະຫວັດໄດ້
class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 90.h),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ---------- ຫ້ອງສົນທະນາ ----------
                    if (controller.filteredRooms.isNotEmpty) ...[
                      SectionHeader(
                        title: AppStrings.chatList,
                        icon: Icons.forum_outlined,
                        subtitle: '${controller.rooms.length} ການສົນທະນາ',
                      ),
                      for (var i = 0; i < controller.filteredRooms.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: ChatRoomTile(
                            room: controller.filteredRooms[i],
                            other: controller.userOf(controller.filteredRooms[i].otherParty(controller.myUid)),
                            myUid: controller.myUid,
                            onTap: () => Get.toNamed(
                              Routes.CHAT_ROOM,
                              arguments: {
                                'roomId': controller.filteredRooms[i].id,
                                'otherUid':
                                    controller.filteredRooms[i].otherParty(controller.myUid),
                              },
                            ),
                            onLongPress: () => controller.deleteRoom(controller.filteredRooms[i]),
                          ),
                        )
                            .animate(delay: (i * 50).ms)
                            .fadeIn(duration: 320.ms)
                            .slideX(begin: 0.05, end: 0),
                      SizedBox(height: 20.h),
                    ],

                    // ---------- ເລີ່ມສົນທະນາໃໝ່ ----------
                    SectionHeader(
                      title: AppStrings.allMembers,
                      icon: Icons.person_search_rounded,
                      subtitle: 'ເລືອກສະມາຊິກ ເພື່ອເລີ່ມສົນທະນາ',
                    ),
                    if (controller.others.isEmpty)
                      const EmptyState(
                        title: AppStrings.noConversation,
                        description: AppStrings.noConversationDesc,
                        icon: Icons.forum_outlined,
                        compact: true,
                      )
                    else
                      for (final user in controller.others)
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: StartChatTile(
                            user: user,
                            onChat: () => controller.openRoomWith(user),
                            onTapDetail: () => controller.openDetail(user),
                          ),
                        ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.forum_rounded, size: 18.sp, color: Colors.white),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.chat,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'ສົນທະນາກັບສະມາຊິກໃນຄອບຄົວ',
                      style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller.searchController,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: 'ຄົ້ນຫາການສົນທະນາ ຫຼື ສະມາຊິກ...',
              isDense: true,
              prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
