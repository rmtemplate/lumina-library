import 'package:flutter/material.dart';

import '../../../core/theme/lumina_colors.dart';
import '../../../core/theme/lumina_radius.dart';
import '../../../core/theme/lumina_spacing.dart';
import '../../../core/theme/lumina_text_styles.dart';

class LuminaSearchField extends StatelessWidget {
  const LuminaSearchField({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.showFilterButton = false,
    this.autofocus = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final field = Container(
      height: 50,
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(
          color: LuminaColors.outlineVariant,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: LuminaTextStyles.bodyMd.copyWith(
          color: LuminaColors.onSurface,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: LuminaColors.onSurfaceVariant,
          ),
          hintText: hintText,
          hintStyle: LuminaTextStyles.bodyMd.copyWith(
            color: LuminaColors.onSurfaceVariant,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.md,
            vertical: 14,
          ),
        ),
      ),
    );

    if (!showFilterButton) return field;

    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: LuminaSpacing.sm),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(LuminaRadius.lg),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(LuminaRadius.lg),
              border: Border.all(
                color: LuminaColors.outlineVariant,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: LuminaColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
