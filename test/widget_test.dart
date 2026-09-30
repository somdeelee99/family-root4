import 'package:family_root/app/modules/shell/widgets/lazy_indexed_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(int index, List<Widget> children) => MaterialApp(
    home: Scaffold(body: LazyIndexedStack(index: index, children: children)),
  );

  // ໝາຍເຫດ: IndexedStack ເກັບໜ້າທີ່ບໍ່ໄດ້ເລືອກໄວ້ offstage ຈຶ່ງຕ້ອງໃຊ້
  // skipOffstage: false ເພື່ອກວດສອບວ່າ widget ຖືກ build ແທ້ ຫຼື ບໍ່
  testWidgets('builds only the visible tab on first frame', (tester) async {
    await tester.pumpWidget(host(0, const [Text('tab-a'), Text('tab-b')]));

    expect(find.text('tab-a', skipOffstage: false), findsOneWidget);
    expect(find.text('tab-b', skipOffstage: false), findsNothing);
  });

  testWidgets('builds a tab the first time it becomes visible', (tester) async {
    final children = <Widget>[const Text('tab-a'), const Text('tab-b')];
    await tester.pumpWidget(host(0, children));

    await tester.pumpWidget(host(1, children));

    // ທັງສອງຢູ່ໃນຕົ້ນໄມ້ແລ້ວ ແຕ່ສະເພາະ tab-b ທີ່ສະແດງຜົນ
    expect(find.text('tab-a', skipOffstage: false), findsOneWidget);
    expect(find.text('tab-b', skipOffstage: false), findsOneWidget);
    expect(find.text('tab-b'), findsOneWidget);
    expect(find.text('tab-a'), findsNothing);
  });

  testWidgets('keeps a visited tab mounted so its state survives', (tester) async {
    final children = <Widget>[const _Counter(), const Text('tab-b')];
    await tester.pumpWidget(host(0, children));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('count: 1'), findsOneWidget);

    // ອອກໄປໜ້າອື່ນແລ້ວກັບມາ - ຄ່າຕ້ອງຍັງຢູ່
    await tester.pumpWidget(host(1, children));
    await tester.pumpWidget(host(0, children));

    expect(find.text('count: 1'), findsOneWidget);
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text('count: $_count'),
      ElevatedButton(
        onPressed: () => setState(() => _count++),
        child: const Text('inc'),
      ),
    ],
  );
}
