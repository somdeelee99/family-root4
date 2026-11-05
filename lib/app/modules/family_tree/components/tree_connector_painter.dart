import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../layout/tree_layout_config.dart';
import '../layout/tree_layout_result.dart';

/// ວາດເສັ້ນເຊື່ອມຄວາມສຳພັນລະຫວ່າງ node.
///
/// - ພໍ່ແມ່ → ລູກ: ວາດຈາກ “ຈຸດກາງຂອງຄູ່” ລົງມາເປັນເສັ້ນດຽວ ແລ້ວແຍກໄປຫາລູກແຕ່ລະຄົນ
/// - ຜົວ–ເມຍ: ເສັ້ນນອນ + ຫົວໃຈ (ຖ້າຢ່າຮ້າງຈະເປັນເສັ້ນປະ)
/// - ພໍ່ແມ່ທີ່ຢູ່ຄົນລະ block: ເສັ້ນປະ
class TreeConnectorPainter extends CustomPainter {
  TreeConnectorPainter({
    required this.nodes,
    required this.edges,
    required this.revision,
    this.selectedId,
  });

  final List<TreeNodePosition> nodes;
  final List<TreeEdge> edges;
  final int revision;
  final String? selectedId;

  @override
  void paint(Canvas canvas, Size size) {
    final byId = {for (final node in nodes) node.member.id: node};
    _paintParentChild(canvas, byId);
    _paintSpouses(canvas, byId);
  }

  // ==================== ພໍ່ແມ່ → ລູກ ====================

  void _paintParentChild(Canvas canvas, Map<String, TreeNodePosition> byId) {
    final primary = <String, List<TreeEdge>>{};
    final secondary = <TreeEdge>[];

    for (final edge in edges) {
      if (edge.type != TreeEdgeType.parentChild) continue;
      if (edge.isSecondary) {
        secondary.add(edge);
        continue;
      }
      final key = ([...edge.parentIds]..sort()).join('|');
      primary.putIfAbsent(key, () => <TreeEdge>[]).add(edge);
    }

    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.34)
      ..strokeWidth = 1.55
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.55);

    for (final group in primary.values) {
      if (group.isEmpty) continue;

      final parentAnchors = <Offset>[];
      for (final parentId in group.first.parentIds) {
        final parent = byId[parentId];
        if (parent == null) continue;
        parentAnchors.add(
          Offset(
            parent.offset.dx + TreeLayoutConfig.nodeWidth / 2,
            parent.offset.dy + TreeLayoutConfig.nodeHeight,
          ),
        );
      }
      if (parentAnchors.isEmpty) continue;

      final anchor = _average(parentAnchors);

      final childTops = <Offset>[];
      for (final edge in group) {
        final child = byId[edge.childId];
        if (child == null) continue;
        childTops.add(
          Offset(
            child.offset.dx + TreeLayoutConfig.nodeWidth / 2,
            child.offset.dy,
          ),
        );
      }
      if (childTops.isEmpty) continue;

      final minX = childTops.map((offset) => offset.dx).reduce(math.min);
      final maxX = childTops.map((offset) => offset.dx).reduce(math.max);
      final minChildY = childTops.map((offset) => offset.dy).reduce(math.min);
      final busY = (anchor.dy + minChildY) / 2;

      // ເສັ້ນຕັ້ງຈາກຄູ່ລົງມາຫາ bus
      canvas.drawLine(anchor, Offset(anchor.dx, busY), linePaint);
      // ເສັ້ນນອນ (bus) ທີ່ເຊື່ອມລູກທຸກຄົນ
      canvas.drawLine(Offset(minX, busY), Offset(maxX, busY), linePaint);
      // ເສັ້ນລົງຫາລູກແຕ່ລະຄົນ
      for (final top in childTops) {
        canvas.drawLine(Offset(top.dx, busY), top, linePaint);
        canvas.drawCircle(top, 2.6, dotPaint);
      }
    }

    // ພໍ່/ແມ່ທີ່ຢູ່ຄົນລະ block — ເສັ້ນປະ
    final secondaryPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final edge in secondary) {
      final parent = byId[edge.parentIds.first];
      final child = byId[edge.childId];
      if (parent == null || child == null) continue;

      final from = Offset(
        parent.offset.dx + TreeLayoutConfig.nodeWidth / 2,
        parent.offset.dy + TreeLayoutConfig.nodeHeight,
      );
      final to = Offset(
        child.offset.dx + TreeLayoutConfig.nodeWidth / 2,
        child.offset.dy,
      );
      final midY = (from.dy + to.dy) / 2;

      _dashedLine(canvas, from, Offset(from.dx, midY), secondaryPaint);
      _dashedLine(
        canvas,
        Offset(from.dx, midY),
        Offset(to.dx, midY),
        secondaryPaint,
      );
      _dashedLine(canvas, Offset(to.dx, midY), to, secondaryPaint);
    }
  }

  // ==================== ຜົວ–ເມຍ ====================

  void _paintSpouses(Canvas canvas, Map<String, TreeNodePosition> byId) {
    for (final edge in edges) {
      if (edge.type != TreeEdgeType.spouse) continue;
      final a = byId[edge.aId];
      final b = byId[edge.bId];
      if (a == null || b == null) continue;

      final paint = Paint()
        ..color = edge.divorced
            ? AppColors.divorced.withValues(alpha: 0.75)
            : AppColors.female.withValues(alpha: 0.68)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final y = a.offset.dy + TreeLayoutConfig.nodeHeight / 2;

      if (a.offset.dy == b.offset.dy) {
        final left = a.offset.dx < b.offset.dx
            ? a.offset.dx + TreeLayoutConfig.nodeWidth
            : b.offset.dx + TreeLayoutConfig.nodeWidth;
        final right = a.offset.dx < b.offset.dx ? b.offset.dx : a.offset.dx;
        final isAdjacent = (right - left) <= 24;

        if (isAdjacent) {
          if (edge.divorced) {
            _dashedLine(canvas, Offset(left, y), Offset(right, y), paint);
          } else {
            canvas.drawLine(Offset(left, y), Offset(right, y), paint);
            _drawHeart(canvas, Offset((left + right) / 2, y));
          }
        } else {
          // ຢູ່ລຸ້ນດຽວກັນແຕ່ບໍ່ຕິດກັນ — ວາດເສັ້ນໂຄ້ງລຸ່ມ
          final path = Path()
            ..moveTo(
              a.offset.dx + TreeLayoutConfig.nodeWidth / 2,
              a.offset.dy + TreeLayoutConfig.nodeHeight,
            )
            ..quadraticBezierTo(
              (a.offset.dx + b.offset.dx) / 2 + TreeLayoutConfig.nodeWidth / 2,
              a.offset.dy +
                  TreeLayoutConfig.nodeHeight +
                  TreeLayoutConfig.nodeHeight * 0.18,
              b.offset.dx + TreeLayoutConfig.nodeWidth / 2,
              b.offset.dy + TreeLayoutConfig.nodeHeight,
            );
          canvas.drawPath(path, paint);
        }
      } else {
        final upper = a.offset.dy < b.offset.dy ? a : b;
        final lower = a.offset.dy < b.offset.dy ? b : a;
        final from = Offset(
          upper.offset.dx + TreeLayoutConfig.nodeWidth / 2,
          upper.offset.dy + TreeLayoutConfig.nodeHeight,
        );
        final to = Offset(
          lower.offset.dx + TreeLayoutConfig.nodeWidth / 2,
          lower.offset.dy,
        );
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(from.dx, from.dy + 30, to.dx, to.dy - 30, to.dx, to.dy);
        canvas.drawPath(path, paint);
      }
    }
  }

  // ==================== ຕົວຊ່ວຍ ====================

  Offset _average(List<Offset> points) {
    var dx = 0.0;
    var dy = 0.0;
    for (final point in points) {
      dx += point.dx;
      dy += point.dy;
    }
    return Offset(dx / points.length, dy / points.length);
  }

  void _dashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dash = 6.0;
    const gap = 4.0;
    final delta = b - a;
    final distance = delta.distance;
    if (distance == 0) return;

    final direction = delta / distance;
    var start = 0.0;
    while (start < distance) {
      final end = math.min(start + dash, distance);
      canvas.drawLine(a + direction * start, a + direction * end, paint);
      start = end + gap;
    }
  }

  void _drawHeart(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = AppColors.female
      ..isAntiAlias = true;
    final path = Path();
    const s = 3.6;
    path.moveTo(center.dx, center.dy + s * 0.9);
    path.cubicTo(
      center.dx - s * 1.6,
      center.dy - s * 0.35,
      center.dx - s * 0.5,
      center.dy - s * 1.3,
      center.dx,
      center.dy - s * 0.35,
    );
    path.cubicTo(
      center.dx + s * 0.5,
      center.dy - s * 1.3,
      center.dx + s * 1.6,
      center.dy - s * 0.35,
      center.dx,
      center.dy + s * 0.9,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TreeConnectorPainter oldDelegate) =>
      oldDelegate.revision != revision || oldDelegate.selectedId != selectedId;
}
