import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:papirar/features/auth/di/auth_module.dart';
import 'package:papirar/features/auth/domain/auth_form_validators.dart';
import 'package:papirar/features/auth/domain/usecases/request_password_reset.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_feedback.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_page_shell.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:papirar/features/auth/presentation/widgets/auth_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final RequestPasswordReset _requestPasswordReset =
      AuthModule.requestPasswordReset();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
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
    final result = await _requestPasswordReset(_emailController.text);
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    showAuthFeedback(context, result.message);
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageShell(
      title: 'Recuperar senha',
      subtitle: 'Informe seu e-mail para receber um link seguro de acesso.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _emailController,
                label: 'E-mail',
                hint: 'voce@exemplo.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                validator: AuthFormValidators.validateEmail,
              ),
              const SizedBox(height: 18),
              AuthPrimaryButton(
                label: _isSubmitting ? 'Enviando...' : 'Enviar instruções',
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 18),
              AuthFooterLink(
                text: 'Lembrou sua senha?',
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
