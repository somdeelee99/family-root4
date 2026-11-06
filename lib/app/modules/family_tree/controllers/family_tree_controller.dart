import 'dart:async';
import 'dart:math' as math;
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
import 'tree_layout_config.dart';
import 'tree_layout_engine.dart';
import 'tree_layout_result.dart';

export 'tree_layout_result.dart'
    show TreeEdge, TreeEdgeType, TreeNodePosition;

/// ຄວບຄຸມຜັງໄມ້ຄອບຄົວ
class FamilyTreeController extends GetxController {
  static const double nodeWidth = TreeLayoutConfig.nodeWidth;
  static const double nodeHeight = TreeLayoutConfig.nodeHeight;
  static const double canvasPadding = 60;

  final MemberRepository _memberRepo = MemberRepository();
  final FamilyRepository _familyRepo = FamilyRepository();
  final TreeLayoutEngine _engine = const TreeLayoutEngine();

  final TransformationController transformation = TransformationController();
  final GlobalKey boundaryKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();

  StreamSubscription<List<FamilyMember>>? _sub;

  final RxList<FamilyMember> members = <FamilyMember>[].obs;
  final RxList<TreeNodePosition> nodes = <TreeNodePosition>[].obs;
  final RxSet<String> matchedIds = <String>{}.obs;
  final Rxn<FamilyMember> selected = Rxn<FamilyMember>();
  final Rxn<Family> family = Rxn<Family>();
  final RxString query = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isTreeMode = true.obs; // ຜັງ vs ລາຍການ
  final RxBool isExporting = false.obs;

  /// ຂະໜາດ viewport ຕົວຈິງ (ອັບເດດຈາກ LayoutBuilder ໃນ canvas)
  Size viewportSize = Size.zero;

  TreeLayoutResult _layoutResult = TreeLayoutResult.empty;
  TreeLayoutResult get layoutResult => _layoutResult;
  int _layoutRevision = 0;
  bool _didAutoFit = false;

  bool get isAdmin => AuthService.to.isAdmin;
  String get familyId => AuthService.to.familyId;

  /// ຂະໜາດ canvas ທີ່ layout engine ຄຳນວນໄວ້
  Size get canvasSize => _layoutResult.canvasSize;

  @override
  void onInit() {
    super.onInit();
    _listen();
    searchController.addListener(() {
      final text = searchController.text.trim();
      if (query.value == text) return;
      query.value = text;
      _updateMatches();
    });
  }

  void _listen() {
    final fid = familyId;
    if (fid.isEmpty) {
      isLoading.value = false;
      return;
    }
    _sub = _memberRepo
        .membersStream(fid)
        .listen(
          (list) {
            members.assignAll(list);
            _updateMatches();
            _layout();
            isLoading.value = false;
            if (selected.value != null) {
              final match = list
                  .where((m) => m.id == selected.value!.id)
                  .toList();
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

  // ==================== LAYOUT ====================

  /// ຈັດຕຳແໜ່ງ node ໃໝ່ທັງໝົດ (ຄູ່ຕິດກັນ + ລູກແຍກຕາມຄູ່ພໍ່ແມ່)
  void _layout() {
    _layoutRevision++;
    _layoutResult = _engine.layout(members, revision: _layoutRevision);
    nodes.assignAll(_layoutResult.nodes);
  }

  // ==================== ການຄົ້ນຫາ ====================

  void search(String value) => searchController.text = value;

  void clearSearch() {
    searchController.clear();
    query.value = '';
    matchedIds.clear();
  }

  void _updateMatches() {
    final q = query.value.trim().toLowerCase();
    matchedIds.clear();
    if (q.isEmpty) return;
    for (final member in members) {
      if (member.fullName.toLowerCase().contains(q) ||
          (member.nickname ?? '').toLowerCase().contains(q)) {
        matchedIds.add(member.id);
      }
    }
  }

  /// ເລື່ອນໄປຫາ node ທຳອິດທີ່ຄົ້ນຫາເຫັນ
  void focusFirstMatch() {
    if (matchedIds.isEmpty) return;
    for (final node in nodes) {
      if (matchedIds.contains(node.member.id)) {
        focusNode(node);
        return;
      }
    }
  }

  /// ເລື່ອນ viewport ໄປຫາ node ທີ່ເລືອກ (ຮັກສາລະດັບ zoom ເດີມ)
  void focusNode(TreeNodePosition node) {
    final viewport = _effectiveViewport;
    final scale = transformation.value.getMaxScaleOnAxis().clamp(0.35, 2.6);
    final x = node.offset.dx + nodeWidth / 2;
    final y = node.offset.dy + nodeHeight / 2;
    final translation = Matrix4.translationValues(
      viewport.width / 2 - x * scale,
      viewport.height / 2 - y * scale,
      0,
    );
    transformation.value =
        translation * Matrix4.diagonal3Values(scale, scale, 1);
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

  // ==================== ZOOM / VIEWPORT ====================

  void updateViewport(Size size) {
    if (size.isEmpty || size == viewportSize) return;
    viewportSize = size;
  }

  /// ປັບຜັງໃຫ້ເຫັນເຕັມ viewport ຄັ້ງທຳອິດ
  void maybeAutoFit() {
    if (_didAutoFit || nodes.isEmpty || viewportSize.isEmpty) return;
    _didAutoFit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => fitToScreen());
  }

  void zoomIn() => _zoom(1.25);
  void zoomOut() => _zoom(0.8);

  /// ຊູມອ້ອມຈຸດກາງ viewport ໂດຍບໍ່ລຶບ pan ເດີມ
  void _zoom(double factor) {
    final current = transformation.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(0.35, 2.6);
    if ((next - current).abs() < 0.001) return;

    final viewport = _effectiveViewport;
    final cx = viewport.width / 2;
    final cy = viewport.height / 2;
    final zoom =
        Matrix4.translationValues(cx, cy, 0) *
        Matrix4.diagonal3Values(next / current, next / current, 1) *
        Matrix4.translationValues(-cx, -cy, 0);

    transformation.value = zoom * transformation.value;
  }

  void resetZoom() => transformation.value = Matrix4.identity();

  /// ປັບ scale/ຕຳແໜ່ງໃຫ້ຜັງທັງໝົດຢູ່ກາງ viewport
  void fitToScreen() {
    final viewport = _effectiveViewport;
    final bounds = _layoutResult.bounds;
    if (bounds.isEmpty || nodes.isEmpty) {
      resetZoom();
      return;
    }

    final scale = math
        .min(viewport.width / bounds.width, viewport.height / bounds.height)
        .clamp(0.35, 2.6);
    final dx =
        (viewport.width - bounds.width * scale) / 2 - bounds.left * scale;
    final dy =
        (viewport.height - bounds.height * scale) / 2 - bounds.top * scale;

    transformation.value =
        Matrix4.translationValues(dx, dy, 0) *
        Matrix4.diagonal3Values(scale, scale, 1);
  }

  Size get _effectiveViewport =>
      viewportSize.isEmpty ? const Size(390, 600) : viewportSize;

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
      final image = await ExportService.captureWidget(
        boundaryKey,
        pixelRatio: 1.6,
      );
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
    await ExportService.printPdf(
      bytes,
      name: 'family-tree-${family.value?.surname ?? 'root'}',
    );
  }

  Future<void> sharePdf() async {
    final bytes = await buildPdf();
    if (bytes == null) return;
    await ExportService.sharePdf(
      bytes,
      name: 'family-tree-${family.value?.surname ?? 'root'}',
    );
  }

  Future<Uint8List?> captureImage() =>
      ExportService.captureWidget(boundaryKey, pixelRatio: 2.0);

  /// ສະມາຊິກທີ່ສາມາດເປັນພໍ່ແມ່ໄດ້ (ລຸ້ນກ່ອນໜ້າ ຫຼື ເທົ່າກັນ)
  List<FamilyMember> possibleParents({
    int generation = 99,
    String? excludeId,
  }) => members
      .where(
        (m) =>
            m.id != excludeId &&
            m.generation < generation &&
            m.status != MemberStatus.deceased,
      )
      .toList();

  List<FamilyMember> possibleSpouses({
    int generation = 99,
    String? excludeId,
  }) => members
      .where((m) => m.id != excludeId && m.generation == generation)
      .toList();

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
