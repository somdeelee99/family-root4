import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/constants/app_sizes.dart';
import 'core/constants/app_strings.dart';
import 'core/services/theme_service.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class FamilyRootApp extends StatelessWidget {
  const FamilyRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return ScreenUtilInit(
      designSize: AppSizes.designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => Obx(
        () => GetMaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: themeService.lightTheme,
          darkTheme: themeService.darkTheme,
          themeMode:
              themeService.isDark.value ? ThemeMode.dark : ThemeMode.light,
          defaultTransition: Transition.cupertino,
          transitionDuration: const Duration(milliseconds: 280),
          initialRoute: Routes.SPLASH,
          getPages: AppPages.pages,
          locale: const Locale('lo', 'LA'),
          fallbackLocale: const Locale('en', 'US'),
          builder: (context, child) {
            // ຈຳກັດຂະໜາດຕົວອັກສອນ ເພື່ອຮັກສາຄວາມສວຍງາມຂອງ UI
            final mediaQuery = MediaQuery.of(context);
            final scale = mediaQuery.textScaler.scale(1.0).clamp(0.9, 1.2);
            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
