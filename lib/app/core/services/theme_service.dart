import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// ຈັດການໂໝດມືດ / ສະຫວ່າງ ແລະ ຈື່ຈຳການຕັ້ງຄ່າ
class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();

  static const _key = 'dark_mode';

  final RxBool isDark = false.obs;

  Future<ThemeService> init() async {
    final prefs = await SharedPreferences.getInstance();
    isDark.value = prefs.getBool(_key) ?? false;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    return this;
  }

  ThemeData get lightTheme => AppTheme.light;
  ThemeData get darkTheme => AppTheme.dark;

  Future<void> toggle() async {
    isDark.value = !isDark.value;
    Get.changeThemeMode(isDark.value ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark.value);
  }

  Color get surface => isDark.value ? const Color(0xFF16211D) : Colors.white;
  Color get textPrimary =>
      isDark.value ? const Color(0xFFE9F2EF) : const Color(0xFF11221D);
  Color get textSecondary =>
      isDark.value ? const Color(0xFF98ADA6) : const Color(0xFF6B7C77);
  Color get divider =>
      isDark.value ? const Color(0xFF2A3B34) : const Color(0xFFE3EAE7);
}
