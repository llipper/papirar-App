import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:papirar/features/auth/di/auth_module.dart';
import 'package:papirar/features/auth/domain/auth_form_validators.dart';
import 'package:papirar/features/auth/domain/usecases/create_account.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_feedback.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_page_shell.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_password_rules.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_password_visibility_button.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final CreateAccount _createAccount = AuthModule.createAccount();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmation = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    TextInput.finishAutofillContext();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _emailController.text = AuthFormValidators.normalizeEmail(
      _emailController.text,
    );
    setState(() => _isSubmitting = true);
    final result = await _createAccount(
      name: _nameController.text.trim(),
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    showAuthFeedback(context, result.message);
    if (result.isSuccess) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      title: 'Criar conta',
      subtitle: 'Proteja seu progresso e continue estudando em qualquer lugar.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _nameController,
                label: 'Nome',
                hint: 'Seu nome',
                autofillHints: const [AutofillHints.name],
                validator: AuthFormValidators.validateName,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _emailController,
                label: 'E-mail',
                hint: 'voce@exemplo.com',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: AuthFormValidators.validateEmail,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _passwordController,
                label: 'Senha',
                hint: 'Mínimo 12 caracteres',
                autofillHints: const [AutofillHints.newPassword],
                obscureText: !_showPassword,
                validator: (value) => AuthFormValidators.validateStrongPassword(
                  value,
                  email: _emailController.text,
                ),
                onChanged: (_) => setState(() {}),
                suffixIcon: AuthPasswordVisibilityButton(
                  isVisible: _showPassword,
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Confirmar senha',
                hint: 'Repita sua senha',
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                obscureText: !_showConfirmation,
                validator: (value) {
                  return AuthFormValidators.validatePasswordConfirmation(
                    value,
                    _passwordController.text,
                  );
                },
                suffixIcon: AuthPasswordVisibilityButton(
                  isVisible: _showConfirmation,
                  onPressed: () {
                    setState(() => _showConfirmation = !_showConfirmation);
                  },
                ),
              ),
              const SizedBox(height: 12),
              const AuthPasswordRules(),
              const SizedBox(height: 18),
              AuthPrimaryButton(
                label: _isSubmitting ? 'Criando...' : 'Criar conta',
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 18),
              AuthFooterLink(
                text: 'Já tem conta?',
                actionLabel: 'Entrar',
                onPressed: () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
