import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/user_role.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/role_selector.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  UserRole? _role;
  bool _tosAccepted = false;
  bool _cocAccepted = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (_role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pickRoleSnack)),
      );
      return;
    }
    if (!_tosAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tosRequiredSnack)),
      );
      return;
    }
    if (_role == UserRole.tutor && !_cocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cocRequiredSnack)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(AuthRegisterRequested(RegistrationInput(
          firstName: _first.text,
          lastName: _last.text,
          email: _email.text,
          phone: _phone.text,
          password: _password.text,
          role: _role!,
          tosAccepted: _tosAccepted,
          codeOfConductAccepted: _cocAccepted,
        )));
  }

  String _errorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'signup_failed':
        return l10n.registerErrorSignupFailed;
      case 'tos_required':
        return l10n.tosRequiredSnack;
      case 'coc_required':
        return l10n.registerErrorCocRequired;
      default:
        return l10n.errorGeneric;
    }
  }

  String? _validateName(AppLocalizations l10n, String? v) =>
      Validators.name(v) == null ? null : l10n.nameInvalid;
  String? _validateEmail(AppLocalizations l10n, String? v) =>
      Validators.email(v) == null ? null : l10n.emailInvalid;
  String? _validatePhone(AppLocalizations l10n, String? v) =>
      Validators.nepaliPhone(v) == null ? null : l10n.phoneInvalid;
  String? _validatePassword(AppLocalizations l10n, String? v) {
    final code = Validators.password(v);
    if (code == null) return null;
    if (code == 'passwordTooShort') return l10n.passwordTooShort;
    return l10n.passwordWeak;
  }

  String? _validateConfirm(AppLocalizations l10n, String? v) =>
      Validators.confirmPassword(v, _password.text) == null
          ? null
          : l10n.confirmPasswordMismatch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.awaitingOtp) {
            context.go(AppRoutes.otp);
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
                  Text(l10n.registerSubtitle, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.firstNameLabel,
                          controller: _first,
                          prefixIcon: Icons.person_outline,
                          validator: (v) => _validateName(l10n, v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: l10n.lastNameLabel,
                          controller: _last,
                          validator: (v) => _validateName(l10n, v),
                        ),
                      ),
                    ],
                  ),
                  AppTextField(
                    label: l10n.emailAddressLabel,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    validator: (v) => _validateEmail(l10n, v),
                  ),
                  AppTextField(
                    label: l10n.phoneNumberLabel,
                    hint: l10n.phoneNumberHint,
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) => _validatePhone(l10n, v),
                  ),
                  AppTextField(
                    label: l10n.passwordLabel,
                    controller: _password,
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => _validatePassword(l10n, v),
                  ),
                  AppTextField(
                    label: l10n.confirmPasswordLabel,
                    controller: _confirm,
                    obscureText: _obscureConfirm,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) => _validateConfirm(l10n, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.roleLabel, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  RoleSelector(
                    value: _role,
                    onChanged: (r) => setState(() {
                      _role = r;
                      if (r != UserRole.tutor) _cocAccepted = false;
                    }),
                    tutorLabel: l10n.roleTutor,
                    tutorSubtitle: l10n.roleTutorSubtitle,
                    studentLabel: l10n.roleStudent,
                    studentSubtitle: l10n.roleStudentSubtitle,
                  ),
                  if (_role != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.rolePermanentNote,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  CheckboxListTile(
                    value: _tosAccepted,
                    onChanged: (v) => setState(() => _tosAccepted = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.tosAcceptLabel),
                  ),
                  if (_role == UserRole.tutor)
                    CheckboxListTile(
                      value: _cocAccepted,
                      onChanged: (v) => setState(() => _cocAccepted = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.cocAcceptLabel),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: l10n.registerSubmit, busy: busy, onPressed: busy ? null : _submit),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: Text(l10n.registerToLogin),
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
