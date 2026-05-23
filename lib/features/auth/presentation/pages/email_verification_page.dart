import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../blocs/auth_bloc.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  static const Duration _pollInterval = Duration(seconds: 5);
  static const int _resendCooldownSeconds = 60;

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldownRemaining = 0;
  bool _manualRefreshShownHint = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _autoRefresh());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _autoRefresh() {
    if (!mounted) return;
    final bloc = context.read<AuthBloc>();
    final status = bloc.state.status;
    final verified = bloc.state.user?.emailVerified ?? false;
    if (verified || status == AuthStatus.registering) return;
    bloc.add(const AuthEmailVerificationRefreshRequested());
  }

  void _manualRefresh(AppLocalizations l10n) {
    final bloc = context.read<AuthBloc>();
    final wasVerified = bloc.state.user?.emailVerified ?? false;
    bloc.add(const AuthEmailVerificationRefreshRequested());
    // Show a "not yet" hint shortly after a manual click, once per session.
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final after = context.read<AuthBloc>().state.user;
      if (!wasVerified && after != null && !after.emailVerified && !_manualRefreshShownHint) {
        _manualRefreshShownHint = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.verifyEmailNotYet)),
        );
      }
    });
  }

  void _resend(AppLocalizations l10n) {
    context.read<AuthBloc>().add(const AuthEmailVerificationResendRequested());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.verifyEmailResentSnack)),
    );
    setState(() => _cooldownRemaining = _resendCooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _cooldownRemaining -= 1);
      if (_cooldownRemaining <= 0) timer.cancel();
    });
  }

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
          }
        },
        builder: (context, state) {
          final busy = state.status == AuthStatus.registering;
          final email = state.user?.email ?? '';
          final resendLabel = _cooldownRemaining > 0
              ? l10n.verifyEmailResendCooldown(_cooldownRemaining)
              : l10n.verifyEmailResend;
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
                  onPressed: busy ? null : () => _manualRefresh(l10n),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: (busy || _cooldownRemaining > 0) ? null : () => _resend(l10n),
                  child: Text(resendLabel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
