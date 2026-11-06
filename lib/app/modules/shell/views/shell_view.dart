import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/connectivity_service.dart';
import '../../../core/widgets/lazy_indexed_stack.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_view.dart';
import '../../family_tree/views/family_tree_view.dart';
import '../../home/views/home_view.dart';
import '../../members/views/members_view.dart';
import '../../profile/views/profile_view.dart';
import '../component/app_bottom_nav.dart';
import '../component/offline_banner.dart';
import '../controllers/shell_controller.dart';

/// ຖານຫຼັກຂອງແອັບ - ບັນຈຸ 5 ໜ້າຫຼັກດ້ວຍ UI ຮ່ວມກັນ
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Scaffold(
      body: Column(
        children: [
          Obx(
            () => ConnectivityService.to.isOnline.value
                ? const SizedBox.shrink()
                : const OfflineBanner(),
          ),
          Expanded(
            child: Obx(
              () => LazyIndexedStack(
                index: controller.currentIndex.value,
                children: const [
                  HomeView(),
                  FamilyTreeView(),
                  MembersView(),
                  ChatView(),
                  ProfileView(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => StreamBuilder<int>(
          stream: chatController.totalUnreadStream(),
          initialData: 0,
          builder: (context, snapshot) => AppBottomNav(
            currentIndex: controller.currentIndex.value,
            unreadCount: snapshot.data ?? 0,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}
