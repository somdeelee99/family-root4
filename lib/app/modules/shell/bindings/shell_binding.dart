import 'package:get/get.dart';

import '../../chat/controllers/chat_controller.dart';
import '../../family_tree/controllers/family_tree_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../members/controllers/members_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/shell_controller.dart';

/// ຜູກ controller ຂອງທັງ 5 ໜ້າກັບ shell ເພື່ອໃຫ້ຂໍ້ມູ້ອຍູ່ຕະຫຼອດອາຍຸຂອງແຖບນຳທາງ
class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ShellController>(ShellController());
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<FamilyTreeController>(() => FamilyTreeController(), fenix: true);
    Get.lazyPut<MembersController>(() => MembersController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}
