import 'package:flutter/material.dart';

/// ຊຸດສີຂອງແອັບ Family Root
/// ແນວຄິດ: ສີຂຽວເຂັ້ມ (ຕົ້ນໄມ້/ຮາກ) + ສີທອງ (ຄວາມອົບອຸ່ນຂອງຄອບຄົວ)
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1E6F5C);
  static const Color primaryDark = Color(0xFF10513F);
  static const Color primaryLight = Color(0xFF44A184);
  static const Color primarySoft = Color(0xFFE7F3EF);

  static const Color accent = Color(0xFFF2A93B);
  static const Color accentSoft = Color(0xFFFFF4E2);

  static const Color background = Color(0xFFF5F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF0F5F3);
  static const Color divider = Color(0xFFE3EAE7);

  static const Color textPrimary = Color(0xFF11221D);
  static const Color textSecondary = Color(0xFF6B7C77);
  static const Color textHint = Color(0xFF9AA9A4);

  static const Color male = Color(0xFF3B82F6);
  static const Color female = Color(0xFFEC4899);
  static const Color deceased = Color(0xFF8B9AA5);
  static const Color divorced = Color(0xFFF59E0B);
  static const Color alive = Color(0xFF22A06B);

  static const Color success = Color(0xFF22A06B);
  static const Color warning = Color(0xFFF2A93B);
  static const Color danger = Color(0xFFE5484D);
  static const Color info = Color(0xFF3B82F6);

  static const Color chatMine = Color(0xFF1E6F5C);
  static const Color chatOther = Color(0xFFFFFFFF);

  // ---- Dark mode ----
  static const Color darkBackground = Color(0xFF0D1512);
  static const Color darkSurface = Color(0xFF16211D);
  static const Color darkSurfaceAlt = Color(0xFF1D2C26);
  static const Color darkDivider = Color(0xFF2A3B34);
  static const Color darkTextPrimary = Color(0xFFE9F2EF);
  static const Color darkTextSecondary = Color(0xFF98ADA6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryDark, primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF7C36A), Color(0xFFF2A93B), Color(0xFFDE8F22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF10513F), Color(0xFF1E6F5C), Color(0xFF2E8C71)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// ສີຕາມເພດ
  static Color forGender(String? gender) {
    switch (gender) {
      case 'male':
        return male;
      case 'female':
        return female;
      default:
        return textSecondary;
    }
  }
}
