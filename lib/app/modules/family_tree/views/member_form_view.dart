import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/enums.dart';
import '../controllers/member_form_controller.dart';
import '../widgets/relation_picker.dart';

/// ຟອມເພີ່ມ / ແກ້ໄຂ ສະມາຊິກໃນຜັງ (Admin)
class MemberFormView extends GetView<MemberFormController> {
  const MemberFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
            Text(controller.isEdit ? AppStrings.editNode : AppStrings.addNode),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: controller.formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _avatarPicker(),
                    SizedBox(height: 20.h),
                    _card(
                      title: 'ຂໍ້ມູນພື້ນຖານ',
                      icon: Icons.person_outline_rounded,
                      children: [
                        AppTextField(
                          controller: controller.nameController,
                          label: 'ຊື່ ແລະ ນາມສະກຸນ',
                          hint: 'ຕົວຢ່າງ: ສົມພອນ ວົງສະຫວັນ',
                          prefixIcon: Icons.person_outline_rounded,
                          isRequired: true,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              Validators.required(v, field: 'ຊື່ ແລະ ນາມສະກຸນ'),
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.nicknameController,
                          label: 'ຊື່ຫຼິ້ນ',
                          hint: 'ຕົວຢ່າງ: ພອນ',
                          prefixIcon: Icons.emoji_emotions_outlined,
                          isOptional: true,
                        ),
                        SizedBox(height: 16.h),
                        // ---------- ເພດ ----------
                        _label('ເພດ', isRequired: true),
                        SizedBox(height: 8.h),
                        Obx(
                          () => _segmented<Gender>(
                            values: const [
                              Gender.male,
                              Gender.female,
                              Gender.other
                            ],
                            selected: controller.gender.value,
                            labelOf: (g) => g.label,
                            iconOf: (g) => g == Gender.female
                                ? Icons.female_rounded
                                : g == Gender.male
                                    ? Icons.male_rounded
                                    : Icons.transgender_rounded,
                            onChanged: (value) =>
                                controller.gender.value = value,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // ---------- ວັນເກີດ ----------
                        AppDateField(
                          label: 'ວັນເກີດ',
                          value: controller.birthDate.value,
                          isOptional: true,
                          onTap: () => _pickDate(
                            initial: controller.birthDate.value,
                            lastDate: DateTime.now(),
                            onPicked: (date) =>
                                controller.birthDate.value = date,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // ---------- ລຸ້ນ ----------
                        _generationField(),
                        SizedBox(height: 8.h),
                        Text(
                          'ແນະນຳ: ລຸ້ນຈະຖືກຄຳນວນອັດຕະໂນມັດ ເມື່ອກຳນົດພໍ່ແມ່ (ລູກ = ລຸ້ນພໍ່ແມ່ + 1)',
                          style: TextStyle(
                              fontSize: 11.sp, color: AppColors.textHint),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _card(
                      title: 'ສະຖານະ',
                      icon: Icons.favorite_border_rounded,
                      children: [
                        Obx(
                          () => _segmented<MemberStatus>(
                            values: MemberStatus.values,
                            selected: controller.status.value,
                            labelOf: (s) => s.shortLabel,
                            iconOf: (s) => s == MemberStatus.alive
                                ? Icons.favorite_rounded
                                : s == MemberStatus.deceased
                                    ? Icons.spa_rounded
                                    : Icons.heart_broken_rounded,
                            onChanged: (value) =>
                                controller.status.value = value,
                          ),
                        ),
                        Obx(
                          () => controller.status.value != MemberStatus.deceased
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.only(top: 16.h),
                                  child: AppDateField(
                                    label: 'ວັນເສຍຊີວິດ',
                                    value: controller.deathDate.value,
                                    isRequired: true,
                                    icon: Icons.spa_rounded,
                                    onTap: () => _pickDate(
                                      initial: controller.deathDate.value,
                                      onPicked: (date) =>
                                          controller.deathDate.value = date,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    // ---------- ຄວາມສຳພັນ ----------
                    _card(
                      title: AppStrings.relationships,
                      icon: Icons.hub_outlined,
                      children: [
                        Obx(
                          () => Column(
                            children: [
                              RelationSinglePicker(
                                label: AppStrings.father,
                                icon: Icons.man_rounded,
                                members: controller.parentCandidates,
                                selectedId: controller.fatherId.value,
                                onChanged: (id) =>
                                    controller.fatherId.value = id,
                              ),
                              SizedBox(height: 14.h),
                              RelationSinglePicker(
                                label: AppStrings.mother,
                                icon: Icons.woman_rounded,
                                members: controller.parentCandidates,
                                selectedId: controller.motherId.value,
                                onChanged: (id) =>
                                    controller.motherId.value = id,
                              ),
                              SizedBox(height: 14.h),
                              RelationMultiPicker(
                                label: AppStrings.spouse,
                                icon: Icons.favorite_rounded,
                                members: controller.sameGenerationCandidates,
                                selectedIds: controller.spouseIds,
                                onToggle: controller.toggleSpouse,
                                emptyHint: 'ຕ້ອງມີສະມາຊິກລຸ້ນດຽວກັນກ່ອນ',
                              ),
                              SizedBox(height: 14.h),
                              RelationMultiPicker(
                                label: AppStrings.children,
                                icon: Icons.child_care_rounded,
                                members: controller.childCandidates,
                                selectedIds: controller.childIds,
                                onToggle: controller.toggleChild,
                                emptyHint:
                                    'ຕ້ອງມີສະມາຊິກລຸ້ນຖັດໄປກ່ອນ ຫຼື ປັບລຸ້ນຂອງຄົນນີ້',
                              ),
                              SizedBox(height: 14.h),
                              RelationMultiPicker(
                                label: AppStrings.siblings,
                                icon: Icons.people_outline_rounded,
                                members: controller.sameGenerationCandidates,
                                selectedIds: controller.siblingIds,
                                onToggle: controller.toggleSibling,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _card(
                      title: 'ຂໍ້ມູນຕິດຕໍ່',
                      icon: Icons.contact_phone_outlined,
                      children: [
                        AppTextField(
                          controller: controller.phoneController,
                          label: AppStrings.phone,
                          hint: '020 xxxx xxxx',
                          prefixIcon: Icons.call_outlined,
                          isOptional: true,
                          keyboardType: TextInputType.phone,
                          validator: (v) => Validators.phone(v),
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.whatsappController,
                          label: AppStrings.whatsapp,
                          hint: '020 xxxx xxxx',
                          prefixIcon: Icons.chat_outlined,
                          isOptional: true,
                          keyboardType: TextInputType.phone,
                          validator: (v) => Validators.phone(v),
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.emailController,
                          label: AppStrings.email,
                          hint: 'name@email.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          isOptional: true,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v ?? '').isEmpty ? null : Validators.email(v),
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.occupationController,
                          label: 'ອາຊີບ',
                          hint: 'ຕົວຢ່າງ: ຄູສອນ',
                          prefixIcon: Icons.work_outline_rounded,
                          isOptional: true,
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.addressController,
                          label: 'ທີ່ຢູ່',
                          hint: 'ບ້ານ / ເມືອງ / ແຂວງ',
                          prefixIcon: Icons.location_on_outlined,
                          isOptional: true,
                        ),
                        SizedBox(height: 14.h),
                        AppTextField(
                          controller: controller.noteController,
                          label: 'ໝາຍເຫດ',
                          hint: 'ຂໍ້ມູນເພີ່ມເຕີມ...',
                          prefixIcon: Icons.notes_rounded,
                          isOptional: true,
                          maxLines: 3,
                          maxLength: 300,
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    // ---------- ຜູກບັນຊີ ----------
                    _card(
                      title: 'ຜູກກັບບັນຊີເຂົ້າລະບົບ',
                      icon: Icons.link_rounded,
                      children: [
                        Obx(
                          () => Column(
                            children: [
                              for (final account in controller.accounts)
                                RadioListTile<String?>(
                                  value: account.uid,
                                  groupValue: controller.linkedUserId.value,
                                  onChanged: (value) =>
                                      controller.linkedUserId.value = value,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  activeColor: AppColors.primary,
                                  title: Text(
                                    account.displayName,
                                    style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    account.email ?? account.phone ?? '',
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                              RadioListTile<String?>(
                                value: null,
                                groupValue: controller.linkedUserId.value,
                                onChanged: (value) =>
                                    controller.linkedUserId.value = null,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                activeColor: AppColors.primary,
                                title: Text(
                                  'ບໍ່ຜູກບັນຊີ (ບຸກຄົນໃນຜັງເທົ່ານັ້ນ)',
                                  style: TextStyle(
                                      fontSize: 13.5.sp,
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Obx(
        () => controller.isLoading.value
            ? const SizedBox.shrink()
            : Container(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                              minimumSize: Size.fromHeight(52.h)),
                          child: const Text(AppStrings.cancel),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: controller.isSaving.value
                              ? null
                              : controller.save,
                          icon: controller.isSaving.value
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_rounded, size: 20),
                          label: Text(controller.isEdit
                              ? AppStrings.update
                              : AppStrings.save),
                          style: FilledButton.styleFrom(
                            minimumSize: Size.fromHeight(52.h),
                            backgroundColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ==================== widgets ====================

  /// ເລືອກລຳດັບຊົ່ວຄົນ (Generation 1, 2, 3...)
  Widget _generationField() => Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(AppStrings.generation, isRequired: true),
            SizedBox(height: 7.h),
            InkWell(
              onTap: _pickGeneration,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
              child: Container(
                height: AppSizes.inputHeight.h,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd.r),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        'ລຸ້ນທີ ${controller.generation.value}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.unfold_more_rounded,
                        size: 20.sp, color: AppColors.textHint),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _avatarPicker() {
    return Center(
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: controller.chooseImageSource,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (controller.pickedImage.value != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: Image.file(
                        controller.pickedImage.value! as File,
                        width: 104.w,
                        height: 104.w,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    AppAvatar(
                      imageUrl: controller.avatarUrl.value,
                      name: controller.nameController.text.isEmpty
                          ? '?'
                          : controller.nameController.text,
                      size: 104,
                      gender: controller.gender.value,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  Positioned(
                    right: -4.w,
                    bottom: -4.h,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.camera_alt_rounded,
                          size: 15.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextButton.icon(
            onPressed: controller.chooseImageSource,
            icon: const Icon(Icons.image_outlined, size: 17),
            label: const Text(AppStrings.changePhoto),
          ),
        ],
      ),
    );
  }

  Widget _card(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg.r),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppSizes.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 16.sp, color: AppColors.primary),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _label(String text, {bool isRequired = false}) => Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          if (isRequired)
            Text(' *',
                style: TextStyle(color: AppColors.danger, fontSize: 13.sp)),
        ],
      );

  Widget _segmented<T>({
    required List<T> values,
    required T selected,
    required String Function(T) labelOf,
    required IconData Function(T) iconOf,
    required ValueChanged<T> onChanged,
  }) {
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(values[i]),
              borderRadius: BorderRadius.circular(14.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: values[i] == selected
                      ? AppColors.primary
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: values[i] == selected
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      iconOf(values[i]),
                      size: 18.sp,
                      color: values[i] == selected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      labelOf(values[i]),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: values[i] == selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickDate({
    DateTime? initial,
    DateTime? lastDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: lastDate ?? now,
      helpText: 'ເລືອກວັນທີ',
      cancelText: AppStrings.cancel,
      confirmText: 'ຕົກລົງ',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _pickGeneration() async {
    final selected = await Get.bottomSheet<int>(
      Container(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ກຳນົດລຳດັບຊົ່ວຄົນ (Generation)',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                for (var i = 1; i <= 10; i++)
                  InkWell(
                    onTap: () => Get.back(result: i),
                    borderRadius: BorderRadius.circular(30.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18.w, vertical: 11.h),
                      decoration: BoxDecoration(
                        color: controller.generation.value == i
                            ? AppColors.primary
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Text(
                        'ລຸ້ນທີ $i',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: controller.generation.value == i
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
    if (selected != null) controller.generation.value = selected;
  }
}
