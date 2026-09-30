import 'package:flutter/material.dart';

/// ຂະໜາດ ແລະ ໄລຍະຫ່າງມາດຕະຖານ (design size 390 x 844 - iPhone 14)
class AppSizes {
  AppSizes._();

  static const Size designSize = Size(390, 844);

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;

  static const double buttonHeight = 54;
  static const double inputHeight = 56;
  static const double avatarSm = 36;
  static const double avatarMd = 52;
  static const double avatarLg = 96;

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 600);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0F10513F), blurRadius: 18, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x140D3B2E), blurRadius: 22, offset: Offset(0, 10)),
  ];
}
