import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/enums.dart';
import '../../../data/models/family_member.dart';
import 'tree_layout_config.dart';
import 'tree_layout_result.dart';

/// ຈັດຕຳແໜ່ງ node ໃນຜັງໄມ້ຄອບຄົວ.
///
/// ຫຼັກການ:
/// 1. ຄົນທີ່ແຕ່ງງານກັນຈະຖືກລວມເປັນ block ດຽວ ແລະ ວາງຕິດກັນສະເໝີ.
/// 2. ລູກຖືກຈັດກຸ່ມຕາມຄູ່ພໍ່ແມ່ (fatherId|motherId) ບໍ່ແມ່ນຕາມລຸ້ນ.
/// 3. ກຸ່ມລູກຂອງແຕ່ລະຄູ່ຖືກວາງເປັນແຖວຕໍ່ເນື່ອງ ແລະ ມີໄລຍະຫ່າງ
///    [TreeLayoutConfig.groupGap] ຄັ້ນກັບກຸ່ມຂອງຄູ່ອື່ນ.
class TreeLayoutEngine {
  const TreeLayoutEngine({this.config = const TreeLayoutConfig()});

  final TreeLayoutConfig config;

  TreeLayoutResult layout(List<FamilyMember> members, {int revision = 0}) {
    if (members.isEmpty) return TreeLayoutResult.empty;

    final byId = {for (final m in members) m.id: m};
    final blocks = _buildBlocks(members, byId);
    if (blocks.isEmpty) return TreeLayoutResult.empty;

    final blockOf = <String, _Block>{};
    for (final block in blocks) {
      for (final person in block.people) {
        blockOf[person.id] = block;
      }
    }

    final groupsByBlock = <_Block, List<_ChildGroup>>{};
    final edges = <TreeEdge>[];

    for (final child in members) {
      final parentIds = [
        child.fatherId,
        child.motherId,
      ].whereType<String>().where(byId.containsKey).toList();
      if (parentIds.isEmpty) continue;

      final childBlock = blockOf[child.id];
      if (childBlock == null) continue;

      // ເຈົ້າພາບຂອງກຸ່ມລູກ: ໃຊ້ block ຂອງພໍ່ກ່ອນ, ຖ້າບໍ່ມີຈຶ່ງໃຊ້ຂອງແມ່
      final fatherBlock = child.fatherId == null
          ? null
          : blockOf[child.fatherId];
      final owner = fatherBlock ?? blockOf[parentIds.first];
      if (owner == null || identical(owner, childBlock)) continue;

      final sortedParents = [...parentIds]..sort();
      final key = sortedParents.join('|');

      final groups = groupsByBlock.putIfAbsent(owner, () => <_ChildGroup>[]);
      var group = _findGroup(groups, key);
      if (group == null) {
        group = _ChildGroup(key: key, parentIds: sortedParents);
        groups.add(group);
      }
      if (!group.childBlocks.contains(childBlock)) {
        group.childBlocks.add(childBlock);
        group.children.add(child);
      }

      final primary = sortedParents
          .where((id) => identical(blockOf[id], owner))
          .toList();
      final secondary = sortedParents
          .where((id) => !identical(blockOf[id], owner))
          .toList();

      edges.add(
        TreeEdge.parentChild(
          parentIds: primary.isEmpty ? <String>[sortedParents.first] : primary,
          childId: child.id,
        ),
      );
      for (final parentId in secondary) {
        edges.add(
          TreeEdge.parentChild(
            parentIds: <String>[parentId],
            childId: child.id,
            isSecondary: true,
          ),
        );
      }
    }

    // ຄູ່ຜົວ–ເມຍ (dedupe ທັງສອງຝ່າຍ)
    final spouseSeen = <String>{};
    for (final block in blocks) {
      for (var i = 0; i < block.people.length; i++) {
        for (var j = i + 1; j < block.people.length; j++) {
          final a = block.people[i];
          final b = block.people[j];
          if (!a.spouseIds.contains(b.id) && !b.spouseIds.contains(a.id)) {
            continue;
          }
          final key = ([a.id, b.id]..sort()).join('|');
          if (!spouseSeen.add(key)) continue;
          edges.add(
            TreeEdge.spouse(
              aId: a.id,
              bId: b.id,
              divorced:
                  a.status == MemberStatus.divorced ||
                  b.status == MemberStatus.divorced,
            ),
          );
        }
      }
    }

    // ລຽງກຸ່ມລູກໃນແຕ່ລະ block ໃຫ້ຄົງທີ່
    for (final entry in groupsByBlock.entries) {
      entry.key.groups
        ..clear()
        ..addAll(entry.value..sort(_compareGroups));
    }

    // ກຳນົດ block ພໍ່ແມ່ (block ໜຶ່ງມີພໍ່ແມ່ໄດ້ບ່ອນດຽວ ເພື່ອບໍ່ໃຫ້ຕົ້ນໄມ້ຊ້ຳ)
    final orderedBlocks = [...blocks]..sort(_compareBlocks);
    final parentOf = <_Block, _Block>{};
    for (final block in orderedBlocks) {
      for (final group in block.groups) {
        for (final childBlock in group.childBlocks) {
          parentOf.putIfAbsent(childBlock, () => block);
        }
      }
    }

    // ເອົາລູກທີ່ຖືກ block ອື່ນອ້າງອີງອອກ ເພື່ອບໍ່ໃຫ້ນັບຄວາມກວ້າງສອງເທື່ອ
    for (final block in orderedBlocks) {
      for (final group in block.groups) {
        group.childBlocks.removeWhere(
          (childBlock) =>
              parentOf[childBlock] != null &&
              !identical(parentOf[childBlock], block),
        );
        group.children.removeWhere((child) {
          final childBlock = blockOf[child.id];
          return childBlock != null &&
              parentOf[childBlock] != null &&
              !identical(parentOf[childBlock], block);
        });
      }
      block.groups.removeWhere((group) => group.childBlocks.isEmpty);
    }

    final roots = orderedBlocks
        .where((block) => !parentOf.containsKey(block))
        .toList();

    // ວັດຄວາມກວ້າງ (post-order)
    for (final block in orderedBlocks) {
      block.resetMeasurement();
    }
    for (final root in roots) {
      _measure(root);
    }
    for (final block in orderedBlocks) {
      if (!block.measured) _measure(block);
    }

    // ວາງຕຳແໜ່ງ (pre-order)
    final nodes = <TreeNodePosition>[];
    final rootBase = roots.isEmpty
        ? 1
        : roots.map((root) => root.baseGeneration).reduce(math.min);
    var cursorX = config.padding;
    for (final root in roots) {
      _place(root, cursorX, root.baseGeneration - rootBase + 1, nodes);
      cursorX += root.subtreeWidth + config.groupGap;
    }

    // block ທີ່ຢູ່ໃນ cycle ຫຼື ບໍ່ຖືກເຊື່ອມ — ວາງແຖວລຸ່ມສຸດ
    final unplaced = orderedBlocks.where((block) => !block.placed).toList();
    if (unplaced.isNotEmpty) {
      var maxY = 0.0;
      for (final node in nodes) {
        maxY = math.max(maxY, node.offset.dy);
      }
      final extraRow = nodes.isEmpty
          ? 1
          : ((maxY - config.padding) / config.rowHeight).floor() + 2;
      cursorX = config.padding;
      for (final block in unplaced) {
        _place(block, cursorX, extraRow, nodes);
        cursorX += block.subtreeWidth + config.groupGap;
      }
    }

    var maxX = 0.0;
    var maxY = 0.0;
    for (final node in nodes) {
      maxX = math.max(maxX, node.offset.dx + TreeLayoutConfig.nodeWidth);
      maxY = math.max(maxY, node.offset.dy + TreeLayoutConfig.nodeHeight);
    }

    return TreeLayoutResult(
      nodes: nodes,
      edges: edges,
      bounds: Rect.fromLTWH(0, 0, maxX + config.padding, maxY + config.padding),
      revision: revision,
    );
  }

  // ==================== ສ້າງ block ====================

  List<_Block> _buildBlocks(
    List<FamilyMember> members,
    Map<String, FamilyMember> byId,
  ) {
    final parent = <String, String>{for (final m in members) m.id: m.id};

    String find(String id) {
      var root = id;
      while (parent[root] != root) {
        root = parent[root]!;
      }
      var current = id;
      while (parent[current] != current) {
        final next = parent[current]!;
        parent[current] = root;
        current = next;
      }
      return root;
    }

    void union(String a, String b) {
      final rootA = find(a);
      final rootB = find(b);
      if (rootA != rootB) parent[rootB] = rootA;
    }

    for (final member in members) {
      for (final spouseId in member.spouseIds) {
        if (byId.containsKey(spouseId)) union(member.id, spouseId);
      }
    }

    final grouped = <String, List<FamilyMember>>{};
    for (final member in members) {
      grouped.putIfAbsent(find(member.id), () => <FamilyMember>[]).add(member);
    }

    return [
      for (final people in grouped.values) _Block(people: _orderPeople(people)),
    ];
  }

  /// ຈັດລຳດັບຄົນໃນ block: ຄົນທີ່ມີພໍ່ແມ່ (ສາຍເລືອດ) ຢູ່ກ່ອນ, ແລ້ວຄູ່.
  List<FamilyMember> _orderPeople(List<FamilyMember> people) {
    if (people.length <= 1) return people;

    final sorted = [...people]
      ..sort((a, b) {
        final aBlood = (a.fatherId != null || a.motherId != null) ? 0 : 1;
        final bBlood = (b.fatherId != null || b.motherId != null) ? 0 : 1;
        if (aBlood != bBlood) return aBlood.compareTo(bBlood);
        return _comparePeople(a, b);
      });

    final anchor = sorted.first;
    final spouses = sorted.skip(1).toList()..sort(_comparePeople);
    return [anchor, ...spouses];
  }

  // ==================== ວັດ ແລະ ວາງ ====================

  double _measure(_Block block) {
    if (block.measured) return block.subtreeWidth;
    block.measured = true;

    block.ownWidth =
        block.people.length * TreeLayoutConfig.nodeWidth +
        (block.people.length - 1) * config.spouseGap;

    var childrenWidth = 0.0;
    for (final group in block.groups) {
      var groupWidth = 0.0;
      for (var i = 0; i < group.childBlocks.length; i++) {
        groupWidth += _measure(group.childBlocks[i]);
        if (i < group.childBlocks.length - 1) {
          groupWidth += config.siblingGap;
        }
      }
      group.width = groupWidth;
      childrenWidth += groupWidth;
    }
    if (block.groups.isNotEmpty) {
      childrenWidth += (block.groups.length - 1) * config.groupGap;
    }

    block.childrenWidth = childrenWidth;
    block.subtreeWidth = math.max(block.ownWidth, childrenWidth);
    return block.subtreeWidth;
  }

  void _place(
    _Block block,
    double left,
    int baseRow,
    List<TreeNodePosition> out,
  ) {
    if (block.placed) return;
    block.placed = true;

    final peopleLeft = left + (block.subtreeWidth - block.ownWidth) / 2;
    final y = config.padding + (baseRow - 1) * config.rowHeight;

    for (var i = 0; i < block.people.length; i++) {
      out.add(
        TreeNodePosition(
          member: block.people[i],
          offset: Offset(
            peopleLeft + i * (TreeLayoutConfig.nodeWidth + config.spouseGap),
            y,
          ),
        ),
      );
    }

    var cursor = left + (block.subtreeWidth - block.childrenWidth) / 2;
    for (final group in block.groups) {
      var childCursor = cursor;
      for (var i = 0; i < group.childBlocks.length; i++) {
        final childBlock = group.childBlocks[i];
        _place(childBlock, childCursor, baseRow + 1, out);
        childCursor += childBlock.subtreeWidth;
        if (i < group.childBlocks.length - 1) {
          childCursor += config.siblingGap;
        }
      }
      cursor += group.width + config.groupGap;
    }
  }

  // ==================== ການລຽງລຳດັບ ====================

  int _compareGroups(_ChildGroup a, _ChildGroup b) {
    final aBirth = _earliestBirth(a.children);
    final bBirth = _earliestBirth(b.children);
    final byBirth = aBirth.compareTo(bBirth);
    if (byBirth != 0) return byBirth;
    return a.key.compareTo(b.key);
  }

  int _compareBlocks(_Block a, _Block b) {
    final byGeneration = a.baseGeneration.compareTo(b.baseGeneration);
    if (byGeneration != 0) return byGeneration;
    final byBirth = _earliestBirth(a.people)
        .compareTo(_earliestBirth(b.people));
    if (byBirth != 0) return byBirth;
    return a.people.first.fullName.compareTo(b.people.first.fullName);
  }

  int _comparePeople(FamilyMember a, FamilyMember b) {
    // ຜົວຢູ່ຊ້າຍ, ເມຍຢູ່ຂວາ ສຳລັບຄູ່ທີ່ບໍ່ມີຂໍ້ມູນວັນເກີດ
    final byGender = a.gender.index.compareTo(b.gender.index);
    if (byGender != 0) return byGender;

    final byBirth = (a.birthDate?.millisecondsSinceEpoch ?? (1 << 62))
        .compareTo(b.birthDate?.millisecondsSinceEpoch ?? (1 << 62));
    if (byBirth != 0) return byBirth;
    return a.fullName.compareTo(b.fullName);
  }

  int _earliestBirth(List<FamilyMember> people) {
    var earliest = 1 << 62;
    for (final person in people) {
      final value = person.birthDate?.millisecondsSinceEpoch;
      if (value != null && value < earliest) earliest = value;
    }
    return earliest;
  }

  _ChildGroup? _findGroup(List<_ChildGroup> groups, String key) {
    for (final group in groups) {
      if (group.key == key) return group;
    }
    return null;
  }
}

class _Block {
  _Block({required this.people});

  final List<FamilyMember> people;
  final List<_ChildGroup> groups = <_ChildGroup>[];

  double ownWidth = 0;
  double childrenWidth = 0;
  double subtreeWidth = 0;
  bool measured = false;
  bool placed = false;

  int get baseGeneration {
    var value = 1 << 30;
    for (final person in people) {
      if (person.generation < value) value = person.generation;
    }
    return value == 1 << 30 ? 1 : math.max(1, value);
  }

  void resetMeasurement() {
    measured = false;
    placed = false;
    ownWidth = 0;
    childrenWidth = 0;
    subtreeWidth = 0;
  }
}

class _ChildGroup {
  _ChildGroup({required this.key, required this.parentIds});

  final String key;
  final List<String> parentIds;
  final List<FamilyMember> children = <FamilyMember>[];
  final List<_Block> childBlocks = <_Block>[];
  double width = 0;
}
