import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../core/constants/firestore_paths.dart';
import '../models/app_user.dart';
import '../models/enums.dart';

/// ຈັດການການເຂົ້າລະບົບ
/// - Google / Facebook / Apple  => ສະເພາະ Admin ຂອງຄອບຄົວ
/// - ອີແມວ + ລະຫັດຜ່ານ        => ສະເພາະ Member ທີ່ admin ສ້າງບັນຊີໃຫ້
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  static const _secure = FlutterSecureStorage();

  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ============================ Google ============================
  // google_sign_in 7.x ໃຊ້ singleton + ຕ້ອງ initialize() ກ່ອນ
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: _googleServerClientId,
    );
    _googleInitialized = true;
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleInitialized();

    try {
      // 1) ການພິສູດຕົວຕົນ (Authentication)
      final GoogleSignInAccount account = await GoogleSignIn.instance
          .authenticate(scopeHint: const ['email', 'profile']);

      // 2) ການຂໍສິດ (Authorization) ເພື່ອເອົາ accessToken
      String? accessToken;
      try {
        final clientAuth = account.authorizationClient;
        final authorization =
            await clientAuth.authorizationForScopes(const [
              'email',
              'profile',
            ]) ??
            await clientAuth.authorizeScopes(const ['email', 'profile']);
        accessToken = authorization.accessToken;
      } catch (_) {
        // ບາງແພລດຟອມບໍ່ຈຳເປັນຕ້ອງມີ accessToken (idToken ພຽງພໍສຳລັບ Firebase)
      }

      final GoogleSignInAuthentication auth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: accessToken,
      );

      final result = await _auth.signInWithCredential(credential);
      await _ensureAdminProfile(
        user: result.user!,
        provider: AuthProviderType.google,
        fallbackName: account.displayName ?? account.email,
      );
      return result;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'ຍົກເລີກການເຂົ້າລະບົບ',
        );
      }
      throw FirebaseAuthException(
        code: e.code.name,
        message: e.description ?? 'ເຂົ້າລະບົບດ້ວຍ Google ບໍ່ສຳເລັດ',
      );
    }
  }

  // ========================== Facebook ==========================
  Future<UserCredential> signInWithFacebook() async {
    final fb = FacebookLogin();
    final result = await fb.logIn(
      permissions: const [
        FacebookPermission.publicProfile,
        FacebookPermission.email,
      ],
    );

    if (result.status == FacebookLoginStatus.cancel) {
      throw FirebaseAuthException(
        code: 'aborted-by-user',
        message: 'ຍົກເລີກການເຂົ້າລະບົບ',
      );
    }
    if (result.status != FacebookLoginStatus.success ||
        result.accessToken == null) {
      throw FirebaseAuthException(
        code: 'facebook-error',
        message:
            result.error?.localizedDescription ??
            result.error?.developerMessage ??
            'ເຂົ້າລະບົບດ້ວຍ Facebook ບໍ່ສຳເລັດ',
      );
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.token,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    await _ensureAdminProfile(
      user: userCredential.user!,
      provider: AuthProviderType.facebook,
      fallbackName: userCredential.user!.displayName ?? 'Admin',
    );
    return userCredential;
  }

  // =========================== Apple ============================
  Future<UserCredential> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
      final result = await _auth.signInWithCredential(oauthCredential);

      final fullName = [
        appleCredential.givenName,
        appleCredential.familyName,
      ].where((e) => e != null && e.isNotEmpty).join(' ');

      await _ensureAdminProfile(
        user: result.user!,
        provider: AuthProviderType.apple,
        fallbackName: fullName.isEmpty ? 'Apple Admin' : fullName,
      );
      return result;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'ຍົກເລີກການເຂົ້າລະບົບ',
        );
      }
      rethrow;
    }
  }

  // ====================== Email / Password ======================
  /// ສະເພາະ member ທີ່ admin ສ້າງບັນຊີໃຫ້ (ບໍ່ມີຟັງຊັນສະໝັກສະມາຊິກເອງ)
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _registerProvider(AuthProviderType.password);
    await _touchLastSeen();
    return result;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() async {
    try {
      if (_googleInitialized) await GoogleSignIn.instance.signOut();
    } catch (_) {
      // ບໍ່ສຳຄັນ ຖ້າຜູ້ໃຫ້ບໍລິການບໍ່ມີ session
    }
    try {
      await FacebookLogin().logOut();
    } catch (_) {
      // ບໍ່ສຳຄັນ
    }
    await _auth.signOut();
  }

  // ========================= ຂໍ້ມູນຜູ້ໃຊ້ =========================
  Future<void> _ensureAdminProfile({
    required User user,
    required AuthProviderType provider,
    required String fallbackName,
  }) async {
    final ref = _firestore.doc(FirestorePaths.userDoc(user.uid));
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      // ຜູ້ໃຊ້ໃໝ່ທີ່ເຂົ້າຜ່ານໂຊເຊຍ => ເປັນ admin
      final data = AppUser(
        uid: user.uid,
        displayName: (user.displayName ?? fallbackName).trim(),
        email: user.email,
        avatarUrl: user.photoURL,
        role: UserRole.admin,
        providers: [provider],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
      ).toMap();
      await ref.set(data, SetOptions(merge: true));
    } else {
      // ບັນຊີເກົ່າ: ບໍ່ບັງຄັບປ່ຽນ role ຖ້າ admin ກຳນົດໄວ້ແລ້ວ
      await _registerProvider(provider);
      await ref.set({
        'lastSeenAt': FieldValue.serverTimestamp(),
        if (user.photoURL != null && (snapshot.data()?['avatarUrl'] == null))
          'avatarUrl': user.photoURL,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _registerProvider(AuthProviderType provider) async {
    if (uid == null) return;
    await _firestore.doc(FirestorePaths.userDoc(uid!)).set({
      'providers': FieldValue.arrayUnion([provider.value]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _touchLastSeen() async {
    if (uid == null) return;
    await _firestore.doc(FirestorePaths.userDoc(uid!)).set({
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<AppUser?> userStream(String uid) => _firestore
      .doc(FirestorePaths.userDoc(uid))
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromDoc(doc) : null);

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  Future<void> updateProfile({
    String? displayName,
    String? surname,
    String? phone,
    String? whatsapp,
    String? avatarUrl,
    DateTime? birthDate,
    String? gender,
    String? familyId,
    String? memberId,
  }) async {
    if (uid == null) return;
    await _firestore.doc(FirestorePaths.userDoc(uid!)).set({
      if (displayName != null) 'displayName': displayName.trim(),
      if (surname != null) 'surname': surname.trim(),
      if (phone != null) 'phone': phone,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (birthDate != null) 'birthDate': Timestamp.fromDate(birthDate),
      if (gender != null) 'gender': gender,
      if (familyId != null) 'familyId': familyId,
      if (memberId != null) 'memberId': memberId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (displayName != null && displayName.trim().isNotEmpty) {
      await _auth.currentUser?.updateDisplayName(displayName.trim());
    }
    if (avatarUrl != null) await _auth.currentUser?.updatePhotoURL(avatarUrl);
  }

  Future<void> updateFcmToken(String token) async {
    if (uid == null) return;
    await _firestore.doc(FirestorePaths.userDoc(uid!)).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setActiveStatus(bool active) async {
    if (uid == null) return;
    await _firestore.doc(FirestorePaths.userDoc(uid!)).set({
      'isActive': active,
      'lastSeenAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ================== ຕົວຊ່ວຍ Apple nonce ==================
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// ບັນທຶກວ່າຜູ້ໃຊ້ເຄີຍຕິດຕັ້ງ/ເຂົ້າໃຊ້ຄັ້ງທຳອິດ
  static Future<void> markFirstLaunch() =>
      _secure.write(key: 'first_launch', value: 'done');
  static Future<bool> isFirstLaunch() async =>
      (await _secure.read(key: 'first_launch')) == null;

  @visibleForTesting
  String get debugUid => uid ?? 'not-signed-in';
}
