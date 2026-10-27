// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:data_naija/core/auto_buy_model.dart';
import 'package:data_naija/core/app_state.dart';
import 'package:data_naija/core/models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Builds a minimal valid rule for testing.
AutoBuyRule _rule({
  ScheduleFrequency frequency = ScheduleFrequency.daily,
  int startHour = 8,
  int startMinute = 0,
  List<int>? weeklyDays,
  int customIntervalHours = 24,
  AutoBuyStatus status = AutoBuyStatus.active,
  int price = 300,
  DateTime? nextRunAt,
}) {
  return AutoBuyRule(
    id: 'test-rule-1',
    networkName: 'MTN',
    phoneNumber: '08012345678',
    bundleGb: '1GB',
    bundleDays: '30 Days',
    bundlePrice: price,
    bundleType: 'SME',
    frequency: frequency,
    weeklyDays: weeklyDays ?? [0],
    startHour: startHour,
    startMinute: startMinute,
    customIntervalHours: customIntervalHours,
    status: status,
    createdAt: DateTime(2025, 1, 1),
    consentGiven: true,
    nextRunAt: nextRunAt,
  );
}

// Monday 2025-04-28 10:00 AM (weekday = 1 = Mon)
final _monday10am = DateTime(2025, 4, 28, 10, 0, 0);
// Monday 2025-04-28 07:00 AM — before start time
final _monday7am = DateTime(2025, 4, 28, 7, 0, 0);

// ─────────────────────────────────────────────────────────────────────────────
// AutoBuyScheduler — computeNextRun
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('AutoBuyScheduler — daily', () {
    test('next run is today if start time is still in the future', () {
      // now = 07:00, startHour = 08, so next run should be today at 08:00
      final rule = _rule(frequency: ScheduleFrequency.daily, startHour: 8);
      final next = AutoBuyScheduler.computeNextRun(rule, _monday7am);
      expect(next.hour, 8);
      expect(next.day, _monday7am.day);
      expect(next.month, _monday7am.month);
    });

    test('next run is tomorrow if start time has passed', () {
      // now = 10:00, startHour = 08, so next run should be tomorrow at 08:00
      final rule = _rule(frequency: ScheduleFrequency.daily, startHour: 8);
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next.hour, 8);
      expect(next.day, _monday10am.day + 1);
    });
  });

  group('AutoBuyScheduler — every 2/4/6/12 hours (interval)', () {
    test('every 2 hours: aligns to start time today if in the future', () {
      final rule = _rule(
        frequency: ScheduleFrequency.every2Hours,
        startHour: 12,
      );
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      // startHour 12 is in the future from 10am
      expect(next.hour, 12);
      expect(next.day, _monday10am.day);
    });

    test('every 2 hours: adds 2h if start time has passed', () {
      final rule = _rule(
        frequency: ScheduleFrequency.every2Hours,
        startHour: 8,
      );
      // now = 10:00, start = 08:00 (passed) → next = 10:00 + 2h = 12:00
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next, _monday10am.add(const Duration(hours: 2)));
    });

    test('every 4 hours adds 4h', () {
      final rule = _rule(frequency: ScheduleFrequency.every4Hours, startHour: 8);
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next, _monday10am.add(const Duration(hours: 4)));
    });

    test('every 6 hours adds 6h', () {
      final rule = _rule(frequency: ScheduleFrequency.every6Hours, startHour: 8);
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next, _monday10am.add(const Duration(hours: 6)));
    });

    test('every 12 hours adds 12h', () {
      final rule =
          _rule(frequency: ScheduleFrequency.every12Hours, startHour: 8);
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next, _monday10am.add(const Duration(hours: 12)));
    });
  });

  group('AutoBuyScheduler — every N days', () {
    test('every 2 days = daily + 1 day', () {
      final daily = _rule(frequency: ScheduleFrequency.daily, startHour: 8);
      final every2 = _rule(frequency: ScheduleFrequency.every2Days, startHour: 8);
      final dailyNext = AutoBuyScheduler.computeNextRun(daily, _monday10am);
      final next = AutoBuyScheduler.computeNextRun(every2, _monday10am);
      expect(next, dailyNext.add(const Duration(days: 1)));
    });

    test('every 3 days = daily + 2 days', () {
      final daily = _rule(frequency: ScheduleFrequency.daily, startHour: 8);
      final every3 = _rule(frequency: ScheduleFrequency.every3Days, startHour: 8);
      final dailyNext = AutoBuyScheduler.computeNextRun(daily, _monday10am);
      final next = AutoBuyScheduler.computeNextRun(every3, _monday10am);
      expect(next, dailyNext.add(const Duration(days: 2)));
    });
  });

  group('AutoBuyScheduler — weekly', () {
    test('weekly Mon: next run is today (Mon) if start time is in the future', () {
      // Now = Mon 07:00, weeklyDays = [0] (Mon), startHour = 8
      final rule = _rule(
        frequency: ScheduleFrequency.weekly,
        weeklyDays: [0],
        startHour: 8,
      );
      final next = AutoBuyScheduler.computeNextRun(rule, _monday7am);
      expect(next.weekday, 1); // Monday
      expect(next.hour, 8);
      expect(next.day, _monday7am.day);
    });

    test('weekly Mon: next run is next week Mon if today Mon has passed', () {
      // Now = Mon 10:00, weeklyDays = [0] (Mon), startHour = 8 (passed)
      final rule = _rule(
        frequency: ScheduleFrequency.weekly,
        weeklyDays: [0],
        startHour: 8,
      );
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      // Should be next Mon (7 days away)
      expect(next.weekday, 1);
      expect(
        next.difference(_monday10am).inDays,
        greaterThanOrEqualTo(6),
      );
    });

    test('weekly Wed+Fri: next run is Wed when now is Mon', () {
      // Now = Mon 10:00, weeklyDays = [2=Wed, 4=Fri], startHour = 8
      final rule = _rule(
        frequency: ScheduleFrequency.weekly,
        weeklyDays: [2, 4], // Wed=2, Fri=4
        startHour: 8,
      );
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next.weekday, 3); // Wednesday
    });

    test('every 2 weeks = weekly + 7 more days', () {
      final weekly = _rule(
        frequency: ScheduleFrequency.weekly,
        weeklyDays: [0],
        startHour: 8,
      );
      final every2w = _rule(
        frequency: ScheduleFrequency.every2Weeks,
        weeklyDays: [0],
        startHour: 8,
      );
      final weeklyNext = AutoBuyScheduler.computeNextRun(weekly, _monday10am);
      final next = AutoBuyScheduler.computeNextRun(every2w, _monday10am);
      expect(next, weeklyNext.add(const Duration(days: 7)));
    });
  });

  group('AutoBuyScheduler — monthly', () {
    test('next run is today if start time in the future', () {
      final rule = _rule(
        frequency: ScheduleFrequency.monthly,
        startHour: 14,
      );
      // Now = Mon 10:00 → today 14:00 is in the future
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next.hour, 14);
      expect(next.day, _monday10am.day);
      expect(next.month, _monday10am.month);
    });

    test('next run is next month same day if today start time has passed', () {
      final rule = _rule(frequency: ScheduleFrequency.monthly, startHour: 8);
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next.day, _monday10am.day);
      expect(next.month, _monday10am.month + 1);
    });

    test('December rolls to January of next year', () {
      final rule = _rule(frequency: ScheduleFrequency.monthly, startHour: 8);
      final dec = DateTime(2025, 12, 15, 10, 0); // Dec 15, 10am
      final next = AutoBuyScheduler.computeNextRun(rule, dec);
      expect(next.month, 1);
      expect(next.year, 2026);
    });
  });

  group('AutoBuyScheduler — custom interval', () {
    test('custom 48h adds 48 hours when start time has passed', () {
      final rule = _rule(
        frequency: ScheduleFrequency.custom,
        customIntervalHours: 48,
        startHour: 8,
      );
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next, _monday10am.add(const Duration(hours: 48)));
    });

    test('custom 1h adds 1 hour', () {
      final rule = _rule(
        frequency: ScheduleFrequency.custom,
        customIntervalHours: 1,
        startHour: 8,
      );
      final next = AutoBuyScheduler.computeNextRun(rule, _monday10am);
      expect(next, _monday10am.add(const Duration(hours: 1)));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // isDue
  // ─────────────────────────────────────────────────────────────────────────
  group('AutoBuyScheduler — isDue', () {
    test('returns false when status is paused', () {
      final rule = _rule(
        status: AutoBuyStatus.paused,
        nextRunAt: _monday10am.subtract(const Duration(seconds: 10)),
      );
      expect(AutoBuyScheduler.isDue(rule, _monday10am), false);
    });

    test('returns false when nextRunAt is null', () {
      final rule = _rule(status: AutoBuyStatus.active);
      expect(AutoBuyScheduler.isDue(rule, _monday10am), false);
    });

    test('returns false when nextRunAt is in the future', () {
      final rule = _rule(
        status: AutoBuyStatus.active,
        nextRunAt: _monday10am.add(const Duration(minutes: 5)),
      );
      expect(AutoBuyScheduler.isDue(rule, _monday10am), false);
    });

    test('returns true when now is exactly at nextRunAt', () {
      final rule = _rule(
        status: AutoBuyStatus.active,
        nextRunAt: _monday10am,
      );
      expect(AutoBuyScheduler.isDue(rule, _monday10am), true);
    });

    test('returns true when now is 90 seconds after nextRunAt', () {
      final rule = _rule(
        status: AutoBuyStatus.active,
        nextRunAt: _monday10am,
      );
      final now = _monday10am.add(const Duration(seconds: 90));
      expect(AutoBuyScheduler.isDue(rule, now), true);
    });

    test('returns false when now is 3 minutes after nextRunAt (window expired)',
        () {
      final rule = _rule(
        status: AutoBuyStatus.active,
        nextRunAt: _monday10am,
      );
      final now = _monday10am.add(const Duration(minutes: 3));
      expect(AutoBuyScheduler.isDue(rule, now), false);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AutoBuyRule — model properties
  // ─────────────────────────────────────────────────────────────────────────
  group('AutoBuyRule — model properties', () {
    test('bundleSummary is correct', () {
      final rule = _rule();
      expect(rule.bundleSummary, 'SME · 1GB – 30 Days');
    });

    test('priceFormatted includes naira sign', () {
      final rule = _rule(price: 1500);
      expect(rule.priceFormatted, '₦1,500');
    });

    test('statusLabel active', () {
      expect(_rule(status: AutoBuyStatus.active).statusLabel, 'Active');
    });

    test('statusLabel paused', () {
      expect(_rule(status: AutoBuyStatus.paused).statusLabel, 'Paused');
    });

    test('nextRunFormatted returns Not scheduled when null', () {
      expect(_rule().nextRunFormatted, 'Not scheduled');
    });

    test('nextRunFormatted returns formatted date when set', () {
      final rule = _rule(nextRunAt: DateTime(2025, 4, 28, 14, 30));
      expect(rule.nextRunFormatted, contains('Apr'));
      expect(rule.nextRunFormatted, contains('2025'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AutoBuyRule — serialisation round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group('AutoBuyRule — serialisation', () {
    test('toJson / fromJson round-trip preserves all fields', () {
      final original = AutoBuyRule(
        id: 'rule-42',
        networkName: 'Airtel',
        phoneNumber: '08098765432',
        bundleGb: '2GB',
        bundleDays: '30 Days',
        bundlePrice: 600,
        bundleType: 'SME2',
        frequency: ScheduleFrequency.weekly,
        weeklyDays: [1, 3], // Tue, Thu
        startHour: 9,
        startMinute: 30,
        customIntervalHours: 24,
        status: AutoBuyStatus.active,
        createdAt: DateTime(2025, 3, 15, 12, 0),
        consentGiven: true,
        nextRunAt: DateTime(2025, 3, 22, 9, 30),
        executions: [
          AutoBuyExecution(
            id: 'exec-1',
            executedAt: DateTime(2025, 3, 15, 9, 30),
            status: AutoBuyExecutionStatus.success,
            txId: 99,
          ),
        ],
      );

      final json = original.toJson();
      final restored = AutoBuyRule.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.networkName, original.networkName);
      expect(restored.phoneNumber, original.phoneNumber);
      expect(restored.bundleGb, original.bundleGb);
      expect(restored.bundlePrice, original.bundlePrice);
      expect(restored.bundleType, original.bundleType);
      expect(restored.frequency, original.frequency);
      expect(restored.weeklyDays, original.weeklyDays);
      expect(restored.startHour, original.startHour);
      expect(restored.startMinute, original.startMinute);
      expect(restored.status, original.status);
      expect(restored.consentGiven, original.consentGiven);
      expect(restored.nextRunAt?.millisecondsSinceEpoch,
          original.nextRunAt?.millisecondsSinceEpoch);
      expect(restored.executions.length, 1);
      expect(restored.executions.first.id, 'exec-1');
      expect(restored.executions.first.status, AutoBuyExecutionStatus.success);
      expect(restored.executions.first.txId, 99);
    });

    test('fromJson handles missing optional fields gracefully', () {
      final minimal = {
        'id': 'r1',
        'networkName': 'MTN',
        'phoneNumber': '08012345678',
        'bundleGb': '1GB',
        'bundleDays': '30 Days',
        'bundlePrice': 300,
        'bundleType': 'SME',
        'frequency': 'daily',
        'weeklyDays': <int>[],
        'startHour': 8,
        'startMinute': 0,
        'status': 'active',
        'createdAt': DateTime(2025, 1, 1).millisecondsSinceEpoch,
        'consentGiven': true,
      };
      expect(() => AutoBuyRule.fromJson(minimal), returnsNormally);
      final rule = AutoBuyRule.fromJson(minimal);
      expect(rule.customIntervalHours, 24); // default
      expect(rule.nextRunAt, isNull);
      expect(rule.executions, isEmpty);
    });

    test('toJsonString / fromJsonString round-trip', () {
      final original = _rule();
      final str = original.toJsonString();
      final restored = AutoBuyRule.fromJsonString(str);
      expect(restored.id, original.id);
      expect(restored.bundleGb, original.bundleGb);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AutoBuyRule — copyWith
  // ─────────────────────────────────────────────────────────────────────────
  group('AutoBuyRule — copyWith', () {
    test('copyWith preserves unchanged fields', () {
      final rule = _rule();
      final copy = rule.copyWith(bundleGb: '2GB');
      expect(copy.networkName, rule.networkName);
      expect(copy.phoneNumber, rule.phoneNumber);
      expect(copy.bundleGb, '2GB');
      expect(copy.id, rule.id);
    });

    test('copyWith can change status', () {
      final rule = _rule(status: AutoBuyStatus.active);
      final paused = rule.copyWith(status: AutoBuyStatus.paused);
      expect(paused.status, AutoBuyStatus.paused);
    });

    test('copyWith with new executions list replaces it', () {
      final rule = _rule();
      final exec = AutoBuyExecution(
        id: 'e1',
        executedAt: DateTime.now(),
        status: AutoBuyExecutionStatus.success,
      );
      final updated = rule.copyWith(executions: [exec]);
      expect(updated.executions.length, 1);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AutoBuyExecution — serialisation
  // ─────────────────────────────────────────────────────────────────────────
  group('AutoBuyExecution — serialisation', () {
    test('success execution round-trips', () {
      final exec = AutoBuyExecution(
        id: 'e-1',
        executedAt: DateTime(2025, 4, 28, 9, 0),
        status: AutoBuyExecutionStatus.success,
        txId: 42,
      );
      final restored = AutoBuyExecution.fromJson(exec.toJson());
      expect(restored.id, exec.id);
      expect(restored.status, AutoBuyExecutionStatus.success);
      expect(restored.txId, 42);
      expect(restored.failureReason, isNull);
    });

    test('insufficient funds execution round-trips with reason', () {
      final exec = AutoBuyExecution(
        id: 'e-2',
        executedAt: DateTime(2025, 4, 28, 9, 0),
        status: AutoBuyExecutionStatus.skippedInsufficientFunds,
        failureReason: 'Insufficient wallet balance (₦100)',
      );
      final restored = AutoBuyExecution.fromJson(exec.toJson());
      expect(restored.status, AutoBuyExecutionStatus.skippedInsufficientFunds);
      expect(restored.failureReason, contains('Insufficient'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AppState.fundAutoBuy — integration
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState.fundAutoBuy', () {
    test('deducts balance', () {
      final s = AppState()..balance = 1000;
      s.fundAutoBuy(
        amount: 300,
        networkName: 'MTN',
        phone: '08012345678',
        bundleGb: '1GB',
        bundleType: 'SME',
      );
      expect(s.balance, 700);
    });

    test('records transaction as Auto-Buy kind (data)', () {
      final s = AppState()..balance = 1000;
      s.fundAutoBuy(
        amount: 300,
        networkName: 'MTN',
        phone: '08012345678',
        bundleGb: '1GB',
        bundleType: 'SME',
      );
      final tx = s.transactions.first;
      expect(tx.title, 'Auto-Buy');
      expect(tx.kind, TxKind.data);
      expect(tx.amount, -300);
    });

    test('sets lastPurchasedTxId', () {
      final s = AppState()..balance = 1000;
      s.fundAutoBuy(
        amount: 300,
        networkName: 'MTN',
        phone: '08012345678',
        bundleGb: '1GB',
        bundleType: 'SME',
      );
      expect(s.lastPurchasedTxId, isNotNull);
    });

    test('records correct phone', () {
      final s = AppState()..balance = 1000;
      s.fundAutoBuy(
        amount: 300,
        networkName: 'Airtel',
        phone: '08098765432',
        bundleGb: '2GB',
        bundleType: 'SME',
      );
      expect(s.transactions.first.phone, '08098765432');
    });

    test('sub includes network and gb', () {
      final s = AppState()..balance = 1000;
      s.fundAutoBuy(
        amount: 300,
        networkName: 'Glo',
        phone: '07012345678',
        bundleGb: '1GB',
        bundleType: 'SME',
      );
      final sub = s.transactions.first.sub;
      expect(sub, contains('Glo'));
      expect(sub, contains('1GB'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Idempotency — duplicate execution prevention
  // ─────────────────────────────────────────────────────────────────────────
  group('Idempotency key logic', () {
    test('same rule + same minute produces identical idempotency key', () {
      // The key is: ruleId + "_" + (nextRunAt ms ~/ 60000)
      final ts = DateTime(2025, 4, 28, 10, 0);
      final key1 = 'rule-1_${ts.millisecondsSinceEpoch ~/ 60000}';
      // 30 seconds later — same minute
      final ts2 = ts.add(const Duration(seconds: 30));
      final key2 = 'rule-1_${ts2.millisecondsSinceEpoch ~/ 60000}';
      expect(key1, key2);
    });

    test('different minutes produce different keys', () {
      final ts1 = DateTime(2025, 4, 28, 10, 0);
      final ts2 = DateTime(2025, 4, 28, 10, 1);
      final key1 = 'rule-1_${ts1.millisecondsSinceEpoch ~/ 60000}';
      final key2 = 'rule-1_${ts2.millisecondsSinceEpoch ~/ 60000}';
      expect(key1, isNot(key2));
    });

    test('different rule IDs produce different keys for same time', () {
      final ts = DateTime(2025, 4, 28, 10, 0);
      final key1 = 'rule-A_${ts.millisecondsSinceEpoch ~/ 60000}';
      final key2 = 'rule-B_${ts.millisecondsSinceEpoch ~/ 60000}';
      expect(key1, isNot(key2));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // ScheduleFrequencyLabel extension
  // ─────────────────────────────────────────────────────────────────────────
  group('ScheduleFrequencyLabel', () {
    test('all frequencies have non-empty labels', () {
      for (final f in ScheduleFrequency.values) {
        expect(f.label.isNotEmpty, true);
      }
    });

    test('isIntervalBased is false for weekly', () {
      expect(ScheduleFrequency.weekly.isIntervalBased, false);
    });

    test('isIntervalBased is false for monthly', () {
      expect(ScheduleFrequency.monthly.isIntervalBased, false);
    });

    test('isIntervalBased is false for custom', () {
      expect(ScheduleFrequency.custom.isIntervalBased, false);
    });

    test('isIntervalBased is true for every2Hours', () {
      expect(ScheduleFrequency.every2Hours.isIntervalBased, true);
    });

    test('isIntervalBased is true for daily', () {
      expect(ScheduleFrequency.daily.isIntervalBased, true);
    });
  });
}
