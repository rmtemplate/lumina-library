import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/widgets/payment/payment_logo.dart';

/// Material 3 list item for a single payment method — logo, name,
/// description, radio indicator, chevron, and an animated selected state.
/// Used by `payment_method_selector.dart`; not meant to be used standalone.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.method,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final String method;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? LuminaColors.secondaryContainer.withOpacity(0.22) : LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: isSelected ? LuminaColors.secondary : LuminaColors.outlineVariant.withOpacity(0.4),
          width: isSelected ? 1.6 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: LuminaColors.secondary.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(LuminaSpacing.sm),
            child: Row(
              children: [
                PaymentLogo(method: method, size: 44),
                const SizedBox(width: LuminaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: LuminaTextStyles.bodyMd.copyWith(
                          color: LuminaColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LuminaTextStyles.labelMd.copyWith(
                          color: LuminaColors.onSurfaceVariant,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(isSelected),
                    size: 22,
                    color: isSelected ? LuminaColors.secondary : LuminaColors.outline,
                  ),
                ),
                const SizedBox(width: LuminaSpacing.xs),
                Icon(Icons.chevron_right_rounded, size: 20, color: LuminaColors.outline.withOpacity(0.6)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
