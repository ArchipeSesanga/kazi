import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/kazi_colors.dart';
import '../theme/kazi_spacing.dart';

class KaziTextField extends StatelessWidget {
  const KaziTextField({
    required this.label,
    this.controller,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.xs),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          obscureText: obscureText,
          maxLength: maxLength,
          enabled: enabled,
          autofocus: autofocus,
          focusNode: focusNode,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            color: KaziColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            errorText: errorText,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: KaziSpacing.lg,
              vertical: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class KaziTextArea extends StatelessWidget {
  const KaziTextArea({
    required this.label,
    this.controller,
    this.hint,
    this.onChanged,
    this.validator,
    this.errorText,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 8,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final int? maxLength;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: KaziColors.ink,
          ),
        ),
        const SizedBox(height: KaziSpacing.xs),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          maxLength: maxLength,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            color: KaziColors.ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            counterText: maxLength != null ? null : '',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}
