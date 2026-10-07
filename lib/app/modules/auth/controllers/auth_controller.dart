import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/enums.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _auth = AuthService.to;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool obscure = true.obs;
  final RxBool showEmailForm = true.obs;

  // ✅ เพิ่มใหม่ - จำว่ากำลังโหลด Social ตัวไหน
  final Rxn<AuthProviderType> socialLoading = Rxn<AuthProviderType>();

  bool get isBusy => _auth.isBusy.value;

  // ✅ เพิ่มใหม่ - เช็คแยกแต่ละปุ่ม
  bool get isGoogleLoading =>
      _auth.isBusy.value && socialLoading.value == AuthProviderType.google;
  bool get isFacebookLoading =>
      _auth.isBusy.value && socialLoading.value == AuthProviderType.facebook;
  bool get isAppleLoading =>
      _auth.isBusy.value && socialLoading.value == AuthProviderType.apple;
  bool get isEmailLoading => _auth.isBusy.value && socialLoading.value == null;

  void toggleObscure() => obscure.value = !obscure.value;

  Future<void> signInWithgoogle(AuthProviderType provider) async {
    socialLoading.value = AuthProviderType.google; // ✅ เพิ่ม
    try {
      final ok = await _auth.signInWithProvider(provider);
      if (!ok) {
        UiHelpers.error(
          _auth.errorMessage.value.isEmpty
              ? AppStrings.error
              : _auth.errorMessage.value,
        );
        return;
      }
      UiHelpers.success('${provider.label} - ເຂົ້າລະບົບສຳເລັດ');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _routeAfterLogin();
    } finally {
      socialLoading.value = null; // ✅ เพิ่ม
    }
  }

  Future<void> signInWithFacebook() async {
    socialLoading.value = AuthProviderType.facebook; // ✅ เพิ่ม
    try {
      final ok = await _auth.signInWithProvider(AuthProviderType.facebook);
      if (!ok) {
        UiHelpers.error(
          _auth.errorMessage.value.isEmpty
              ? AppStrings.error
              : _auth.errorMessage.value,
        );
        return;
      }
      UiHelpers.success('Facebook - ເຂົ້າລະບົບສຳເລັດ');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _routeAfterLogin();
    } finally {
      socialLoading.value = null; // ✅ เพิ่ม
    }
  }

  Future<void> signInWithApple() async {
    socialLoading.value = AuthProviderType.apple; // ✅ เพิ่ม
    try {
      final ok = await _auth.signInWithProvider(AuthProviderType.apple);
      if (!ok) {
        UiHelpers.error(
          _auth.errorMessage.value.isEmpty
              ? AppStrings.error
              : _auth.errorMessage.value,
        );
        return;
      }
      UiHelpers.success('Apple - ເຂົ້າລະບົບສຳເລັດ');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _routeAfterLogin();
    } finally {
      socialLoading.value = null; // ✅ เพิ่ม
    }
  }

  Future<void> signInWithEmail() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    final ok = await _auth.signInWithEmail(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    if (!ok) {
      UiHelpers.error(
        _auth.errorMessage.value.isEmpty
            ? AppStrings.error
            : _auth.errorMessage.value,
      );
      return;
    }
    final user = await _auth.fetchFresh();
    if (user == null) {
      UiHelpers.error('ບໍ່ພົບຂໍ້ມູນບັນຊີ ກະລຸນາຕິດຕໍ່ Admin ຂອງຄອບຄົວ');
      await _auth.signOut();
      return;
    }
    if (!user.isActive) {
      UiHelpers.error('ບັນຊີນີ້ຖືກປິດການໃຊ້ງານ');
      await _auth.signOut();
      return;
    }
    UiHelpers.success('ຍິນດີຕ້ອນຮັບ ${user.displayName}');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _routeAfterLogin();
  }

  void _routeAfterLogin() {
    final auth = AuthService.to;
    if (!auth.hasFamily) {
      if (auth.isAdmin) {
        Get.offAllNamed(Routes.FAMILY_SETUP);
      } else {
        UiHelpers.warning(
          'ບັນຊີຂອງທ່ານຍັງບໍ່ຖືກເພີ່ມເຂົ້າຄອບຄົວ ກະລຸນາຕິດຕໍ່ Admin',
        );
      }
      return;
    }
    Get.offAllNamed(Routes.SHELL);
  }

  Future<void> forgotPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty || Validators.email(email) != null) {
      UiHelpers.warning('ກະລຸນາປ້ອນອີແມວຂອງທ່ານກ່ອນ');
      return;
    }
    try {
      await _auth.sendPasswordReset(email);
      UiHelpers.success('ສົ່ງລິ້ງຕັ້ງລະຫັດຜ່ານໃໝ່ໄປທີ່ $email ແລ້ວ');
    } catch (e) {
      UiHelpers.error(UiHelpers.mapError(e));
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
