import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/auto_buy_model.dart';
import '../../core/auto_buy_state.dart';
import '../../core/sample_data.dart';
import '../../widgets/dn_button.dart';
import '../../widgets/dn_chip.dart';
import '../../widgets/toast.dart';

/// Multi-step setup screen for creating or editing an Auto-Buy rule.
/// Steps: 1 Network → 2 Bundle → 3 Schedule → 4 Review & Confirm
class AutoBuySetupScreen extends StatefulWidget {
  const AutoBuySetupScreen({super.key});

  @override
  State<AutoBuySetupScreen> createState() => _AutoBuySetupScreenState();
}

class _AutoBuySetupScreenState extends State<AutoBuySetupScreen> {
  // ── Editing state ─────────────────────────────────────────────────────────
  AutoBuyRule? _editing; // null = creating new
  bool _isEditing = false;

  // ── Step 1 — Network & phone ──────────────────────────────────────────────
  String _network = 'MTN';
  final _phoneCtrl = TextEditingController();

  // ── Step 2 — Bundle ───────────────────────────────────────────────────────
  String _bundleType = 'SME';
  int _planIndex = 1; // default: 1GB plan in SME

  // ── Step 3 — Schedule ─────────────────────────────────────────────────────
  ScheduleFrequency _frequency = ScheduleFrequency.daily;
  List<int> _weeklyDays = [0]; // Mon
  int _startHour = 8;
  int _startMinute = 0;
  int _customIntervalHours = 24;
  final TextEditingController _customIntervalCtrl = TextEditingController(
    text: '24',
  );

  // ── Consent ───────────────────────────────────────────────────────────────
  bool _consent = false;

  // ── Stepper ───────────────────────────────────────────────────────────────
  int _step = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load editing rule if passed as argument.
    if (!_isEditing) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is AutoBuyRule) {
        _editing = arg;
        _isEditing = true;
        _network = arg.networkName;
        _phoneCtrl.text = arg.phoneNumber;
        _bundleType = arg.bundleType;
        // Find plan index.
        final plans = SampleData.bundleTypes[_bundleType]?.plans ?? [];
        _planIndex = plans.indexWhere(
          (p) => p.gb == arg.bundleGb && p.price == arg.bundlePrice,
        );
        if (_planIndex < 0) _planIndex = 0;
        _frequency = arg.frequency;
        _weeklyDays = List.from(arg.weeklyDays);
        _startHour = arg.startHour;
        _startMinute = arg.startMinute;
        _customIntervalHours = arg.customIntervalHours;
        _customIntervalCtrl.text = arg.customIntervalHours.toString();
        _consent = arg.consentGiven;
      }
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _customIntervalCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get _phoneValid =>
      RegExp(r'^0[789][01]\d{8}$').hasMatch(_phoneCtrl.text);

  List<dynamic> get _currentPlans =>
      SampleData.bundleTypes[_bundleType]?.plans ?? [];

  dynamic get _selectedPlan {
    final plans = _currentPlans;
    if (plans.isEmpty) return null;
    return plans[_planIndex.clamp(0, plans.length - 1)];
  }

  String get _timeLabel {
    final h = _startHour > 12
        ? _startHour - 12
        : (_startHour == 0 ? 12 : _startHour);
    final m = _startMinute.toString().padLeft(2, '0');
    final ampm = _startHour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final plan = _selectedPlan;
    if (plan == null) return;

    final state = context.read<AutoBuyState>();

    if (_editing != null) {
      await state.updateRule(
        _editing!.copyWith(
          networkName: _network,
          phoneNumber: _phoneCtrl.text,
          bundleGb: plan.gb,
          bundleDays: plan.days,
          bundlePrice: plan.price,
          bundleType: _bundleType,
          frequency: _frequency,
          weeklyDays: _weeklyDays,
          startHour: _startHour,
          startMinute: _startMinute,
          customIntervalHours: _customIntervalHours,
          consentGiven: _consent,
          status: AutoBuyStatus.active,
        ),
      );
      if (mounted) {
        showDnToast(context, 'Schedule updated.');
        Navigator.of(context).pop();
      }
    } else {
      final now = DateTime.now();
      final id = '${now.millisecondsSinceEpoch}';
      await state.addRule(
        AutoBuyRule(
          id: id,
          networkName: _network,
          phoneNumber: _phoneCtrl.text,
          bundleGb: plan.gb,
          bundleDays: plan.days,
          bundlePrice: plan.price,
          bundleType: _bundleType,
          frequency: _frequency,
          weeklyDays: _weeklyDays,
          startHour: _startHour,
          startMinute: _startMinute,
          customIntervalHours: _customIntervalHours,
          status: AutoBuyStatus.active,
          createdAt: now,
          consentGiven: _consent,
        ),
      );
      if (mounted) {
        showDnToast(context, 'Auto-Buy schedule created!');
        Navigator.of(context).pop();
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing != null ? 'Edit Schedule' : 'New Auto-Buy'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepBar(current: _step, total: 4),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                child: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4Review(),
                ][_step],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Network & phone ───────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Select Network'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.8,
          children: SampleData.networks.map((n) {
            final sel = _network == n.name;
            return GestureDetector(
              onTap: () => setState(() => _network = n.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.borderLight,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  color: sel ? const Color(0xFFF0FAF5) : Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: n.bgColor,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        n.abbr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: n.fgColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      n.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        _label('Recipient Phone Number'),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: const InputDecoration(hintText: 'e.g. 08012345678'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter the number that will receive data.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),
        DnPrimaryButton(
          label: 'Next',
          onPressed: _phoneValid ? () => setState(() => _step = 1) : null,
        ),
      ],
    );
  }

  // ── Step 2: Bundle ────────────────────────────────────────────────────────

  Widget _buildStep2() {
    final plans = _currentPlans;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Select Data Bundle'),
        const SizedBox(height: 10),
        _label('Data type'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SampleData.bundleTypes.keys.map((type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DnChip(
                  label: type,
                  selected: _bundleType == type,
                  onTap: () => setState(() {
                    _bundleType = type;
                    _planIndex = 0;
                  }),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          SampleData.bundleTypes[_bundleType]?.description ?? '',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ...plans.asMap().entries.map((e) {
          final i = e.key;
          final p = e.value;
          final selected = _planIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _planIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.borderLight,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(14),
                color: selected ? const Color(0xFFF0FAF5) : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${p.gb}  ${p.days}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    p.priceFormatted,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.primary : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        DnPrimaryButton(
          label: 'Next',
          onPressed: plans.isNotEmpty ? () => setState(() => _step = 2) : null,
        ),
      ],
    );
  }

  // ── Step 3: Schedule ──────────────────────────────────────────────────────

  static const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Widget _buildStep3() {
    final needsTime = _frequency != ScheduleFrequency.every2Hours &&
        _frequency != ScheduleFrequency.every4Hours &&
        _frequency != ScheduleFrequency.every6Hours &&
        _frequency != ScheduleFrequency.every12Hours;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Choose Schedule'),
        const SizedBox(height: 10),
        _label('Purchase frequency'),
        ...ScheduleFrequency.values.map((f) {
          return InkWell(
            onTap: () => setState(() => _frequency = f),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  RadioGroup<ScheduleFrequency>(
                    groupValue: _frequency,
                    onChanged: (v) => setState(() => _frequency = v!),
                    child: Radio<ScheduleFrequency>(
                      value: f,
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  Text(
                    f.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        // Weekly day picker
        if (_frequency == ScheduleFrequency.weekly ||
            _frequency == ScheduleFrequency.every2Weeks) ...[
          const SizedBox(height: 8),
          _label('Select days'),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final selected = _weeklyDays.contains(i);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    if (_weeklyDays.length > 1) _weeklyDays.remove(i);
                  } else {
                    _weeklyDays.add(i);
                  }
                }),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primary : AppColors.bgGreen,
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.borderLight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _weekdayNames[i],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
        // Custom interval input
        if (_frequency == ScheduleFrequency.custom) ...[
          _label('Interval (hours)'),
          TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              hintText: '24',
              suffixText: 'hours',
              hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted),
            ),
            onChanged: (v) {
              final parsed = int.tryParse(v);
              if (parsed != null && parsed >= 1 && parsed <= 720) {
                setState(() => _customIntervalHours = parsed);
              }
            },
            controller: TextEditingController(
              text: _customIntervalHours.toString(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter a value between 1 and 720 hours.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
        // Time picker
        if (needsTime) ...[
          _label('Start time'),
          GestureDetector(
            onTap: () => _pickTime(context),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _timeLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        DnPrimaryButton(
          label: 'Review',
          onPressed: () => setState(() => _step = 3),
        ),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _startHour, minute: _startMinute),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startHour = picked.hour;
        _startMinute = picked.minute;
      });
    }
  }

  // ── Step 4: Review & Confirm ──────────────────────────────────────────────

  Widget _buildStep4Review() {
    final plan = _selectedPlan;
    if (plan == null) return const SizedBox.shrink();

    // Compute what the next run would be.
    final previewRule = AutoBuyRule(
      id: 'preview',
      networkName: _network,
      phoneNumber: _phoneCtrl.text,
      bundleGb: plan.gb,
      bundleDays: plan.days,
      bundlePrice: plan.price,
      bundleType: _bundleType,
      frequency: _frequency,
      weeklyDays: _weeklyDays,
      startHour: _startHour,
      startMinute: _startMinute,
      customIntervalHours: _customIntervalHours,
      status: AutoBuyStatus.active,
      createdAt: DateTime.now(),
      consentGiven: true,
    );
    final nextRun = AutoBuyScheduler.computeNextRun(previewRule, DateTime.now());
    final nextRule = previewRule.copyWith(nextRunAt: nextRun);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Review & Confirm'),
        const SizedBox(height: 16),
        // Summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewRow(label: 'Network', value: _network),
              _ReviewRow(label: 'Phone', value: _phoneCtrl.text),
              _ReviewRow(
                label: 'Bundle',
                value: '${plan.gb} · ${plan.days} (${plan.priceFormatted})',
              ),
              _ReviewRow(label: 'Type', value: _bundleType),
              _ReviewRow(
                label: 'Frequency',
                value: _frequency.label +
                    (_frequency == ScheduleFrequency.custom
                        ? ' (${_customIntervalHours}h)'
                        : ''),
              ),
              if (_frequency == ScheduleFrequency.weekly ||
                  _frequency == ScheduleFrequency.every2Weeks)
                _ReviewRow(
                  label: 'Days',
                  value: _weeklyDays
                      .map((i) =>
                          ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i])
                      .join(', '),
                ),
              _ReviewRow(
                label: 'Time',
                value: _timeLabel,
              ),
              _ReviewRow(
                label: 'First purchase',
                value: nextRule.nextRunFormatted,
                valueColor: AppColors.primary,
              ),
              const Divider(height: 20),
              _ReviewRow(
                label: 'Per purchase',
                value: plan.priceFormatted,
                bold: true,
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Consent checkbox
        GestureDetector(
          onTap: () => setState(() => _consent = !_consent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _consent,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _consent = v ?? false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'I understand that DataNaija will automatically purchase this data bundle from my wallet at the frequency I have selected. I can pause or cancel at any time.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        DnPrimaryButton(
          label: _editing != null ? 'Save Changes' : 'Activate Auto-Buy',
          onPressed: _consent ? _save : null,
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _step = 2),
            child: Text(
              'Edit schedule',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 18,
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final int current;
  final int total;
  const _StepBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 4),
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _ReviewRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
                color: valueColor ?? AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
