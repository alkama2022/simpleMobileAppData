import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auto_buy_model.dart';
import 'app_state.dart';

/// Manages all Auto-Buy rules.
///
/// IMPORTANT — execution model:
/// Rules are checked and executed by [_tick] when the app is **open**.
/// There is no server-side scheduler in this project.  If the app is closed,
/// the rule is not executed.  A real backend scheduler is required for
/// guaranteed off-device execution and is documented as a future extension.
///
/// Idempotency: each execution generates a unique [AutoBuyExecution.id] from
/// the rule ID + scheduled timestamp.  Before executing, we check that no
/// execution with that ID already exists, preventing duplicate deductions
/// from timer overlap or rapid-restart scenarios.
class AutoBuyState extends ChangeNotifier {
  static const _prefKey = 'auto_buy_rules_v1';

  // Injected at construction so AppState is not fetched through context.
  final AppState appState;

  AutoBuyState({required this.appState});

  List<AutoBuyRule> _rules = [];

  List<AutoBuyRule> get rules => List.unmodifiable(_rules);
  List<AutoBuyRule> get activeRules =>
      _rules.where((r) => r.status == AutoBuyStatus.active).toList();

  Timer? _ticker;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Call once after the widget tree is ready (from main.dart or provider).
  Future<void> init() async {
    await _load();
    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addRule(AutoBuyRule rule) async {
    // Compute first nextRunAt before saving.
    final withNext = rule.copyWith(
      nextRunAt: AutoBuyScheduler.computeNextRun(rule, DateTime.now()),
    );
    _rules = [withNext, ..._rules];
    await _persist();
    notifyListeners();
  }

  Future<void> updateRule(AutoBuyRule updated) async {
    // Re-compute next run when rule is edited.
    final withNext = updated.copyWith(
      nextRunAt: updated.status == AutoBuyStatus.active
          ? AutoBuyScheduler.computeNextRun(updated, DateTime.now())
          : updated.nextRunAt,
    );
    _rules = _rules.map((r) => r.id == withNext.id ? withNext : r).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> deleteRule(String id) async {
    _rules = _rules.where((r) => r.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> setStatus(String id, AutoBuyStatus status) async {
    _rules = _rules.map((r) {
      if (r.id != id) return r;
      final nextRun = status == AutoBuyStatus.active
          ? AutoBuyScheduler.computeNextRun(r, DateTime.now())
          : r.nextRunAt;
      return r.copyWith(status: status, nextRunAt: nextRun);
    }).toList();
    await _persist();
    notifyListeners();
  }

  // ── Execution engine ──────────────────────────────────────────────────────

  /// Periodic tick — checks all active rules and fires any that are due.
  /// Runs every 60 seconds while the app is open.
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 60), (_) => _tick());
    // Also check immediately on startup.
    _tick();
  }

  void _tick() {
    final now = DateTime.now();
    bool changed = false;

    final updated = _rules.map((rule) {
      if (!AutoBuyScheduler.isDue(rule, now)) return rule;

      // Idempotency key: rule id + scheduled timestamp rounded to the minute.
      final scheduledMinute = rule.nextRunAt!;
      final idempKey =
          '${rule.id}_${scheduledMinute.millisecondsSinceEpoch ~/ 60000}';

      // Skip if this execution was already recorded (prevents double-billing).
      final alreadyRan =
          rule.executions.any((e) => e.id == idempKey);
      if (alreadyRan) {
        // Advance nextRunAt and continue.
        changed = true;
        return rule.copyWith(
          nextRunAt: AutoBuyScheduler.computeNextRun(rule, now),
          lastRunAt: rule.lastRunAt,
        );
      }

      // Check balance.
      if (appState.balance < rule.bundlePrice) {
        final exec = AutoBuyExecution(
          id: idempKey,
          executedAt: now,
          status: AutoBuyExecutionStatus.skippedInsufficientFunds,
          failureReason: 'Insufficient wallet balance (₦${appState.balance})',
        );
        changed = true;
        return rule.copyWith(
          nextRunAt: AutoBuyScheduler.computeNextRun(rule, now),
          lastRunAt: now,
          executions: [exec, ...rule.executions],
        );
      }

      // Execute: deduct balance via AppState so the transaction appears
      // in the main transaction history.
      appState.fundAutoBuy(
        amount: rule.bundlePrice,
        networkName: rule.networkName,
        phone: rule.phoneNumber,
        bundleGb: rule.bundleGb,
        bundleType: rule.bundleType,
      );

      final txId = appState.lastPurchasedTxId;

      final exec = AutoBuyExecution(
        id: idempKey,
        executedAt: now,
        status: AutoBuyExecutionStatus.success,
        txId: txId,
      );

      changed = true;
      return rule.copyWith(
        nextRunAt: AutoBuyScheduler.computeNextRun(rule, now),
        lastRunAt: now,
        executions: [exec, ...rule.executions],
      );
    }).toList();

    if (changed) {
      _rules = updated;
      _persist(); // fire-and-forget
      notifyListeners();
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final list = jsonDecode(raw) as List;
      _rules = list
          .map((e) => AutoBuyRule.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      // Corrupted data — start fresh.
      _rules = [];
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_rules.map((r) => r.toJson()).toList());
      await prefs.setString(_prefKey, raw);
    } catch (_) {
      // Persistence failure is non-fatal; rules are still held in memory.
    }
  }
}
