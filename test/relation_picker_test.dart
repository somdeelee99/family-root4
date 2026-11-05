import 'package:family_root/app/data/models/family_member.dart';
import 'package:family_root/app/modules/family_tree/components/relation_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('relation picker sheet ບໍ່ overflow ເທິງໜ້າຈໍນ້ອຍ', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final members = List.generate(
      12,
      (index) => FamilyMember(
        id: 'm$index',
        familyId: 'family',
        fullName: 'ສະມາຊິກ $index',
        generation: 1,
      ),
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: RelationMultiPicker(
              label: 'ລູກ',
              icon: Icons.child_care_rounded,
              members: members,
              selectedIds: const [],
              onToggle: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('ເພີ່ມ'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
