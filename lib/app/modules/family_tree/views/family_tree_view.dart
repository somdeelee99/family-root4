import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/export_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/member_tile.dart';
import '../../../routes/app_routes.dart';
import '../controllers/family_tree_controller.dart';
import '../widgets/member_detail_sheet.dart';
import '../widgets/tree_connector_painter.dart';
import '../widgets/tree_controls.dart';
import '../widgets/tree_node_card.dart';

/// ໜ້າຜັງໄມ້ຄອບຄົວ
/// - Admin: ເບິ່ງແບບເຕັມ (zoom/pan) + ເພີ່ມ / ແກ້ໄຂ / ລຶບ + Export PDF
/// - Member: ເບິ່ງແບບ read-only + ຄົ້ນຫາ + ເບິ່ງລາຍລະອຽດ
class FamilyTreeView extends GetView<FamilyTreeController> {
  const FamilyTreeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(),
            Obx(
              () => controller.isTreeMode.value ? Expanded(child: _treeCanvas()) : Expanded(child: _listView()),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => controller.isAdmin
            ? FloatingActionButton.extended(
                heroTag: 'family_tree_fab',
                onPressed: () => Get.toNamed(Routes.MEMBER_FORM),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add_rounded),
                label: const Text('ເພີ່ມສະມາຊິກ'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // ==================== ຫົວໜ້າ ====================
  Widget _header() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.account_tree_rounded, size: 18.sp, color: Colors.white),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.familyTree,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.members.length} ຄົນ • ${controller.family.value?.surname ?? ''}',
                        style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              // ສະລັບ ຜັງ / ລາຍການ
              Obx(
                () => _toggle(
                  isTree: controller.isTreeMode.value,
                  onChanged: (value) => controller.isTreeMode.value = value,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 22.sp, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                onSelected: (value) {
                  switch (value) {
                    case 'pdf':
                      controller.exportPdf();
                      break;
                    case 'share':
                      controller.sharePdf();
                      break;
                    case 'image':
                      _saveImage();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'pdf',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.picture_as_pdf_rounded),
                      title: Text(AppStrings.exportPdf),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.ios_share_rounded),
                      title: Text('ແຊຣ໌ເປັນໄຟລ໌ PDF'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'image',
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.image_rounded),
                      title: Text(AppStrings.exportImage),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // ---------- ຄົ້ນຫາ ----------
          TextField(
            controller: controller.searchController,
            onSubmitted: (_) => controller.focusFirstMatch(),
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: AppStrings.searchMember,
              isDense: true,
              prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
              suffixIcon: Obx(
                () => controller.query.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: controller.clearSearch,
                        icon: Icon(Icons.close_rounded, size: 18.sp),
                      ),
              ),
            ),
          ),
          // ---------- ແຈ້ງເຕືອນ read-only ສຳລັບ member ----------
          Obx(
            () => controller.isAdmin
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 14.sp, color: AppColors.accent),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            AppStrings.readOnlyBanner,
                            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9A6A11)),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _toggle({required bool isTree, required ValueChanged<bool> onChanged}) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          _toggleItem(Icons.account_tree_rounded, isTree, () => onChanged(true)),
          _toggleItem(Icons.list_alt_rounded, !isTree, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _toggleItem(IconData icon, bool active, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: active
                ? [BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.1), blurRadius: 6)]
                : null,
          ),
          child: Icon(icon, size: 17.sp, color: active ? AppColors.primary : AppColors.textHint),
        ),
      );

  // ==================== ຜັງ (canvas) ====================
  Widget _treeCanvas() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.members.isEmpty) {
      return EmptyState(
        title: AppStrings.noMembers,
        description: controller.isAdmin
            ? 'ເລີ່ມສ້າງຜັງໄມ້ຄອບຄົວໂດຍການເພີ່ມສະມາຊິກຄົນທຳອິດ'
            : 'Admin ຍັງບໍ່ໄດ້ເພີ່ມສະມາຊິກໃນຜັງ',
        icon: Icons.account_tree_outlined,
        actionLabel: controller.isAdmin ? AppStrings.addNode : null,
        onAction: controller.isAdmin ? () => Get.toNamed(Routes.MEMBER_FORM) : null,
      );
    }

    final size = _canvasSize();

    return Stack(
      children: [
        InteractiveViewer(
          transformationController: controller.transformation,
          minScale: 0.35,
          maxScale: 2.6,
          boundaryMargin: EdgeInsets.all(220.w),
          constrained: false,
          child: RepaintBoundary(
            key: controller.boundaryKey,
            child: Container(
              width: size.width,
              height: size.height,
              color: AppColors.background,
              child: Stack(
                children: [
                  // ວາດເສັ້ນເຊື່ອມກ່ອນ (ຢູ່ໃຕ້ node)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TreeConnectorPainter(
                        nodes: controller.nodes,
                        selectedId: controller.selected.value?.id,
                      ),
                    ),
                  ),
                  // ວາດ node
                  for (final node in controller.nodes)
                    Positioned(
                      left: node.offset.dx,
                      top: node.offset.dy,
                      child: TreeNodeCard(
                        member: node.member,
                        isSelected: controller.selected.value?.id == node.member.id,
                        isHighlighted: node.isHighlighted,
                        onTap: () {
                          controller.selected.value = node.member;
                          showMemberDetailSheet(
                            node.member,
                            allMembers: controller.members,
                            onChanged: controller.refreshSelected,
                          );
                        },
                        onLongPress: controller.isAdmin
                            ? () => Get.toNamed(Routes.MEMBER_FORM, arguments: {'memberId': node.member.id})
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // ---------- ປຸ່ມຊູມ ----------
        Positioned(
          right: 14.w,
          bottom: 96.h,
          child: TreeControls(
            onZoomIn: controller.zoomIn,
            onZoomOut: controller.zoomOut,
            onReset: controller.resetZoom,
            onCenter: controller.focusFirstMatch,
          ),
        ),

        // ---------- ຄຳອະທິບາຍ ----------
        Positioned(
          left: 14.w,
          bottom: 16.h,
          child: const TreeLegend(),
        ),
      ],
    );
  }

  Size _canvasSize() {
    if (controller.nodes.isEmpty) return const Size(800, 800);
    double maxX = 0, maxY = 0;
    for (final node in controller.nodes) {
      if (node.offset.dx > maxX) maxX = node.offset.dx;
      if (node.offset.dy > maxY) maxY = node.offset.dy;
    }
    return Size(
      maxX + FamilyTreeController.nodeWidth + FamilyTreeController.canvasPadding,
      maxY + FamilyTreeController.nodeHeight + 140,
    );
  }

  // ==================== ໂໝດລາຍການ ====================
  Widget _listView() {
    if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
    final grouped = controller.groupedByGeneration;
    if (grouped.isEmpty) {
      return const EmptyState(title: AppStrings.noMembers, icon: Icons.groups_outlined);
    }

    final query = controller.query.value.toLowerCase();

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 90.h),
      physics: const BouncingScrollPhysics(),
      children: [
        for (final entry in grouped.entries) ...[
          _generationHeader(entry.key, entry.value.length),
          SizedBox(height: 10.h),
          for (final member in entry.value)
            if (query.isEmpty ||
                member.fullName.toLowerCase().contains(query) ||
                (member.nickname ?? '').toLowerCase().contains(query))
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: MemberTile(
                  member: member,
                  onTap: () {
                    controller.selected.value = member;
                    showMemberDetailSheet(
                      member,
                      allMembers: controller.members,
                      onChanged: controller.refreshSelected,
                    );
                  },
                ),
              ),
          SizedBox(height: 14.h),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _generationHeader(int generation, int count) => Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 5.h),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              'ລຸ້ນທີ $generation',
              style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$count ຄົນ',
            style: TextStyle(fontSize: 11.5.sp, color: AppColors.textSecondary),
          ),
        ],
      );

  /// ບັນທຶກຜັງເປັນຮູບ PNG ໄປໃນເຄື່ອງ
  Future<void> _saveImage() async {
    final bytes = await controller.captureImage();
    if (bytes == null) {
      UiHelpers.error('ບໍ່ສາມາດບັນທຶກຮູບໄດ້ ກະລຸນາລອງໃໝ່');
      return;
    }
    final path = await ExportService.saveImageToDevice(
      bytes,
      name: 'family-tree-${controller.family.value?.surname ?? 'root'}',
    );
    if (path == null) {
      UiHelpers.error('ບໍ່ສາມາດບັນທຶກຮູບໄດ້');
      return;
    }
    UiHelpers.success('ບັນທຶກຮູບແລ້ວ: $path');
  }
}
