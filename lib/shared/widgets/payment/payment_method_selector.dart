import 'package:flutter/material.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';
import 'package:lumina_library/shared/widgets/payment/payment_method_card.dart';

/// Grouped list of payment methods (QR / Virtual Account / E-Wallet) — the
/// member picks one before POST /payments/create fires. Backs both the
/// initial method choice and "Change Payment Method". Each row is a
/// Material 3 [PaymentMethodCard] (logo, name, description, radio, chevron).
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<PaymentMethodOption>>{};
    for (final option in PaymentMethodOption.all) {
      groups.putIfAbsent(option.group, () => []).add(option);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: LuminaSpacing.xs, top: LuminaSpacing.sm),
            child: Text(
              entry.key,
              style: LuminaTextStyles.labelMd.copyWith(
                color: LuminaColors.outline,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ),
          ...entry.value.map((option) => Padding(
                padding: const EdgeInsets.only(bottom: LuminaSpacing.xs),
                child: PaymentMethodCard(
                  method: option.value,
                  label: option.label,
                  description: option.description,
                  isSelected: selected == option.value,
                  onTap: () => onSelect(option.value),
                ),
              )),
        ],
      ],
    );
  }
}
