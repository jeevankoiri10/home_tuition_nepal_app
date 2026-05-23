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
    if (_role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a role to continue.')),
      );
      return;
    }
    if (!_tosAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must accept the Terms of Service.')),
      );
      return;
    }
    if (_role == UserRole.tutor && !_cocAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tutors must accept the Tutors' Code of Conduct.")),
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

  String _errorMessage(String code) {
    switch (code) {
      case 'signup_failed':
        return 'Could not create the account. The email may already be in use.';
      case 'tos_required':
        return 'You must accept the Terms of Service.';
      case 'coc_required':
        return "Tutors must accept the Code of Conduct.";
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  String? _validateName(String? v) => Validators.name(v) == null ? null : 'Required (max 40).';
  String? _validateEmail(String? v) => Validators.email(v) == null ? null : 'Enter a valid email.';
  String? _validatePhone(String? v) =>
      Validators.nepaliPhone(v) == null ? null : 'Enter a valid 10-digit Nepali mobile (98… / 97…).';
  String? _validatePassword(String? v) {
    final code = Validators.password(v);
    if (code == null) return null;
    if (code == 'passwordTooShort') return 'At least 8 characters.';
    return 'Password must include letters and digits.';
  }

  String? _validateConfirm(String? v) =>
      Validators.confirmPassword(v, _password.text) == null ? null : 'Passwords do not match.';

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
              SnackBar(content: Text(_errorMessage(state.errorCode!))),
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
                          label: 'First name',
                          controller: _first,
                          prefixIcon: Icons.person_outline,
                          validator: _validateName,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: 'Last name',
                          controller: _last,
                          validator: _validateName,
                        ),
                      ),
                    ],
                  ),
                  AppTextField(
                    label: 'Email address',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    validator: _validateEmail,
                  ),
                  AppTextField(
                    label: 'Phone number',
                    hint: '98XXXXXXXX',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: _validatePhone,
                  ),
                  AppTextField(
                    label: 'Password',
                    controller: _password,
                    obscureText: _obscure,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: _validatePassword,
                  ),
                  AppTextField(
                    label: 'Confirm password',
                    controller: _confirm,
                    obscureText: _obscureConfirm,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: _validateConfirm,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Role', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  RoleSelector(
                    value: _role,
                    onChanged: (r) => setState(() {
                      _role = r;
                      if (r != UserRole.tutor) _cocAccepted = false;
                    }),
                    tutorLabel: "I'm a tutor",
                    tutorSubtitle: 'I want to teach',
                    studentLabel: "I'm a student",
                    studentSubtitle: "I'm looking for a tutor",
                  ),
                  if (_role != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Your role is permanent for this account.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  CheckboxListTile(
                    value: _tosAccepted,
                    onChanged: (v) => setState(() => _tosAccepted = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('I accept the Terms of Service & Privacy Policy.'),
                  ),
                  if (_role == UserRole.tutor)
                    CheckboxListTile(
                      value: _cocAccepted,
                      onChanged: (v) => setState(() => _cocAccepted = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("I accept the Tutors' Code of Conduct."),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: 'Register', busy: busy, onPressed: busy ? null : _submit),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Already registered? Sign in'),
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
