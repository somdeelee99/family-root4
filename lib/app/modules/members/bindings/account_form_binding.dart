import 'package:get/get.dart';

import '../controllers/account_form_controller.dart';

class AccountFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountFormController>(() => AccountFormController());
  }
}
