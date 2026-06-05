import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.quicksand(
        color: colors.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      cursorColor: colors.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffixIcon,
        labelStyle: GoogleFonts.quicksand(
          color: colors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: GoogleFonts.quicksand(
          color: colors.muted.withValues(alpha: 0.72),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: colors.secondary,
        contentPadding: const EdgeInsets.fromLTRB(18, 15, 14, 15),
        border: _border(colors.border),
        enabledBorder: _border(colors.border),
        focusedBorder: _border(colors.text),
        errorBorder: _border(colors.text),
        focusedErrorBorder: _border(colors.text),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: color),
    );
  }
}
