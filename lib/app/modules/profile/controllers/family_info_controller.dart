import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/family.dart';
import '../../../data/models/family_member.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/storage_repository.dart';

/// ຂໍ້ມູນຄອບຄົວ - Admin ແກ້ໄຂໄດ້, Member ເບິ່ງໄດ້ຢ່າງດຽວ
class FamilyInfoController extends GetxController {
  final FamilyRepository _familyRepo = FamilyRepository();
  final MemberRepository _memberRepo = MemberRepository();
  final StorageRepository _storageRepo = StorageRepository();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();

  final Rxn<Family> family = Rxn<Family>();
  final RxList<FamilyMember> members = <FamilyMember>[].obs;
  final RxBool isEditing = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<File?> pickedCover = Rx<File?>(null);

  bool get isAdmin => AuthService.to.isAdmin;
  String get familyId => AuthService.to.familyId;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  void _listen() {
    if (familyId.isEmpty) return;
    _familyRepo.familyStream(familyId).listen((value) {
      family.value = value;
      if (value != null && !isEditing.value) _fill(value);
    });
    _memberRepo
        .membersStream(familyId)
        .listen((list) => members.assignAll(list));
  }

  void _fill(Family value) {
    surnameController.text = value.surname;
    nameController.text = value.name;
    descriptionController.text = value.description;
    provinceController.text = value.province ?? '';
  }

  void startEditing() {
    if (!isAdmin) {
      UiHelpers.error('ສະເພາະ Admin ຈຶ່ງແກ້ໄຂຂໍ້ມູນຄອບຄົວໄດ້');
      return;
    }
    final value = family.value;
    if (value != null) _fill(value);
    isEditing.value = true;
  }

  void cancelEditing() {
    final value = family.value;
    if (value != null) _fill(value);
    pickedCover.value = null;
    isEditing.value = false;
  }

  Future<void> pickCover() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    pickedCover.value = File(picked.path);
  }

  Future<void> save() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSaving.value = true;
    UiHelpers.loading(message: 'ກຳລັງບັນທຶກ...');
    try {
      String? coverUrl;
      if (pickedCover.value != null) {
        coverUrl =
            await _storageRepo.uploadFamilyCover(pickedCover.value!, familyId);
      }

      await _familyRepo.updateFamily(
        familyId,
        surname: surnameController.text,
        name: nameController.text,
        description: descriptionController.text,
        province: provinceController.text,
        coverUrl: coverUrl,
      );

      await _familyRepo.logActivity(
        familyId: familyId,
        userId: AuthService.to.uid,
        action: 'ອັບເດດຂໍ້ມູນຄອບຄົວ',
        detail: surnameController.text,
      );

      UiHelpers.hideLoading();
      UiHelpers.success('ອັບເດດຂໍ້ມູນຄອບຄົວສຳລັບ');
      isEditing.value = false;
      pickedCover.value = null;
    } catch (e) {
      UiHelpers.hideLoading();
      UiHelpers.error(UiHelpers.mapError(e));
    } finally {
      isSaving.value = false;
    }
  }

  int get totalMembers => members.length;

  int get maleCount => members.where((m) => m.gender.value == 'male').length;
  int get femaleCount =>
      members.where((m) => m.gender.value == 'female').length;
  int get deceasedCount => members.where((m) => m.isDeceased).length;
  int get under18Count => members.where((m) => m.isUnder18).length;

  int get generationCount =>
      members.isEmpty ? 0 : members.map((m) => m.generation).toSet().length;

  @override
  void onClose() {
    surnameController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    provinceController.dispose();
    super.onClose();
  }
}
