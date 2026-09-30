import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/chat/bindings/chat_room_binding.dart';
import '../modules/chat/views/chat_room_view.dart';
import '../modules/family_setup/bindings/family_setup_binding.dart';
import '../modules/family_setup/views/family_setup_view.dart';
import '../modules/family_tree/bindings/member_form_binding.dart';
import '../modules/family_tree/views/member_form_view.dart';
import '../modules/members/bindings/account_form_binding.dart';
import '../modules/members/bindings/member_detail_binding.dart';
import '../modules/members/views/account_form_view.dart';
import '../modules/members/views/member_detail_view.dart';
import '../modules/profile/bindings/edit_profile_binding.dart';
import '../modules/profile/bindings/family_info_binding.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/family_info_view.dart';
import '../modules/shell/bindings/shell_binding.dart';
import '../modules/shell/views/shell_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = Routes.SPLASH;

  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.FAMILY_SETUP,
      page: () => const FamilySetupView(),
      binding: FamilySetupBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.SHELL,
      page: () => const ShellView(),
      binding: ShellBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.MEMBER_DETAIL,
      page: () => const MemberDetailView(),
      binding: MemberDetailBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.MEMBER_FORM,
      page: () => const MemberFormView(),
      binding: MemberFormBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.ACCOUNT_FORM,
      page: () => const AccountFormView(),
      binding: AccountFormBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.CHAT_ROOM,
      page: () => const ChatRoomView(),
      binding: ChatRoomBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.FAMILY_INFO,
      page: () => const FamilyInfoView(),
      binding: FamilyInfoBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      transition: Transition.downToUp,
    ),
  ];

  // ສຳລັບການນຳທາງດ້ວຍ GetX
  static Future<T?>? toPage<T>(String route,
          {dynamic arguments, Map<String, String>? parameters}) =>
      Get.toNamed<T>(route, arguments: arguments, parameters: parameters);

  static Future<T?>? offAll<T>(String route, {dynamic arguments}) =>
      Get.offAllNamed<T>(route, arguments: arguments);
}
