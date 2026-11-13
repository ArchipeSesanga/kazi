import 'package:flutter/material.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class StepperBar extends StatelessWidget {
  const StepperBar({
    required this.totalSteps,
    required this.currentStep,
    super.key,
  });

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i < currentStep;
        final isCurrent = i == currentStep - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < totalSteps - 1 ? KaziSpacing.xs : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? (isCurrent ? KaziColors.accent : KaziColors.primary)
                    : KaziColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
