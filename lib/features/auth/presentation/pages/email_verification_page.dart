import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../blocs/auth_bloc.dart';

class EmailVerificationPage extends StatelessWidget {
  const EmailVerificationPage({super.key});

  String _errorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'no_session':
        return l10n.verifyEmailErrorNoSession;
      default:
        return l10n.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyEmailTitle)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go(AppRoutes.routeForRole(state.user!.role));
          } else if (state.status == AuthStatus.error && state.errorCode != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorMessage(l10n, state.errorCode!))),
            );
          } else if (state.status == AuthStatus.awaitingEmailVerification &&
              state.user != null &&
              !state.user!.emailVerified) {
            // Refresh succeeded but the email isn't confirmed yet — nudge the user.
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          }
        },
        builder: (context, state) {
          final busy = state.status == AuthStatus.registering;
          final email = state.user?.email ?? '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Icon(Icons.mark_email_unread_outlined, size: 72),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.verifyEmailInstruction(email),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: l10n.verifyEmailRefresh,
                  busy: busy,
                  onPressed: busy
                      ? null
                      : () {
                          final wasVerified = state.user?.emailVerified ?? false;
                          context.read<AuthBloc>().add(
                                const AuthEmailVerificationRefreshRequested(),
                              );
                          // If after refresh we're still unverified, show a hint.
                          // The bloc listener can't directly compare pre/post, so
                          // we schedule the hint here.
                          Future<void>.delayed(const Duration(seconds: 1), () {
                            if (!context.mounted) return;
                            final after = context.read<AuthBloc>().state.user;
                            if (!wasVerified && after != null && !after.emailVerified) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.verifyEmailNotYet)),
                              );
                            }
                          });
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: busy
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                                const AuthEmailVerificationResendRequested(),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.verifyEmailResentSnack)),
                          );
                        },
                  child: Text(l10n.verifyEmailResend),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
