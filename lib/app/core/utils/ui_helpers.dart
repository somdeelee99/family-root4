import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class UiHelpers {
  UiHelpers._();

  static void success(String message) =>
      _snack(message, AppColors.success, Icons.check_circle_outline);

  static void error(String message) =>
      _snack(message, AppColors.danger, Icons.error_outline);

  static void info(String message) =>
      _snack(message, AppColors.primary, Icons.info_outline);

  static void warning(String message) =>
      _snack(message, AppColors.warning, Icons.warning_amber_rounded);

  static void _snack(String message, Color color, IconData icon) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(14),
      borderRadius: 16,
      icon: Icon(icon, color: Colors.white),
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      duration: const Duration(seconds: 3),
    );
  }

  static void loading({String message = 'ກຳລັງດຳເນີນການ...'}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              boxShadow: AppSizes.cardShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(strokeWidth: 2.6),
                const SizedBox(height: 16),
                Text(message,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  static Future<bool> confirm({
    required String title,
    String? message,
    String confirmText = 'ຢືນຢັນ',
    String cancelText = 'ຍົກເລີກ',
    bool isDanger = false,
    IconData? icon,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        icon: icon != null
            ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isDanger ? AppColors.danger : AppColors.primary)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: isDanger ? AppColors.danger : AppColors.primary),
              )
            : null,
        title: Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: message == null
            ? null
            : Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Get.back(result: false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(110, 46),
              side: const BorderSide(color: AppColors.divider),
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(110, 46),
              backgroundColor: isDanger ? AppColors.danger : AppColors.primary,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// ສະແດງຂໍ້ຜິດພາດຈາກ Firebase ແບບອ່ານງ່າຍ
  static String mapError(Object error) {
    final text = error.toString();
    if (text.contains('user-not-found') ||
        text.contains('wrong-password') ||
        text.contains('invalid-credential')) {
      return 'ອີແມວ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ';
    }
    if (text.contains('email-already-in-use')) return 'ອີແມວນີ້ຖືກໃຊ້ແລ້ວ';
    if (text.contains('network-request-failed'))
      return 'ການເຊື່ອມຕໍ່ບໍ່ສະຖຽນ ກະລຸນາລອງໃໝ່';
    if (text.contains('permission-denied'))
      return 'ທ່ານບໍ່ມີສິດໃນການດຳເນີນການນີ້';
    if (text.contains('weak-password')) return 'ລະຫັດຜ່ານອ່ອນເກີນໄປ';
    if (text.contains('unavailable')) return 'ບໍ່ສາມາດເຊື່ອມຕໍ່ເຊີບເວີໄດ້';
    return 'ເກີດຂໍ້ຜິດພາດ: $text';
  }
}
