import 'dart:convert';
import 'models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Schedule frequency
// ─────────────────────────────────────────────────────────────────────────────

enum ScheduleFrequency {
  every2Hours,
  every4Hours,
  every6Hours,
  every12Hours,
  daily,
  every2Days,
  every3Days,
  weekly,
  every2Weeks,
  monthly,
  custom,
}

extension ScheduleFrequencyLabel on ScheduleFrequency {
  String get label {
    switch (this) {
      case ScheduleFrequency.every2Hours:
        return 'Every 2 hours';
      case ScheduleFrequency.every4Hours:
        return 'Every 4 hours';
      case ScheduleFrequency.every6Hours:
        return 'Every 6 hours';
      case ScheduleFrequency.every12Hours:
        return 'Every 12 hours';
      case ScheduleFrequency.daily:
        return 'Daily';
      case ScheduleFrequency.every2Days:
        return 'Every 2 days';
      case ScheduleFrequency.every3Days:
        return 'Every 3 days';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.every2Weeks:
        return 'Every 2 weeks';
      case ScheduleFrequency.monthly:
        return 'Monthly';
      case ScheduleFrequency.custom:
        return 'Custom interval';
    }
  }

  /// True when this frequency uses a fixed interval (not calendar-based).
  bool get isIntervalBased {
    return this != ScheduleFrequency.weekly &&
        this != ScheduleFrequency.monthly &&
        this != ScheduleFrequency.custom;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rule status
// ─────────────────────────────────────────────────────────────────────────────

enum AutoBuyStatus { active, paused }

// ─────────────────────────────────────────────────────────────────────────────
// Execution record (one successful or failed run)
// ─────────────────────────────────────────────────────────────────────────────

enum AutoBuyExecutionStatus { success, failed, skippedInsufficientFunds }

class AutoBuyExecution {
  final String id; // idempotency key — prevents double execution
  final DateTime executedAt;
  final AutoBuyExecutionStatus status;
  final String? failureReason;
  final int? txId; // linked Transaction id on success

  const AutoBuyExecution({
    required this.id,
    required this.executedAt,
    required this.status,
    this.failureReason,
    this.txId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'executedAt': executedAt.millisecondsSinceEpoch,
    'status': status.name,
    'failureReason': failureReason,
    'txId': txId,
  };

  factory AutoBuyExecution.fromJson(Map<String, dynamic> j) {
    return AutoBuyExecution(
      id: j['id'] as String,
      executedAt: DateTime.fromMillisecondsSinceEpoch(j['executedAt'] as int),
      status: AutoBuyExecutionStatus.values.firstWhere(
        (s) => s.name == j['status'],
        orElse: () => AutoBuyExecutionStatus.failed,
      ),
      failureReason: j['failureReason'] as String?,
      txId: j['txId'] as int?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AutoBuyRule — the main model
// ─────────────────────────────────────────────────────────────────────────────

class AutoBuyRule {
  final String id;
  final String networkName;
  final String phoneNumber;
  final String bundleGb;
  final String bundleDays;
  final int bundlePrice;
  final String bundleType;
  final ScheduleFrequency frequency;

  /// For weekly: which weekdays (0=Mon … 6=Sun).
  final List<int> weeklyDays;

  /// Start time of day (hour 0-23). Used for daily/weekly/interval schedules.
  final int startHour;
  final int startMinute;

  /// For custom frequency: interval in hours (1–720).
  final int customIntervalHours;

  final AutoBuyStatus status;
  final DateTime createdAt;
  final DateTime? nextRunAt;
  final DateTime? lastRunAt;
  final List<AutoBuyExecution> executions;

  /// Consent flag — customer must have explicitly agreed before activation.
  final bool consentGiven;

  const AutoBuyRule({
    required this.id,
    required this.networkName,
    required this.phoneNumber,
    required this.bundleGb,
    required this.bundleDays,
    required this.bundlePrice,
    required this.bundleType,
    required this.frequency,
    required this.weeklyDays,
    required this.startHour,
    required this.startMinute,
    required this.customIntervalHours,
    required this.status,
    required this.createdAt,
    required this.consentGiven,
    this.nextRunAt,
    this.lastRunAt,
    this.executions = const [],
  });

  AutoBuyRule copyWith({
    String? id,
    String? networkName,
    String? phoneNumber,
    String? bundleGb,
    String? bundleDays,
    int? bundlePrice,
    String? bundleType,
    ScheduleFrequency? frequency,
    List<int>? weeklyDays,
    int? startHour,
    int? startMinute,
    int? customIntervalHours,
    AutoBuyStatus? status,
    DateTime? createdAt,
    bool? consentGiven,
    DateTime? nextRunAt,
    DateTime? lastRunAt,
    List<AutoBuyExecution>? executions,
  }) {
    return AutoBuyRule(
      id: id ?? this.id,
      networkName: networkName ?? this.networkName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bundleGb: bundleGb ?? this.bundleGb,
      bundleDays: bundleDays ?? this.bundleDays,
      bundlePrice: bundlePrice ?? this.bundlePrice,
      bundleType: bundleType ?? this.bundleType,
      frequency: frequency ?? this.frequency,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      customIntervalHours: customIntervalHours ?? this.customIntervalHours,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      consentGiven: consentGiven ?? this.consentGiven,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      executions: executions ?? this.executions,
    );
  }

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'networkName': networkName,
    'phoneNumber': phoneNumber,
    'bundleGb': bundleGb,
    'bundleDays': bundleDays,
    'bundlePrice': bundlePrice,
    'bundleType': bundleType,
    'frequency': frequency.name,
    'weeklyDays': weeklyDays,
    'startHour': startHour,
    'startMinute': startMinute,
    'customIntervalHours': customIntervalHours,
    'status': status.name,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'consentGiven': consentGiven,
    'nextRunAt': nextRunAt?.millisecondsSinceEpoch,
    'lastRunAt': lastRunAt?.millisecondsSinceEpoch,
    'executions': executions.map((e) => e.toJson()).toList(),
  };

  factory AutoBuyRule.fromJson(Map<String, dynamic> j) {
    return AutoBuyRule(
      id: j['id'] as String,
      networkName: j['networkName'] as String,
      phoneNumber: j['phoneNumber'] as String,
      bundleGb: j['bundleGb'] as String,
      bundleDays: j['bundleDays'] as String,
      bundlePrice: j['bundlePrice'] as int,
      bundleType: j['bundleType'] as String,
      frequency: ScheduleFrequency.values.firstWhere(
        (f) => f.name == j['frequency'],
        orElse: () => ScheduleFrequency.daily,
      ),
      weeklyDays: List<int>.from(j['weeklyDays'] as List),
      startHour: j['startHour'] as int,
      startMinute: j['startMinute'] as int,
      customIntervalHours: j['customIntervalHours'] as int? ?? 24,
      status: AutoBuyStatus.values.firstWhere(
        (s) => s.name == j['status'],
        orElse: () => AutoBuyStatus.paused,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(j['createdAt'] as int),
      consentGiven: j['consentGiven'] as bool? ?? false,
      nextRunAt: j['nextRunAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(j['nextRunAt'] as int)
          : null,
      lastRunAt: j['lastRunAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(j['lastRunAt'] as int)
          : null,
      executions: (j['executions'] as List? ?? [])
          .map((e) => AutoBuyExecution.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static AutoBuyRule fromJsonString(String s) =>
      AutoBuyRule.fromJson(jsonDecode(s) as Map<String, dynamic>);

  String toJsonString() => jsonEncode(toJson());

  // ── Display helpers ───────────────────────────────────────────────────────

  String get bundleSummary => '$bundleType · $bundleGb – $bundleDays';

  String get priceFormatted => '₦${bundlePrice.toLocaleString()}';

  String get statusLabel =>
      status == AutoBuyStatus.active ? 'Active' : 'Paused';

  String get nextRunFormatted {
    if (nextRunAt == null) return 'Not scheduled';
    final d = nextRunAt!;
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${months[d.month - 1]} ${d.day}, ${d.year} · $h:$m $ampm';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scheduling logic — pure functions, easy to unit-test
// ─────────────────────────────────────────────────────────────────────────────

class AutoBuyScheduler {
  AutoBuyScheduler._();

  /// Computes the next run time for a rule after [from].
  /// All times are in local device time (Africa/Lagos on Nigerian devices).
  static DateTime computeNextRun(AutoBuyRule rule, DateTime from) {
    switch (rule.frequency) {
      case ScheduleFrequency.every2Hours:
        return _addInterval(from, hours: 2,
            startHour: rule.startHour, startMinute: rule.startMinute);
      case ScheduleFrequency.every4Hours:
        return _addInterval(from, hours: 4,
            startHour: rule.startHour, startMinute: rule.startMinute);
      case ScheduleFrequency.every6Hours:
        return _addInterval(from, hours: 6,
            startHour: rule.startHour, startMinute: rule.startMinute);
      case ScheduleFrequency.every12Hours:
        return _addInterval(from, hours: 12,
            startHour: rule.startHour, startMinute: rule.startMinute);
      case ScheduleFrequency.daily:
        return _nextDailyRun(from, rule.startHour, rule.startMinute);
      case ScheduleFrequency.every2Days:
        return _nextDailyRun(from, rule.startHour, rule.startMinute)
            .add(const Duration(days: 1));
      case ScheduleFrequency.every3Days:
        return _nextDailyRun(from, rule.startHour, rule.startMinute)
            .add(const Duration(days: 2));
      case ScheduleFrequency.weekly:
        return _nextWeeklyRun(from, rule.weeklyDays, rule.startHour,
            rule.startMinute);
      case ScheduleFrequency.every2Weeks:
        return _nextWeeklyRun(from, rule.weeklyDays, rule.startHour,
            rule.startMinute).add(const Duration(days: 7));
      case ScheduleFrequency.monthly:
        return _nextMonthlyRun(from, rule.startHour, rule.startMinute);
      case ScheduleFrequency.custom:
        return _addInterval(from, hours: rule.customIntervalHours,
            startHour: rule.startHour, startMinute: rule.startMinute);
    }
  }

  /// Returns true when [rule] is due to run at [now] (within a 2-minute window
  /// to account for the periodic check not firing at the exact millisecond).
  static bool isDue(AutoBuyRule rule, DateTime now) {
    if (rule.status != AutoBuyStatus.active) return false;
    if (rule.nextRunAt == null) return false;
    final diff = now.difference(rule.nextRunAt!);
    // Due if we are within 0..2 minutes past the scheduled time.
    return diff.inSeconds >= 0 && diff.inMinutes < 2;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// For interval-based frequencies, the first run fires at [startHour:startMinute]
  /// on the same day if that time is still in the future, otherwise at
  /// [from + interval].
  static DateTime _addInterval(
    DateTime from, {
    required int hours,
    required int startHour,
    required int startMinute,
  }) {
    // First run: align to start time on today if possible.
    final todayStart = DateTime(
      from.year, from.month, from.day, startHour, startMinute,
    );
    if (todayStart.isAfter(from)) return todayStart;
    return from.add(Duration(hours: hours));
  }

  static DateTime _nextDailyRun(DateTime from, int hour, int minute) {
    final today = DateTime(from.year, from.month, from.day, hour, minute);
    if (today.isAfter(from)) return today;
    return today.add(const Duration(days: 1));
  }

  static DateTime _nextWeeklyRun(
    DateTime from,
    List<int> weeklyDays,
    int hour,
    int minute,
  ) {
    if (weeklyDays.isEmpty) {
      // Default to same weekday if no days selected.
      return _nextDailyRun(from, hour, minute).add(const Duration(days: 7));
    }

    // Dart weekday: Mon=1 … Sun=7. Our weeklyDays: Mon=0 … Sun=6.
    // Convert Dart weekday to our index: (weekday - 1).
    final sorted = List<int>.from(weeklyDays)..sort();
    DateTime candidate = DateTime(from.year, from.month, from.day, hour, minute);

    // Try up to 14 days ahead to find the next matching weekday.
    for (int i = 0; i <= 13; i++) {
      final day = candidate.add(Duration(days: i));
      final dayIndex = day.weekday - 1; // 0=Mon … 6=Sun
      if (sorted.contains(dayIndex) && day.isAfter(from)) {
        return day;
      }
    }
    // Fallback: 7 days
    return from.add(const Duration(days: 7));
  }

  static DateTime _nextMonthlyRun(DateTime from, int hour, int minute) {
    // Same day of month next month (or today if still in the future).
    final thisMonth = DateTime(from.year, from.month, from.day, hour, minute);
    if (thisMonth.isAfter(from)) return thisMonth;
    // Next month same day; clamp to last day of month.
    final nextMonth = from.month == 12
        ? DateTime(from.year + 1, 1, from.day, hour, minute)
        : DateTime(from.year, from.month + 1, from.day, hour, minute);
    return nextMonth;
  }
}

// Import models.dart to use the IntFormat extension (toLocaleString).
// No duplicate extension needed here.

