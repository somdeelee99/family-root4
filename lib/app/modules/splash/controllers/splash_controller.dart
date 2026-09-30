import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // ຈຳລອງການໂຫຼດເພື່ອຄວາມນຽນສະງົບຂອງອະນິເມຊັນ
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 210));
      progress.value = i / 10;
    }

    final auth = AuthService.to;
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!auth.isSignedIn) {
      Get.offAllNamed(Routes.AUTH);
      return;
    }

    if (auth.hasFamily) {
      Get.offAllNamed(Routes.SHELL);
    } else if (auth.isAdmin) {
      Get.offAllNamed(Routes.FAMILY_SETUP);
    } else {
      // member ທີ່ຍັງບໍ່ຖືກຜູກກັບຄອບຄົວ
      Get.offAllNamed(Routes.AUTH);
    }
  }
}
