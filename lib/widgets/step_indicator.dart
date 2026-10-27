import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// 3-step progress indicator used in the Buy Data flow.
/// Matches `.st`, `.sd`, `.sl` in the prototype.
class StepIndicator extends StatelessWidget {
  final int currentStep; // 1, 2, or 3

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(1),
        _line(),
        _dot(2),
        _line(),
        _dot(3),
      ],
    );
  }

  Widget _dot(int step) {
    final active = step <= currentStep;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.primary : AppColors.borderLight,
      ),
      alignment: Alignment.center,
      child: Text(
        '$step',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: active ? Colors.white : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _line() {
    return Expanded(
      child: Container(height: 2, color: AppColors.borderLight),
    );
  }
}
