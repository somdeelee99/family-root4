import 'package:get/get.dart';

import '../controllers/family_tree_controller.dart';

class FamilyTreeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FamilyTreeController>(() => FamilyTreeController());
  }
}
