import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papirar/features/perfil/domain/entities/user_profile.dart';
import 'package:papirar/features/perfil/domain/profile_validators.dart';
import 'package:papirar/features/perfil/widgets/profile_colors.dart';

class ProfileEditSheet extends StatefulWidget {
  final ProfileColors colors;
  final UserProfile profile;
  final bool isSaving;
  final Future<bool> Function({
    required String displayName,
    required String username,
    required String bio,
  })
  onSave;

  const ProfileEditSheet({
    super.key,
    required this.colors,
    required this.profile,
    required this.isSaving,
    required this.onSave,
  });

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    _usernameController = TextEditingController(text: widget.profile.username);
    _bioController = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);
    final saved = await widget.onSave(
      displayName: _displayNameController.text,
      username: _usernameController.text,
      bio: _bioController.text,
    );
    if (!mounted) return;

    setState(() => _isSaving = false);
    if (saved) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Editar perfil',
                style: GoogleFonts.quicksand(
                  color: colors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _ProfileField(
                colors: colors,
                controller: _displayNameController,
                label: 'Nome',
                validator: ProfileValidators.validateDisplayName,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                colors: colors,
                controller: _usernameController,
                label: 'Usuário',
                prefixText: '@',
                validator: ProfileValidators.validateUsername,
              ),
              const SizedBox(height: 12),
              _ProfileField(
                colors: colors,
                controller: _bioController,
                label: 'Bio',
                maxLines: 3,
                validator: ProfileValidators.validateBio,
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.accentText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Salvando...' : 'Salvar perfil',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final ProfileColors colors;
  final TextEditingController controller;
  final String label;
  final String? prefixText;
  final int maxLines;
  final String? Function(String?) validator;

  const _ProfileField({
    required this.colors,
    required this.controller,
    required this.label,
    required this.validator,
    this.prefixText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.quicksand(
        color: colors.text,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        filled: true,
        fillColor: colors.inner,
        labelStyle: GoogleFonts.quicksand(
          color: colors.muted,
          fontWeight: FontWeight.w800,
        ),
        border: _border(colors.line),
        enabledBorder: _border(colors.line),
        focusedBorder: _border(colors.text),
        errorBorder: _border(colors.text),
        focusedErrorBorder: _border(colors.text),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color),
    );
  }
}
