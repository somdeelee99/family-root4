import 'package:family_root/app/data/models/family_member.dart';
import 'package:family_root/app/modules/family_tree/layout/tree_layout_config.dart';
import 'package:family_root/app/modules/family_tree/layout/tree_layout_engine.dart';
import 'package:family_root/app/modules/family_tree/layout/tree_layout_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = TreeLayoutEngine();
  const config = TreeLayoutConfig();

  FamilyMember person(
    String id, {
    String? father,
    String? mother,
    List<String> spouses = const [],
    List<String> children = const [],
    int generation = 1,
  }) => FamilyMember(
    id: id,
    familyId: 'family',
    fullName: id,
    fatherId: father,
    motherId: mother,
    spouseIds: spouses,
    childIds: children,
    generation: generation,
  );

  double centerX(TreeNodePosition node) =>
      node.offset.dx + TreeLayoutConfig.nodeWidth / 2;

  test('ຄູ່ຜົວເມຍຢູ່ຕິດກັນ ແລະ ລູກຢູ່ກາງພໍ່ແມ່', () {
    final result = engine.layout([
      person('F', spouses: ['M'], children: ['C1', 'C2']),
      person('M', spouses: ['F'], children: ['C1', 'C2']),
      person('C1', father: 'F', mother: 'M', generation: 2),
      person('C2', father: 'F', mother: 'M', generation: 2),
    ]);

    final byId = result.byId;
    final f = byId['F']!;
    final m = byId['M']!;
    final c1 = byId['C1']!;
    final c2 = byId['C2']!;

    expect(m.offset.dy, f.offset.dy);
    expect(
      (m.offset.dx - f.offset.dx).abs(),
      TreeLayoutConfig.nodeWidth + config.spouseGap,
    );

    expect(c1.offset.dy, c2.offset.dy);
    expect(
      (c2.offset.dx - c1.offset.dx).abs(),
      TreeLayoutConfig.nodeWidth + config.siblingGap,
    );

    final coupleCenter = (centerX(f) + centerX(m)) / 2;
    final childrenCenter = (centerX(c1) + centerX(c2)) / 2;
    expect(childrenCenter, closeTo(coupleCenter, 0.01));
  });

  test('ລູກຂອງສອງຄູ່ແຍກກັນ ບໍ່ປົນກັນ', () {
    final result = engine.layout([
      person('F1', spouses: ['M1']),
      person('M1', spouses: ['F1']),
      person('F2', spouses: ['M2']),
      person('M2', spouses: ['F2']),
      person('C1', father: 'F1', mother: 'M1', generation: 2),
      person('C2', father: 'F1', mother: 'M1', generation: 2),
      person('D1', father: 'F2', mother: 'M2', generation: 2),
      person('D2', father: 'F2', mother: 'M2', generation: 2),
    ]);

    final byId = result.byId;
    final c1 = byId['C1']!;
    final c2 = byId['C2']!;
    final d1 = byId['D1']!;
    final d2 = byId['D2']!;

    expect(c1.offset.dx, lessThan(c2.offset.dx));
    expect(c2.offset.dx, lessThan(d1.offset.dx));
    expect(d1.offset.dx, lessThan(d2.offset.dx));

    // ລະຫວ່າງກຸ່ມຕ້ອງມີ groupGap ຢ່າງໜ້ອຍ
    final gapBetweenGroups =
        d1.offset.dx - (c2.offset.dx + TreeLayoutConfig.nodeWidth);
    expect(gapBetweenGroups, greaterThanOrEqualTo(config.groupGap - 0.01));
  });

  test('ລູກທີ່ແຕ່ງງານແລ້ວ ຢູ່ຕິດຄູ່ ແລະ ລູກຂອງລາວຢູ່ໃຕ້ຄູ່', () {
    final result = engine.layout([
      person('F', spouses: ['M']),
      person('M', spouses: ['F']),
      person('C1', father: 'F', mother: 'M', generation: 2, spouses: ['S1']),
      person('S1', spouses: ['C1'], generation: 2),
      person('C2', father: 'F', mother: 'M', generation: 2),
      person('G1', father: 'C1', mother: 'S1', generation: 3),
    ]);

    final byId = result.byId;
    final c1 = byId['C1']!;
    final s1 = byId['S1']!;
    final c2 = byId['C2']!;
    final g1 = byId['G1']!;

    expect(s1.offset.dy, c1.offset.dy);
    expect(
      (s1.offset.dx - c1.offset.dx).abs(),
      TreeLayoutConfig.nodeWidth + config.spouseGap,
    );

    final coupleCenter = (centerX(c1) + centerX(s1)) / 2;
    expect(centerX(g1), closeTo(coupleCenter, 0.01));
    expect(g1.offset.dx, lessThan(c2.offset.dx));
  });

  test('ພໍ່ແມ່ດຽວ ກໍ່ຍັງຈັດລູກໃຫ້ກາງ', () {
    final result = engine.layout([
      person('P', children: ['A', 'B']),
      person('A', father: 'P', generation: 2),
      person('B', father: 'P', generation: 2),
    ]);

    final byId = result.byId;
    final p = byId['P']!;
    final a = byId['A']!;
    final b = byId['B']!;

    expect(centerX(p), closeTo((centerX(a) + centerX(b)) / 2, 0.01));
    expect(
      (b.offset.dx - a.offset.dx).abs(),
      TreeLayoutConfig.nodeWidth + config.siblingGap,
    );
  });

  test('ແຕ່ງຫຼາຍຄັ້ງ: ລູກແຕ່ລະຄູ່ຍັງແຍກກັນ', () {
    final result = engine.layout([
      person('F', spouses: ['M1', 'M2']),
      person('M1', spouses: ['F']),
      person('M2', spouses: ['F']),
      person('C1', father: 'F', mother: 'M1', generation: 2),
      person('C2', father: 'F', mother: 'M2', generation: 2),
    ]);

    final byId = result.byId;
    final f = byId['F']!;
    final m1 = byId['M1']!;
    final m2 = byId['M2']!;
    final c1 = byId['C1']!;
    final c2 = byId['C2']!;

    expect((m1.offset.dx - f.offset.dx).abs(), greaterThan(0));
    expect((m2.offset.dx - f.offset.dx).abs(), greaterThan(0));

    final gapBetweenGroups =
        (c2.offset.dx - c1.offset.dx).abs() - TreeLayoutConfig.nodeWidth;
    expect(gapBetweenGroups, greaterThanOrEqualTo(config.groupGap - 0.01));
  });
}
