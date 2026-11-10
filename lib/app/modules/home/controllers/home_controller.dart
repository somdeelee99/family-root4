import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../data/models/family.dart';
import '../../../data/models/family_member.dart';
import '../../../data/repositories/family_repository.dart';
import '../../../data/repositories/member_repository.dart';

class HomeController extends GetxController {
  final MemberRepository _memberRepo = MemberRepository();
  final FamilyRepository _familyRepo = FamilyRepository();

  final RxList<FamilyMember> members = <FamilyMember>[].obs;
  final Rx<FamilyStats> stats = FamilyStats.empty.obs;
  final Rxn<Family> family = Rxn<Family>();
  final RxBool isLoading = true.obs;
  final RxBool isChartView = false.obs;

  bool get isAdmin => AuthService.to.isAdmin;
  String get familyId => AuthService.to.familyId;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  List<FamilyMember> get recentMembers {
    final list = [...members]
      ..sort((a, b) {
        final ad = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bd = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bd.compareTo(ad);
      });
    return list.take(5).toList();
  }

  Map<String, double> get genderChart => {
    'male': stats.value.male.toDouble(),
    'female': stats.value.female.toDouble(),
  };

  List<MapEntry<int, int>> get generationChart {
    final entries = stats.value.generations.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  void toggleChartView() => isChartView.value = !isChartView.value;

  Future<void> refreshData() async {
    final fid = familyId;
    if (fid.isEmpty) return;

    isLoading.value = true;
    try {
      final list = await _memberRepo.fetchAll(fid);
      members.assignAll(list);
      stats.value = MemberRepository.calculateStats(list);

      final fam = await _familyRepo.fetchFamily(fid);
      family.value = fam;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
