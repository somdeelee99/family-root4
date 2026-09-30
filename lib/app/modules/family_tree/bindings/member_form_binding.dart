import 'package:get/get.dart';

import '../controllers/member_form_controller.dart';

class MemberFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemberFormController>(() => MemberFormController());
  }
}
