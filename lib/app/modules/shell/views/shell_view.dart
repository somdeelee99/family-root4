import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/connectivity_service.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../chat/views/chat_view.dart';
import '../../family_tree/views/family_tree_view.dart';
import '../../home/views/home_view.dart';
import '../../members/views/members_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/shell_controller.dart';
import '../widgets/app_bottom_nav.dart';

/// ຖານຫຼັກຂອງແອັບ - ບັນຈຸ 5 ໜ້າຫຼັກດ້ວຍ UI ຮ່ວມກັນ
/// ການເຫັນຂໍ້ມູ້ອຍູ່ໃນແຕ່ລະໜ້າແຍກຕາມ role (admin / member)
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Scaffold(
      body: Obx(
        () => Column(
          children: [
            // ແຈ້ງເຕືອນເມື່ອອອບລາຍ
            Obx(
              () => ConnectivityService.to.isOnline.value
                  ? const SizedBox.shrink()
                  : Container(
                      width: double.infinity,
                      color: AppColors.warning,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 15),
                          SizedBox(width: 8),
                          Text(
                            'ທ່ານກຳລັງໃຊ້ງານແບບອອບລາຍ - ຂໍ້ມູນຈະຊິ້ງເມື່ອມີເນັດ',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
            ),
            Expanded(
              child: Obx(
                () => IndexedStack(
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
