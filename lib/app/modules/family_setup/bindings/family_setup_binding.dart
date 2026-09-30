import 'package:get/get.dart';

import '../controllers/family_setup_controller.dart';

class FamilySetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FamilySetupController>(() => FamilySetupController());
  }
}
