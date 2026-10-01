import 'package:family_root/app/core/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// ກາດສະຖິຕິເຄີຍ overflow ເພາະ GridView ໃຊ້ childAspectRatio ຄົງທີ່
/// ເຊິ່ງບໍ່ພຽງພໍເມື່ອຂໍ້ຄວາມຍາວຂຶ້ນ ຫຼື ຂະໜາດຕົວອັກສອນເພີ່ມຂຶ້ນ.
/// ຊຸດທົດສອບນີ້ຢືນຢັນວ່າ StatCardGrid ບໍ່ overflow ອີກຕໍ່ໄປ.
void main() {
  Widget wrap(Widget child, {double textScale = 1.0}) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  StatCard card(String label, int index) => StatCard(
    label: label,
    value: 1234 + index,
    icon: Icons.people_alt_rounded,
    color: const Color(0xFF10513F),
    index: index,
  );

  const longLabels = [
    'ສະມາຊິກທັງໝົດໃນຄອບຄົວ',
    'ອາຍຸຕຳກວ່າ 18 ປີ',
    'ເພດຊາຍ',
    'ເພດຍິງ',
    'ສະມາຊິກທີ່ເສຍຊີວິດ',
    'ສະມາຊິກທີ່ຍັງມີຊີວິດ',
  ];

  testWidgets('grid lays out 6 cards without overflow', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(StatCardGrid(cards: [for (var i = 0; i < longLabels.length; i++) card(longLabels[i], i)])),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(StatCard), findsNWidgets(6));
  });

  testWidgets('grid does not overflow with enlarged text', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(
        StatCardGrid(cards: [for (var i = 0; i < longLabels.length; i++) card(longLabels[i], i)]),
        textScale: 1.2, // ຄ່າສູງສຸດທີ່ແອັບອະນຸຍາດ (get app builder ຈຳກັດໄວ້ 1.2)
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('cards in the same row share the tallest height', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(
        StatCardGrid(
          cards: [
            card('ສັ້ນ', 0),
            card('ປ້າຍຍາວຫຼາຍອັນນີ້ຈະຕັດສອງແຖວແນ່ນອນເພື່ອທົດສອບຄວາມສູງ', 1),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final first = tester.getSize(find.byType(StatCard).at(0));
    final second = tester.getSize(find.byType(StatCard).at(1));
    expect(first.height, second.height);
  });
}
