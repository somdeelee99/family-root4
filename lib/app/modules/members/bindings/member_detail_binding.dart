import 'package:get/get.dart';

import '../controllers/member_detail_controller.dart';

class MemberDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberDetailController>(() => MemberDetailController());
  }
}
