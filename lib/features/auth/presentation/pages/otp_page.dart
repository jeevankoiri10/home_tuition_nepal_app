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

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthOtpRequested(_code.text.trim()));
  }

  String _errorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'invalid_otp':
        return l10n.otpErrorInvalid;
      case 'no_session':
        return l10n.otpErrorNoSession;
      default:
        return l10n.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go(AppRoutes.routeForRole(state.user!.role));
          } else if (state.status == AuthStatus.error && state.errorCode != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorMessage(l10n, state.errorCode!))),
            );
          }
        },
        builder: (context, state) {
          final busy = state.status == AuthStatus.registering;
          final phone = state.user?.phone ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.otpInstruction(phone),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppTextField(
                    label: l10n.otpCodeLabel,
                    controller: _code,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.sms_outlined,
                    validator: (v) => Validators.otpCode(v) == null ? null : l10n.otpInvalidLength,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: l10n.otpVerifySubmit, busy: busy, onPressed: busy ? null : _submit),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () {
                            // Re-trigger sendOtp by signing back into the same session.
                            // In the FakeAuthRepository this is a no-op.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.otpResentSnack)),
                            );
                          },
                    child: Text(l10n.otpResend),
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

