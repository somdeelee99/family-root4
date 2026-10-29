# Family Root — ເຊັກລິສຕ໌ຂຶ້ນ Play Store (Production)

> ອັບເດດ: 29 ຕຸລາ 2026
> ເອກະສານນີ້ສະຫຼຸບສິ່ງທີ່ແກ້ໄຂແລ້ວ ແລະ ສິ່ງທີ່ຕ້ອງເຮັດໃນ Play Console / Firebase Console.

## 1. ສະຖານະຫຼັກ

| ຫົວຂໍ້ | ສະຖານະ | ໝາຍເຫດ |
| --- | --- | --- |
| Target SDK 36 (Android 16) | ✅ | `targetSdk = 36` ຜ່ານເງື່ອນໄຂ Play ປີ 2026 |
| AAB + 64-bit | ✅ | `flutter build appbundle --release` |
| Release signing | ✅ ແກ້ແລ້ວ | ບໍ່ fallback ໄປ debug key ອີກ |
| Account deletion ໃນແອັບ | ✅ ແກ້ແລ້ວ | ໂປຣໄຟລ໌ → ລຶບບັນຊີ |
| Account deletion ທາງເວັບ | ⚠️ ຕ້ອງ deploy | `web/delete-account.html` |
| Privacy policy URL | ⚠️ ຕ້ອງ deploy | `web/privacy.html` |
| Terms of use | ⚠️ ຕ້ອງ deploy | `web/terms.html` |
| Data Safety form | ⚠️ ຕ້ອງປະກາດ | ຕ້ອງກົງກັບຂໍ້ມູນທີ່ເກັບ |
| Ads declaration | ⚠️ ຕ້ອງປະກາດ "No ads" | AD_ID ຖືກ remove ແລ້ວ |
| UGC (chat/ຮູບ) moderation | ✅ ແກ້ແລ້ວ | ມີລາຍງານ + ບລັອກໃນຫ້ອງແຊັດ |
| Cloud Functions region | ✅ ແກ້ແລ້ວ | client ໃຊ້ `asia-southeast1` |
| Firestore/Storage rules | ✅ ປັບປຸງ | Storage ຈຳກັດສະມາຊິກຄອບຄົວ |
| Google Sign-In SHA-1 ສຳລັບ Play | ⚠️ ຕ້ອງເພີ່ມ | ຕ້ອງໃສ່ SHA-1 ຂອງ Play App Signing |

## 2. ສິ່ງທີ່ແກ້ໄຂໃນໂຄດແລ້ວ

1. **Cloud Functions region**
   - ກ່ອນນີ້ client ເອີ້ນ `us-central1` ແຕ່ function deploy ຢູ່ `asia-southeast1`
     ເຮັດໃຫ້ `createMemberAccount` / `deleteUserAccount` ໃຊ້ບໍ່ໄດ້.
   - ແກ້ເປັນ `FirebaseFunctions.instanceFor(region: 'asia-southeast1')`.

2. **ລຶບບັນຊີຕົນເອງ (Play Data deletion policy)**
   - ເພີ່ມ `deleteMyAccount()` ໃນ `CloudFunctionService`.
   - ເພີ່ມເມນູ **ໂປຣໄຟລ໌ → ລຶບບັນຊີ**.
   - Cloud Function `deleteUserAccount` ອະນຸຍາດໃຫ້ລຶບຕົນເອງ,
     ລຶບ Auth + ໂປຣໄຟລ໌ + ຮູບ, ແລະ ໂອນສິດເຈົ້າຄອບຄົວຖ້າຈຳເປັນ.

3. **ແກ້ bug ລຶບສະມາຊິກ**
   - ເດີມລຶບ `users/{uid}` ກ່ອນແລ້ວຈຶ່ງເອີ້ນ Cloud Function; function ຫາ target ບໍ່ພົບ
     ເຮັດໃຫ້ Auth account ຄ້າງຢູ່.
   - ປັບໃຫ້ Cloud Function ເຮັດວຽກກ່ອນ ແລະ ບໍ່ decrement `memberCount`
     (ເພາະ `memberCount` ນັບ node ໃນຜັງ).

4. **Release signing**
   - ເອົາ fallback `signingConfigs.getByName("debug")` ອອກ.
   - ຖ້າ `android/key.properties` ຫາຍ release build ຈະ fail ແທນທີ່ຈະອັບ APK
     ທີ່ sign ດ້ວຍ debug key.

5. **AndroidManifest**
   - `android:allowBackup="false"`, `usesCleartextTraffic="false"`.
   - ໃຊ້ `@string/app_name` ແທນ label ຄົງທີ່.
   - ເພີ່ມ FCM default channel/icon.
   - ເອົາ `com.google.android.gms.permission.AD_ID` ອອກ (ແອັບບໍ່ມີໂຄສະນາ).

6. **Storage rules**
   - ຮູບໃນ `families/{familyId}/**` ອ່ານໄດ້ສະເພາະສະມາຊິກຄອບຄົວດຽວກັນ.

7. **ໜ້ານະໂຍບາຍ / ລຶບບັນຊີ / ຂໍ້ກຳນົດ**
   - `web/privacy.html`
   - `web/delete-account.html`
   - `web/terms.html`
   - ລິ້ງໃນແອັບຢູ່ ໂປຣໄຟລ໌ → ຕັ້ງຄ່າ.

## 3. ສິ່ງທີ່ຕ້ອງເຮັດກ່ອນອັບຂຶ້ນ Production

### 3.1 ແກ້ໄຂກ່ອນ deploy

- [ ] ປ່ຽນ `your-email@example.com` ໃນ `web/privacy.html`, `web/terms.html`,
      `web/delete-account.html` ໃຫ້ເປັນອີເມວຕິດຕໍ່ຈິງ.
- [ ] ກວດວ່າ `https://familyroot-26df8.web.app/privacy.html` ແລະ
      `/delete-account.html` ເປີດໄດ້ຫຼັງ deploy hosting.
      ຖ້າໃຊ້ custom domain ໃຫ້ແກ້ URL ໃນ
      `lib/app/modules/profile/controllers/profile_controller.dart`.
- [ ] Deploy:
      ```bash
      firebase deploy --only functions,firestore:rules,storage,hosting
      ```
- [ ] ກວດວ່າ Cloud Functions ຢູ່ region `asia-southeast1` ແລະ ມີ 5 ຟັງຊັນ.
- [ ] ທົດສອບລຶບບັນຊີຕົນເອງໃນ Internal testing ກ່ອນ.

### 3.2 Play Console

- [ ] **App content → Data safety**: ປະກາດຂໍ້ມູນຕາມຄວາມຈິງ
      (ຊື່, ອີເມວ, ເບີໂທ, ຮູບ, ຂໍ້ຄວາມ, ຂໍ້ມູນຄອບຄົວ, device token, analytics/crash).
      ລະບຸວ່າເຂົ້າລະບົບຜ່ານ Google/Facebook/Apple.
- [ ] **Ads**: ເລືອກ "No ads".
- [ ] **Content rating**: ຕອບແບບສອບຖາມ.
- [ ] **Target audience**: ຖ້າບໍ່ແມ່ນແອັບສຳລັບເດັກ ໃຫ້ເລືອກ 13+ ແລະ
      ບໍ່ລະບຸວ່າເປັນແອັບສຳລັບເດັກ.
- [ ] **Privacy policy**: ໃສ່ URL `.../privacy.html`.
- [ ] **Data deletion**: ໃສ່ URL `.../delete-account.html` ແລະ ອະທິບາຍວ່າ
      ລຶບໄດ້ໃນແອັບ (ໂປຣໄຟລ໌ → ລຶບບັນຊີ).
- [ ] **App access**: ໃຫ້ reviewer ບັນຊີທົດສອບ (email/password) ເພາະແອັບຕ້ອງ login.
- [ ] **Advertising ID**: ຖ້າ Play ຖາມ ໃຫ້ຕອບວ່າບໍ່ໃຊ້.

### 3.3 ການ sign ແລະ Google Sign-In

- [ ] ສຳຮອງ `android/upload-keystore.jks` ແລະ `key.properties` ໄວ້ບ່ອນປອດໄພ
      (ຢ່າ commit; `.gitignore` ກັນໄວ້ແລ້ວ).
- [ ] ປ່ຽນລະຫັດ keystore ຈາກ `1122334455` ເປັນລະຫັດທີ່ແຂງແຮງ
      (ຖ້າຍັງບໍ່ໄດ້ອັບຂຶ້ນ Play; ຖ້າອັບແລ້ວ ຢ່າປ່ຽນແບບບໍ່ໄດ້).
- [ ] ໃນ Play Console → App integrity → App signing:
      ຄັດລອກ **SHA-1** ແລະ **SHA-256** ຂອງ Play App Signing.
- [ ] ໃນ Firebase Console → Project settings → Android app:
      ເພີ່ມ SHA-1/SHA-256 ຂອງ Play App Signing ແລະ ຂອງ upload key.
      ຖ້າບໍ່ເພີ່ມ Google Sign-In ຈະໄດ້ error `DEVELOPER_ERROR` ໃນ production.
- [ ] ດາວໂຫຼດ `google-services.json` ໃໝ່ຫຼັງເພີ່ມ SHA ແລ້ວ build ໃໝ່.

### 3.4 Firebase / ຄວາມປອດໄພ

- [ ] ຈຳກັດ API key ໃນ Google Cloud Console (Android app + package name + SHA-1).
- [ ] ເປີດ **Firebase App Check** ສຳລັບ Firestore/Storage/Functions ຖ້າເປັນໄປໄດ້.
- [ ] ກວດ **Firestore rules** ວ່າ deploy ລຸ້ນລ່າສຸດແລ້ວ.
- [ ] ກວດວ່າ `firebase_options.dart` ຂອງ web/macOS/windows ຍັງຊີ້ໄປ
      project `familytree-b4d81` ຄົນລະ project ກັບ Android (`familyroot-26df8`).
      ຖ້າຈະເຜີຍແຜ່ web ຕ້ອງ run `flutterfire configure` ໃໝ່.

## 4. ຄວາມສ່ຽງທີ່ຍັງເຫຼືອ (ແນະນຳໃຫ້ແກ້)

### 4.1 ການເຂົ້າຮ່ວມຄອບຄົວດ້ວຍນາມສະກຸນ

`firestore.rules` ອະນຸຍາດໃຫ້ຜູ້ໃຊ້ທີ່ login ແລ້ວຕັ້ງ `familyId` ຂອງຕົນເອງ
ໄປຫາຄອບຄົວໃດກໍໄດ້ທີ່ບໍ່ແມ່ນ owner, ໂດຍບໍ່ມີການອະນຸມັດ.
ປະຈຸບັນແອັບຫາຄອບຄົວດ້ວຍນາມສະກຸນ ແລະ `families` ອະນຸຍາດ `list` ໃຫ້
ທຸກຄົນທີ່ login ໄດ້. ຜູ້ບໍ່ຫວັງດີສາມາດຄົ້ນຫາ ແລະ ເຂົ້າຮ່ວມຄອບຄົວຄົນອື່ນ
ເພື່ອອ່ານຂໍ້ມູນ/ແຊັດ.

**ແນະນຳ:** ໃຊ້ invite code ຫຼື join request ທີ່ Admin ອະນຸມັດ,
ແລະ ຍ້າຍການຄົ້ນຫານາມສະກຸນໄປ Cloud Function ເພື່ອບໍ່ໃຫ້ `list` ທັງ collection.
(ຍັງບໍ່ໄດ້ແກ້ໃນຮອບນີ້ ເພາະປ່ຽນ flow ການໃຊ້ງານ.)

### 4.2 UGC (ຂໍ້ຄວາມ + ຮູບ)

Google Play ມີນະໂຍບາຍສຳລັບແອັບທີ່ມີ User Generated Content:
ຕ້ອງມີການລາຍງານ/flag, ການບລັອກຜູ້ໃຊ້ ແລະ ການກວດສອບເນື້ອຫາ.

ສະຖານະ: ✅ **ເພີ່ມແລ້ວ** — ໃນຫ້ອງແຊັດ ກົດ `⋮` ຈະມີ:
- **ລາຍງານຜູ້ໃຊ້** → ເລືອກເຫດຜົນ + ລາຍລະອຽດ, ບັນທຶກໃນ `reports/{reportId}`.
- **ບລັອກຜູ້ໃຊ້ / ຍົກເລີກການບລັອກ** → ເກັບໃນ
  `users/{uid}/blockedUsers/{blockedUid}`; ຂໍ້ຄວາມຂອງຜູ້ຖືກບລັອກຈະຖືກເຊື່ອງ
  ແລະ ບໍ່ສາມາດສົ່ງຫາໄດ້. ຜູ້ຖືກບລັອກຈະຫາຍຈາກລາຍຊື່ແຊັດ.

**ຕ້ອງເຮັດຕໍ່:** ຍັງບໍ່ມີໜ້າສຳລັບ admin ອ່ານ `reports` (rules ບລັອກ client ອ່ານ).
ໃຫ້ເບິ່ງຜ່ານ Firebase Console ຫຼື ສ້າງ admin tool ພາຍຫຼັງ.


### 4.3 ການເກັບປະຫວັດແຊັດ

ແອັບບໍ່ອະນຸຍາດໃຫ້ລຶບຂໍ້ຄວາມ. ຖ້າຜູ້ໃຊ້ລຶບບັນຊີ, ຂໍ້ຄວາມອາດຍັງຄ້າງ
ໃນປະຫວັດຄອບຄົວ. ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວໄດ້ອະທິບາຍໄວ້ແລ້ວ;
ຖ້າຕ້ອງການໃຫ້ລຶບທັງໝົດ ຕ້ອງເພີ່ມ logic ໃນ Cloud Function.

## 5. Build ແລະ ກວດກ່ອນອັບ

```bash
# 1) ກວດ code
flutter analyze

# 2) ທົດສອບ
flutter test

# 3) Build AAB
flutter build appbundle --release

# ໄຟລ໌ຢູ່:
# build/app/outputs/bundle/release/app-release.aab
```

- [ ] ອັບ AAB ເຂົ້າ **Internal testing** ກ່ອນ.
- [ ] ທົດສອບ: ສ້າງຄອບຄົວ, ເຂົ້າລະບົບ Google/Facebook/Apple,
      ແຊັດ, ແຈ້ງເຕືອນ, ລຶບບັນຊີ, ລຶບສະມາຊິກ.
- [ ] ເບິ່ງ **Pre-launch report** ຂອງ Play (crash, accessibility, 16 KB page size).
- [ ] ກວດວ່າ target SDK ທີ່ Play ສະແດງເປັນ 36 ແລະ ບໍ່ມີ warning ເລື່ອງ
      permissions ທີ່ບໍ່ໄດ້ປະກາດ.

## 6. ໝາຍເຫດສຳລັບນັກພັດທະນາ

- ຢ່າ commit `android/key.properties` ຫຼື `*.jks` (ຖືກ ignore ແລ້ວ).
- ຢ່າໃຊ້ລະຫັດ keystore ດຽວກັນກັບຕົວຢ່າງ/ໂຄງການອື່ນ.
- ຖ້າປ່ຽນ package name ຕ້ອງອັບເດດ `google-services.json`,
  `firebase_options.dart`, Facebook App ID ແລະ OAuth redirect ໃຫ້ກົງກັນ.
