import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../data/models/app_user.dart';
import '../../data/models/enums.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../utils/ui_helpers.dart';
import 'notification_service.dart';

/// ສູນກາງຂອງສະຖານະການເຂົ້າລະບົບ (GetX Service)
class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final AuthRepository _authRepo = AuthRepository();
  final UserRepository _userRepo = UserRepository();
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  final Rxn<AppUser> user = Rxn<AppUser>();
  final RxBool isBusy = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  bool get isSignedIn => user.value != null;
  bool get isAdmin => user.value?.role.isAdmin ?? false;
  bool get isMember => !isAdmin;
  String get uid => user.value?.uid ?? '';
  String get familyId => user.value?.familyId ?? '';
  bool get hasFamily => (user.value?.familyId ?? '').isNotEmpty;
  bool get isProfileComplete => user.value?.isProfileComplete ?? false;

  Future<AuthService> init() async {
    _authSub = _authRepo.authStateChanges().listen(_onAuthStateChanged);
    return this;
  }

  void _onAuthStateChanged(User? firebaseUser) {
    _profileSub?.cancel();
    if (firebaseUser == null) {
      user.value = null;
      return;
    }
    _profileSub = _authRepo.userStream(firebaseUser.uid).listen((value) async {
      user.value = value;
      if (value != null) {
        try {
          final fid = value.familyId ?? '';
          if (fid.isNotEmpty) {
            await NotificationService.instance.subscribeToFamily(fid);
          }
          final token = NotificationService.instance.token;
          if (token != null) await _authRepo.updateFcmToken(token);
        } catch (e) {
          _log.w('sync ການແຈ້ງເຕືອນບໍ່ສຳເລັດ: $e');
        }
      }
    }, onError: (Object e) => _log.e('ດຶງຂໍ້ມູນຜູ້ໃຊ້ບໍ່ສຳເລັດ: $e'));
  }

  Future<bool> signInWithProvider(AuthProviderType provider) async {
    isBusy.value = true;
    errorMessage.value = '';
    try {
      switch (provider) {
        case AuthProviderType.google:
          await _authRepo.signInWithGoogle();
          break;
        case AuthProviderType.facebook:
          await _authRepo.signInWithFacebook();
          break;
        case AuthProviderType.apple:
          await _authRepo.signInWithApple();
          break;
        case AuthProviderType.password:
          break;
      }
      return true;
    } catch (e) {
      errorMessage.value = UiHelpers.mapError(e);
      _log.e('ເຂົ້າລະບົບບໍ່ສຳເລັດ: $e');
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    isBusy.value = true;
    errorMessage.value = '';
    try {
      await _authRepo.signInWithEmail(email: email, password: password);
      return true;
    } catch (e) {
      errorMessage.value = UiHelpers.mapError(e);
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> sendPasswordReset(String email) =>
      _authRepo.sendPasswordReset(email);

  Future<void> signOut() async {
    try {
      _profileSub?.cancel();
      _profileSub = null;

      final family = familyId;
      if (family.isNotEmpty) {
        try {
          await NotificationService.instance
              .unsubscribeFromFamily(family)
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
      }
    } finally {
      try {
        await _authRepo.signOut();
      } catch (e) {
        _log.w('signOut repo error: $e');
      } finally {
        user.value = null;
      }
    }
  }

  /// ອັບເດດຂໍ້ມູນໂປຣໄຟລ໌ຂອງຕົນເອງ
  Future<bool> updateMyProfile({
    String? displayName,
    String? surname,
    String? phone,
    String? whatsapp,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
  }) async {
    isBusy.value = true;
    try {
      await _authRepo.updateProfile(
        displayName: displayName,
        surname: surname,
        phone: phone,
        whatsapp: whatsapp,
        avatarUrl: avatarUrl,
        birthDate: birthDate,
        gender: gender,
      );
      if (displayName != null || avatarUrl != null) {
        user.value = user.value?.copyWith(
          displayName: displayName,
          avatarUrl: avatarUrl,
        );
      }
      return true;
    } catch (e) {
      errorMessage.value = UiHelpers.mapError(e);
      return false;
    } finally {
      isBusy.value = false;
    }
  }

  /// ຕັ້ງຄ່າຄອບຄົວຄັ້ງທຳອິດ (Admin ເທົ່ານັ້ນ - ຕ້ອງປ້ອນນາມສະກຸນ)
  Future<bool> attachFamily(String newFamilyId, {String? surname}) async {
    if (uid.isEmpty) return false;
    try {
      await _authRepo.updateProfile(familyId: newFamilyId, surname: surname);
      user.value = user.value?.copyWith(
        familyId: newFamilyId,
        surname: surname,
      );
      return true;
    } catch (e) {
      errorMessage.value = UiHelpers.mapError(e);
      return false;
    }
  }

  Future<AppUser?> fetchFresh() async {
    if (uid.isEmpty) return null;
    final fresh = await _userRepo.fetch(uid);
    if (fresh != null) user.value = fresh;
    return fresh;
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.onClose();
  }
}
