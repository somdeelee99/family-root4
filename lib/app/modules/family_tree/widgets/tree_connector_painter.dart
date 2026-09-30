import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/family_tree_controller.dart';

/// ວາດເສັ້ນເຊື່ອມຄວາມສຳພັນລະຫວ່າງ node
/// - ພໍ່ແມ່ -> ລູກ (ເສັ້ນຕັ້ງ + ເສັ້ນນອນ)
/// - ຜົວ/ເມຍ (ເສັ້ນນອນ + ຫົວໃຈ)
class TreeConnectorPainter extends CustomPainter {
  TreeConnectorPainter({
    required this.nodes,
    required this.selectedId,
  });

  final List<TreeNodePosition> nodes;
  final String? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final n in nodes) n.member.id: n};

    // ---------- ເສັ້ນພໍ່ແມ່ -> ລູກ ----------
    final childPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.42)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final node in nodes) {
      final parentIds = [
        node.member.fatherId,
        node.member.motherId,
      ].whereType<String>().where(byId.containsKey).toList();

      if (parentIds.isEmpty) continue;

      final childTop = Offset(
        node.offset.dx + FamilyTreeController.nodeWidth / 2,
        node.offset.dy,
      );

      for (final pid in parentIds) {
        final parent = byId[pid]!;
        final parentBottom = Offset(
          parent.offset.dx + FamilyTreeController.nodeWidth / 2,
          parent.offset.dy + FamilyTreeController.nodeHeight,
        );

        final midY = (parentBottom.dy + childTop.dy) / 2;
        final path = Path()
          ..moveTo(parentBottom.dx, parentBottom.dy)
          ..lineTo(parentBottom.dx, midY)
          ..lineTo(childTop.dx, midY)
          ..lineTo(childTop.dx, childTop.dy);

        canvas.drawPath(path, childPaint);
      }

      // ຈຸດເຊື່ອມ
      canvas.drawCircle(childTop, 2.6,
          Paint()..color = AppColors.primary.withValues(alpha: 0.55));
    }

    // ---------- ເສັ້ນຜົວ/ເມຍ ----------
    final spousePairs = <String>{};
    final spousePaint = Paint()
      ..color = AppColors.female.withValues(alpha: 0.55)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (final node in nodes) {
      for (final spouseId in node.member.spouseIds) {
        final spouse = byId[spouseId];
        if (spouse == null) continue;
        final key = ([node.member.id, spouseId]..sort()).join('-');
        if (spousePairs.contains(key)) continue;
        spousePairs.add(key);

        final a = node.offset;
        final b = spouse.offset;
        final y = a.dy + FamilyTreeController.nodeHeight / 2;

        // ຖ້າຢູ່ລຸ້ນດຽວກັນ ໃຫ້ວາດເສັ້ນຕັດຕາມຂອບ
        if (a.dy == b.dy) {
          final left = a.dx < b.dx
              ? a.dx + FamilyTreeController.nodeWidth
              : b.dx + FamilyTreeController.nodeWidth;
          final right = a.dx < b.dx ? b.dx : a.dx;
          if (right > left) {
            canvas.drawLine(Offset(left, y), Offset(right, y), spousePaint);
            _drawHeart(canvas, Offset((left + right) / 2, y));
          } else {
            // ຢູ່ລຸ້ນດຽວກັນແຕ່ບໍ່ຕິດກັນ - ວາດເສັ້ນໂຄ້ງ
            final path = Path()
              ..moveTo(a.dx + FamilyTreeController.nodeWidth / 2,
                  a.dy + FamilyTreeController.nodeHeight)
              ..quadraticBezierTo(
                (a.dx + b.dx) / 2 + FamilyTreeController.nodeWidth / 2,
                a.dy + FamilyTreeController.nodeHeight + 26,
                b.dx + FamilyTreeController.nodeWidth / 2,
                b.dy + FamilyTreeController.nodeHeight,
              );
            canvas.drawPath(path, spousePaint);
          }
        } else {
          final upper = a.dy < b.dy ? a : b;
          final lower = a.dy < b.dy ? b : a;
          final from = Offset(upper.dx + FamilyTreeController.nodeWidth / 2,
              upper.dy + FamilyTreeController.nodeHeight);
          final to =
              Offset(lower.dx + FamilyTreeController.nodeWidth / 2, lower.dy);
          final path = Path()
            ..moveTo(from.dx, from.dy)
            ..cubicTo(from.dx, from.dy + 30, to.dx, to.dy - 30, to.dx, to.dy);
          canvas.drawPath(path, spousePaint..style = PaintingStyle.stroke);
        }
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center) {
    final paint = Paint()..color = AppColors.female;
    final path = Path();
    const s = 4.6;
    path.moveTo(center.dx, center.dy + s * 0.9);
    path.cubicTo(center.dx - s * 1.6, center.dy - s * 0.35, center.dx - s * 0.5,
        center.dy - s * 1.3, center.dx, center.dy - s * 0.35);
    path.cubicTo(center.dx + s * 0.5, center.dy - s * 1.3, center.dx + s * 1.6,
        center.dy - s * 0.35, center.dx, center.dy + s * 0.9);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TreeConnectorPainter oldDelegate) =>
      oldDelegate.nodes != nodes || oldDelegate.selectedId != selectedId;
}
