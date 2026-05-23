import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_report.dart';

class OwnerBranchSession {
  final Map<String, String> branchData;
  final List<Map<String, String>> products;
  final List<Map<String, String>> sales;
  final List<Map<String, String>> costs;
  final List<Map<String, String>> staff;

  const OwnerBranchSession({
    required this.branchData,
    this.products = const [],
    this.sales = const [],
    this.costs = const [],
    this.staff = const [],
  });
}

class OwnerExportsState {
  final List<DailyReportArchive> reports;
  final Map<String, OwnerBranchSession> branchSessions;

  const OwnerExportsState({
    this.reports = const [],
    this.branchSessions = const {},
  });

  OwnerExportsState copyWith({
    List<DailyReportArchive>? reports,
    Map<String, OwnerBranchSession>? branchSessions,
  }) {
    return OwnerExportsState(
      reports: reports ?? this.reports,
      branchSessions: branchSessions ?? this.branchSessions,
    );
  }
}

class OwnerExportsNotifier extends Notifier<OwnerExportsState> {
  @override
  OwnerExportsState build() => const OwnerExportsState();

  void saveBranchSession(String branchName, OwnerBranchSession session) {
    final key = branchName.trim().toLowerCase();
    if (key.isEmpty) return;
    final updated = Map<String, OwnerBranchSession>.from(state.branchSessions);
    updated[key] = session;
    state = state.copyWith(branchSessions: updated);
  }

  OwnerBranchSession? sessionFor(String branchName) {
    return state.branchSessions[branchName.trim().toLowerCase()];
  }

  int _nextReportId() {
    if (state.reports.isEmpty) return 1;
    return state.reports.map((r) => r.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  DailyReportArchive exportBranchToday(String branchName) {
    final session = sessionFor(branchName);
    final today = DateTime.now().toIso8601String().split('T').first;
    final report = DailyReportArchive.fromOwnerBranch(
      branchName: branchName,
      date: today,
      reportId: _nextReportId(),
      sales: session?.sales ?? [],
      products: session?.products ?? [],
      costs: session?.costs ?? [],
    );
    state = state.copyWith(reports: [...state.reports, report]);
    return report;
  }

  void markDeposited(int reportId) {
    state = state.copyWith(
      reports: state.reports
          .map((r) => r.id == reportId ? r.copyWith(isDeposited: true) : r)
          .toList(),
    );
  }
}

final ownerExportsProvider =
    NotifierProvider<OwnerExportsNotifier, OwnerExportsState>(
  OwnerExportsNotifier.new,
);
