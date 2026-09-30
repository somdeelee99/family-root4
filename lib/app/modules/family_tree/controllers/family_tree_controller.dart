import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/export_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/family.dart';
import '../../../data/models/family_member.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/member_repository.dart';

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

  Rect get rect => Rect.fromLTWH(offset.dx, offset.dy, FamilyTreeController.nodeWidth, FamilyTreeController.nodeHeight);
}

/// ຄວບຄຸມຜັງໄມ້ຄອບຄົວ
class FamilyTreeController extends GetxController {
  static const double nodeWidth = 128;
  static const double nodeHeight = 150;
  static const double gapX = 26;
  static const double gapY = 74;
  static const double canvasPadding = 60;

  final MemberRepository _memberRepo = MemberRepository();
  final FamilyRepository _familyRepo = FamilyRepository();

  final TransformationController transformation = TransformationController();
  final GlobalKey boundaryKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();

  StreamSubscription<List<FamilyMember>>? _sub;

  final RxList<FamilyMember> members = <FamilyMember>[].obs;
  final RxList<TreeNodePosition> nodes = <TreeNodePosition>[].obs;
  final Rxn<FamilyMember> selected = Rxn<FamilyMember>();
  final Rxn<Family> family = Rxn<Family>();
  final RxString query = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTreeMode = true.obs; // ຜັງ vs ລາຍການ
  final RxBool isExporting = false.obs;
  final Size canvasSize = const Size(1200, 900);

  bool get isAdmin => AuthService.to.isAdmin;
  String get familyId => AuthService.to.familyId;

  @override
  void onInit() {
    super.onInit();
    _listen();
    searchController.addListener(() => query.value = searchController.text.trim());
  }

  void _listen() {
    final fid = familyId;
    if (fid.isEmpty) {
      isLoading.value = false;
      return;
    }
    _sub = _memberRepo.membersStream(fid).listen(
      (list) {
        members.assignAll(list);
        _layout();
        isLoading.value = false;
        if (selected.value != null) {
          final match = list.where((m) => m.id == selected.value!.id).toList();
          selected.value = match.isEmpty ? null : match.first;
        }
      },
      onError: (Object e) {
        isLoading.value = false;
        UiHelpers.error(UiHelpers.mapError(e));
      },
    );
    _familyRepo.familyStream(fid).listen((value) => family.value = value);
  }

  // ==================== LAYOUT ENGINE ====================

  /// ຈັດຕຳແໜ່ງ node ໃນຜັງ (ຈັດຕາມລຸ້ນ ແລະ ຈັບກຸ່ມລູກໄວ້ໃຕ້ພໍ່ແມ່)
  void _layout() {
    if (members.isEmpty) {
      nodes.clear();
      return;
    }

    final byId = {for (final m in members) m.id: m};
    final maxGeneration = members.map((m) => m.generation).reduce((a, b) => a > b ? a : b);

    // ຈັດລຳດັບພາຍໃນແຕ່ລະລຸ້ນ
    final ordered = <int, List<FamilyMember>>{};
    for (var gen = 1; gen <= maxGeneration; gen++) {
      ordered[gen] = [];
    }

    // ລຸ້ນທີ 1: ຜູ້ທີ່ບໍ່ມີພໍ່ແມ່ (ຮາກຂອງຄອບຄົວ)
    final roots = members.where((m) => m.generation <= 1 || (m.fatherId == null && m.motherId == null)).toList()
      ..sort((a, b) => (a.birthDate?.year ?? 9999).compareTo(b.birthDate?.year ?? 9999));
    ordered[1] = roots;

    final placed = <String>{for (final r in roots) r.id};
    for (var gen = 2; gen <= maxGeneration; gen++) {
      final list = <FamilyMember>[];
      // ລູກຂອງຜູ້ຢູ່ລຸ້ນກ່ອນ (ຕາມລຳດັບທີ່ຈັດແລ້ວ)
      for (final parent in ordered[gen - 1] ?? const <FamilyMember>[]) {
        for (final childId in parent.childIds) {
          final child = byId[childId];
          if (child == null || placed.contains(child.id)) continue;
          if (child.generation > gen) continue;
          list.add(child);
          placed.add(child.id);
        }
      }
      // ຜູ້ທີ່ຍັງບໍ່ຖືກຈັດ (ບໍ່ມີຂໍ້ມູນພໍ່ແມ່)
      for (final m in members.where((m) => m.generation == gen && !placed.contains(m.id))) {
        list.add(m);
        placed.add(m.id);
      }
      ordered[gen] = list;
    }

    // ຜູ້ທີ່ຍັງເຫຼືອ (generation ຜິດປົກກະຕິ)
    final leftovers = members.where((m) => !placed.contains(m.id)).toList();
    if (leftovers.isNotEmpty) {
      ordered[maxGeneration] = [...(ordered[maxGeneration] ?? []), ...leftovers];
    }

    // ຄຳນວນຕຳແໜ່ງ
    final result = <TreeNodePosition>[];
    final highlighted = query.value.toLowerCase();

    var maxRowWidth = 0.0;
    for (var gen = 1; gen <= maxGeneration; gen++) {
      final row = ordered[gen] ?? const <FamilyMember>[];
      if (row.isEmpty) continue;
      final rowWidth = row.length * nodeWidth + (row.length - 1) * gapX;
      maxRowWidth = rowWidth > maxRowWidth ? rowWidth : maxRowWidth;
    }

    for (var gen = 1; gen <= maxGeneration; gen++) {
      final row = ordered[gen] ?? const <FamilyMember>[];
      if (row.isEmpty) continue;
      final rowWidth = row.length * nodeWidth + (row.length - 1) * gapX;
      final startX = canvasPadding + (maxRowWidth - rowWidth) / 2;
      final y = canvasPadding + (gen - 1) * (nodeHeight + gapY);

      for (var i = 0; i < row.length; i++) {
        final m = row[i];
        final isMatch = highlighted.isNotEmpty &&
            (m.fullName.toLowerCase().contains(highlighted) ||
                (m.nickname ?? '').toLowerCase().contains(highlighted));
        result.add(
          TreeNodePosition(
            member: m,
            offset: Offset(startX + i * (nodeWidth + gapX), y),
            isHighlighted: isMatch,
          ),
        );
      }
    }

    nodes.assignAll(result);
  }

  // ==================== ການຄົ້ນຫາ ====================

  void search(String value) => searchController.text = value;

  void clearSearch() {
    searchController.clear();
    query.value = '';
    _layout();
  }

  /// ເລື່ອນໄປຫາ node ທີ່ຄົ້ນຫາເຫັນຄັ້ງທຳອິດ
  void focusFirstMatch() {
    for (final node in nodes) {
      if (node.isHighlighted) {
        focusNode(node);
        return;
      }
    }
  }

  /// ເລື່ອນ viewport ໄປຫາ node ທີ່ເລືອກ (ຮັກສາລະດັບ zoom ເດີມ)
  void focusNode(TreeNodePosition node) {
    final scale = transformation.value.getMaxScaleOnAxis();
    const viewportCenterX = 195.0;
    const viewportCenterY = 240.0;
    final x = node.offset.dx + nodeWidth / 2;
    final y = node.offset.dy + nodeHeight / 2;
    final translation = Matrix4.translationValues(
      viewportCenterX - x * scale,
      viewportCenterY - y * scale,
      0,
    );
    transformation.value = translation * Matrix4.diagonal3Values(scale, scale, 1);
  }

  /// ເອີ້ນຫຼັງຈາກມີການລຶບ/ແກ້ໄຂ ເພື່ອລ້າງການເລືອກທີ່ອາດອ້າງອີງເຖິງຂໍ້ມູນເກົ່າ
  void refreshSelected() {
    final selectedId = selected.value?.id;
    if (selectedId == null) return;
    FamilyMember? match;
    for (final m in members) {
      if (m.id == selectedId) {
        match = m;
        break;
      }
    }
    selected.value = match;
    _layout();
  }

  void zoomIn() => _zoom(1.25);
  void zoomOut() => _zoom(0.8);

  void _zoom(double factor) {
    final current = transformation.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(0.35, 2.6);
    transformation.value = Matrix4.diagonal3Values(next, next, 1);
  }

  void resetZoom() => transformation.value = Matrix4.identity();

  // ==================== ການຈັດການສະມາຊິກ ====================

  Future<void> deleteMember(FamilyMember member) async {
    final confirmed = await UiHelpers.confirm(
      title: 'ລຶບ ${member.fullName}?',
      message: 'ການລຶບຈະລຶບຄວາມສຳພັນທີ່ອ້າງອີງເຖິງສະມາຊິກຄົນນີ້ນຳ',
      confirmText: 'ລຶບ',
      isDanger: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed) return;
    try {
      UiHelpers.loading(message: 'ກຳລັງລຶບ...');
      await _memberRepo.deleteMember(
        familyId: familyId,
        memberId: member.id,
        allMembers: members,
      );
      await _familyRepo.logActivity(
        familyId: familyId,
        userId: AuthService.to.uid,
        action: 'ລຶບສະມາຊິກ',
        detail: member.fullName,
      );
      UiHelpers.hideLoading();
      selected.value = null;
      UiHelpers.success('ລຶບ ${member.fullName} ສຳເລັດ');
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  // ==================== EXPORT ====================

  /// ບັນທຶກຜັງເປັນ PDF (ພ້ອມຮູບຜັງ ແລະ ຕາຕະລາງລາຍຊື່)
  Future<Uint8List?> buildPdf() async {
    isExporting.value = true;
    try {
      final image = await ExportService.captureWidget(boundaryKey, pixelRatio: 1.6);
      final bytes = await ExportService.buildTreePdf(
        familyName: family.value?.displayName ?? 'ຄອບຄົວ',
        surname: family.value?.surname ?? '',
        members: members,
        treeImage: image,
      );
      return bytes;
    } catch (e) {
      UiHelpers.error(UiHelpers.mapError(e));
      return null;
    } finally {
      isExporting.value = false;
    }
  }

  Future<void> exportPdf() async {
    final bytes = await buildPdf();
    if (bytes == null) return;
    await ExportService.printPdf(bytes, name: 'family-tree-${family.value?.surname ?? 'root'}');
  }

  Future<void> sharePdf() async {
    final bytes = await buildPdf();
    if (bytes == null) return;
    await ExportService.sharePdf(bytes, name: 'family-tree-${family.value?.surname ?? 'root'}');
  }

  Future<Uint8List?> captureImage() => ExportService.captureWidget(boundaryKey, pixelRatio: 2.0);

  /// ສະມາຊິກທີ່ສາມາດເປັນພໍ່ແມ່ໄດ້ (ລຸ້ນກ່ອນໜ້າ ຫຼື ເທົ່າກັນ)
  List<FamilyMember> possibleParents({int generation = 99, String? excludeId}) => members
      .where((m) => m.id != excludeId && m.generation < generation && m.status != MemberStatus.deceased)
      .toList();

  List<FamilyMember> possibleSpouses({int generation = 99, String? excludeId}) =>
      members.where((m) => m.id != excludeId && m.generation == generation).toList();

  /// ລາຍຊື່ສະມາຊິກແຍກຕາມລຸ້ນ (ສຳລັບໂໝດລາຍການ)
  Map<int, List<FamilyMember>> get groupedByGeneration {
    final map = <int, List<FamilyMember>>{};
    for (final m in members) {
      map.putIfAbsent(m.generation, () => []).add(m);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: map[k]!};
  }

  @override
  void onClose() {
    _sub?.cancel();
    searchController.dispose();
    transformation.dispose();
    super.onClose();
  }
}
