import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final RxDouble progress = 0.0.obs;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // ຈຳລອງການໂຫຼດເພື່ອຄວາມນຽນສະງົບຂອງອະນິເມຊັນ
      for (var i = 1; i <= 10; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 210));
        progress.value = i / 10;
      }

      // ຖ້າ Firebase/AuthService init ລ้มລ้ม (ເຊັ່ນ google-services.json ບໍ່ຖືກຕ້ອງ
      // ຫຼື ບໍ່ຖືກ include ເຂົ້າໃນ build release) → ໃຫ້ໄປໜ້າ login ພ້ອມຂໍ້ຄວາມແຈ້ງ
      if (!Get.isRegistered<AuthService>()) {
        UiHelpers.error(
          'ບໍ່ສາມາດເຊື່ອມຕໍ່ Firebase ໄດ້ — ກວດເບິ່ງ google-services.json '
          'ແລະ applicationId ໃນ build.gradle.kts',
        );
        Get.offAllNamed(Routes.AUTH);
        return;
      }

      final auth = AuthService.to;

      // ຖ້າ Firestore ຍັງດຶງໂປຣໄຟລ໌ບໍ່ທັນມາ (ເຊັ່ນ: ເຄື່ອງຊ້າ/ອອບລາຍ)
      // ໃຫ້ລໍຖ້າ userProfile ຈາກ FirebaseAuth ໄດ້ເລັກນ້ອຍ ກ່ອນຕັດສິນໃຈ
      if (!auth.isSignedIn && FirebaseAuth.instance.currentUser != null) {
        unawaited(auth.fetchFresh());
        await Future<void>.delayed(const Duration(milliseconds: 800));
      }

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
    } catch (e, s) {
      // ຫ້າມໃຫ້ splash ຢູ່ນິ່ງ/ໜ້າດຳເດັດຂາດ — error ໃດໆ ຕ້ອງໄປໜ້າ login
      debugPrint('SplashController._bootstrap error: $e\n$s');
      Get.offAllNamed(Routes.AUTH);
    }
  }
}
