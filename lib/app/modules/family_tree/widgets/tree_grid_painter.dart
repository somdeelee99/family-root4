import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// ວາດຕາລາງແບບຈາງໆໃນ canvas ເພື່ອອ່ານຜັງຂະໜາດໃຫຍ່ໄດ້ງ່າຍຂຶ້ນ.
class TreeCanvasGridPainter extends CustomPainter {
  const TreeCanvasGridPainter({this.spacing = 44});

  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.035)
      ..strokeWidth = 0.7;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TreeCanvasGridPainter oldDelegate) =>
      oldDelegate.spacing != spacing;
}
