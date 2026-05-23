import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
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

  String _errorMessage(String code) {
    switch (code) {
      case 'invalid_otp':
        return 'That code is not valid. Please try again.';
      case 'no_session':
        return 'Session expired. Please sign in again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your phone')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go(AppRoutes.routeForRole(state.user!.role));
          } else if (state.status == AuthStatus.error && state.errorCode != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorMessage(state.errorCode!))),
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
                    'Enter the 6-digit code we sent to $phone.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppTextField(
                    label: 'OTP code',
                    controller: _code,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.sms_outlined,
                    validator: (v) => Validators.otpCode(v) == null ? null : '6 digits required.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: 'Verify', busy: busy, onPressed: busy ? null : _submit),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () {
                            // Re-trigger sendOtp by signing back into the same session.
                            // In the FakeAuthRepository this is a no-op.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('A new code was sent.')),
                            );
                          },
                    child: const Text('Resend code'),
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

