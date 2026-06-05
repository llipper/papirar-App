import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:papirar/features/auth/di/auth_module.dart';
import 'package:papirar/features/auth/domain/auth_form_validators.dart';
import 'package:papirar/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_divider_label.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_feedback.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_colors.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_page_shell.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_password_visibility_button.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final SignInWithEmail _signInWithEmail = AuthModule.signInWithEmail();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    final result = await _signInWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    showAuthFeedback(context, result.message);
    if (!result.isSuccess) return;

    final redirect = GoRouterState.of(context).uri.queryParameters['redirect'];
    context.go((redirect == null || redirect.isEmpty) ? '/' : redirect);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AuthColors.of(context);

    return AuthPageShell(
      title: 'Entrar no Papirar',
      subtitle: 'Acesse sua leitura, progresso e revisões com áudio.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthSocialButton(
                onPressed: () => showAuthFeedback(
                  context,
                  'Google Auth ainda precisa ser conectado no backend.',
                ),
              ),
              const SizedBox(height: 18),
              const AuthDividerLabel(label: 'ou entre com e-mail'),
              const SizedBox(height: 18),
              AuthTextField(
                controller: _emailController,
                label: 'E-mail',
                hint: 'voce@exemplo.com',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: AuthFormValidators.validateEmail,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _passwordController,
                label: 'Senha',
                hint: 'Sua senha',
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                obscureText: !_showPassword,
                validator: AuthFormValidators.validateLoginPassword,
                suffixIcon: AuthPasswordVisibilityButton(
                  isVisible: _showPassword,
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/esqueci-senha'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.text,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: const Text('Esqueceu a senha?'),
                ),
              ),
              const SizedBox(height: 8),
              AuthPrimaryButton(
                label: _isSubmitting ? 'Entrando...' : 'Entrar',
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 18),
              AuthFooterLink(
                text: 'Ainda não tem conta?',
                actionLabel: 'Criar conta',
                onPressed: () => context.go('/cadastro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
