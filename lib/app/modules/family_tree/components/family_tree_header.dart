import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/export_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../controllers/family_tree_controller.dart';

/// ຫົວໜ້າຂອງໜ້າຜັງໄມ້ຄອບຄົວ:
/// ຊື່ໜ້າ, ຈຳນວນສະມາຊິກ, ສະລັບ ຜັງ/ລາຍການ, ເມນູ export ແລະ ຊ່ອງຄົ້ນຫາ.
class FamilyTreeHeader extends StatelessWidget {
  const FamilyTreeHeader({super.key, required this.controller});

  final FamilyTreeController controller;

  @override
  Widget build(BuildContext context) {
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
                child: Icon(
                  Icons.account_tree_rounded,
                  size: 18.sp,
                  color: Colors.white,
                ),
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
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => _ModeToggle(
                  isTree: controller.isTreeMode.value,
                  onChanged: (value) => controller.isTreeMode.value = value,
                ),
              ),
              _exportMenu(),
            ],
          ),
          SizedBox(height: 12.h),
          _searchField(),
          Obx(
            () => controller.isAdmin
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14.sp,
                          color: AppColors.accent,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            AppStrings.readOnlyBanner,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF9A6A11),
                            ),
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

  Widget _exportMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 22.sp,
        color: AppColors.textSecondary,
      ),
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
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.picture_as_pdf_rounded),
            title: Text(AppStrings.exportPdf),
          ),
        ),
        PopupMenuItem(
          value: 'share',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.ios_share_rounded),
            title: Text('ແຊຣ໌ເປັນໄຟລ໌ PDF'),
          ),
        ),
        PopupMenuItem(
          value: 'image',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.image_rounded),
            title: Text(AppStrings.exportImage),
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.75)),
      ),
      child: TextField(
        controller: controller.searchController,
        onSubmitted: (_) => controller.focusFirstMatch(),
        textInputAction: TextInputAction.search,
        style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: AppStrings.searchMember,
          hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColors.textHint),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20.sp,
            color: AppColors.primary,
          ),
          suffixIcon: Obx(
            () => controller.query.value.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'ລ້າງຄຳຄົ້ນຫາ',
                    onPressed: controller.clearSearch,
                    icon: Icon(Icons.close_rounded, size: 18.sp),
                  ),
          ),
          isDense: true,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.2),
          ),
        ),
      ),
    );
  }

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

/// ສະລັບ ຜັງ / ລາຍການ
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isTree, required this.onChanged});

  final bool isTree;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          _item(Icons.account_tree_rounded, isTree, () => onChanged(true)),
          _item(Icons.list_alt_rounded, !isTree, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _item(IconData icon, bool active, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30.r),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: active
            ? [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                  blurRadius: 6,
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: 17.sp,
        color: active ? AppColors.primary : AppColors.textHint,
      ),
    ),
  );
}
