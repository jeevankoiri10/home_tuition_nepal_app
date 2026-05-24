import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../blocs/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(email: _email.text.trim(), password: _password.text),
        );
  }

  String _errorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'invalid_credentials':
        return l10n.loginErrorInvalidCredentials;
      default:
        return l10n.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go(AppRoutes.routeForRole(state.user!.role));
          } else if (state.status == AuthStatus.awaitingEmailVerification) {
            context.go(AppRoutes.verifyEmail);
          } else if (state.status == AuthStatus.error && state.errorCode != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorMessage(l10n, state.errorCode!))),
            );
          }
        },
        builder: (context, state) {
          final busy = state.status == AuthStatus.registering;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.loginSubtitle, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.xxl),
                  AppTextField(
                    label: l10n.emailLabel,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    validator: (v) {
                      final code = Validators.email(v);
                      return code == null ? null : l10n.emailInvalid;
                    },
                  ),
                  AppTextField(
                    label: l10n.passwordLabel,
                    controller: _password,
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      tooltip: _obscure ? l10n.showPasswordTooltip : l10n.hidePasswordTooltip,
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => Validators.required(v) == null ? null : l10n.passwordRequired,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: l10n.loginSubmit, busy: busy, onPressed: busy ? null : _submit),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: Text(l10n.loginToRegister),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
