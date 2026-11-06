import 'package:flutter/material.dart';

import '../../../data/models/family_member.dart';
import 'tree_layout_config.dart';

/// ຕຳແໜ່ງຂອງ node ໃນຜັງ (ຄຳນວນຈາກ layout engine)
class TreeNodePosition {
  const TreeNodePosition({
    required this.member,
    required this.offset,
    this.isHighlighted = false,
  });

  final FamilyMember member;
  final Offset offset;
  final bool isHighlighted;

  Rect get rect => Rect.fromLTWH(
    offset.dx,
    offset.dy,
    TreeLayoutConfig.nodeWidth,
    TreeLayoutConfig.nodeHeight,
  );
}

enum TreeEdgeType { parentChild, spouse }

/// ເສັ້ນເຊື່ອມຄວາມສຳພັນທີ່ layout engine ສ້າງໃຫ້ painter ວາດ.
class TreeEdge {
  const TreeEdge.parentChild({
    required this.parentIds,
    required this.childId,
    this.isSecondary = false,
  }) : type = TreeEdgeType.parentChild,
       aId = null,
       bId = null,
       divorced = false;

  const TreeEdge.spouse({
    required this.aId,
    required this.bId,
    this.divorced = false,
  }) : type = TreeEdgeType.spouse,
       parentIds = const [],
       childId = '',
       isSecondary = false;

  final TreeEdgeType type;

  /// ສຳລັບ parentChild: ພໍ່ແມ່ທີ່ຢູ່ block ດຽວກັນ (1 ຫຼື 2 ຄົນ)
  final List<String> parentIds;

  /// ສຳລັບ parentChild: ລູກ
  final String childId;

  /// ສຳລັບ spouse: ຄູ່ຜົວ–ເມຍ
  final String? aId;
  final String? bId;

  /// ເສັ້ນພໍ່ແມ່ທີ່ຢູ່ຄົນລະ block (ວາດເສັ້ນປະ)
  final bool isSecondary;

  final bool divorced;
}

/// ຜົນລັບຂອງ layout engine
class TreeLayoutResult {
  const TreeLayoutResult({
    required this.nodes,
    required this.edges,
    required this.bounds,
    required this.revision,
  });

  static const TreeLayoutResult empty = TreeLayoutResult(
    nodes: <TreeNodePosition>[],
    edges: <TreeEdge>[],
    bounds: Rect.zero,
    revision: 0,
  );

  final List<TreeNodePosition> nodes;
  final List<TreeEdge> edges;
  final Rect bounds;
  final int revision;

  Size get canvasSize => bounds.isEmpty ? const Size(800, 800) : bounds.size;

  Map<String, TreeNodePosition> get byId => {
    for (final node in nodes) node.member.id: node,
  };
}
