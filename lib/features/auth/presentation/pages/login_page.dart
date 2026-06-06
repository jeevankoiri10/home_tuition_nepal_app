import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/language_toggle.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/auth_repository.dart';
import '../../domain/models/user_role.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/google_role_toggle.dart';

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

  /// Whether both credentials have been entered. Drives the submit button's
  /// enabled state so it stays disabled until there is something to submit.
  bool get _hasCredentials =>
      _email.text.trim().isNotEmpty && _password.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _email.addListener(_onCredentialsChanged);
    _password.addListener(_onCredentialsChanged);
  }

  void _onCredentialsChanged() => setState(() {});

  @override
  void dispose() {
    _email.removeListener(_onCredentialsChanged);
    _password.removeListener(_onCredentialsChanged);
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

  /// Maps an auth error [code] to a localized, actionable message. Each Google
  /// sign-in failure mode gets its own message so the user knows what to do
  /// next, instead of every path collapsing into the generic fallback.
  String _errorMessage(AppLocalizations l10n, String code) {
    switch (code) {
      case 'invalid_credentials':
        return l10n.loginErrorInvalidCredentials;
      case 'no_internet':
        return l10n.errorNoInternet;
      case 'signin_cancelled':
        return l10n.errorSignInCancelled;
      case 'signin_timeout':
        return l10n.errorSignInTimeout;
      case 'signin_failed':
        return l10n.errorGoogleSignInFailed;
      default:
        return l10n.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: BrandAppBar(
        title: Text(AppConstants.appName),
        actions: const [LanguageToggle()],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state.status == AuthStatus.authenticated) {
            final user = state.user!;
            // If the email has profiles in both roles, ask the user which one
            // to enter as. Otherwise auto-route to the only available role.
            // `availableRoles` is a single-element set on the current schema,
            // so the chooser only appears once the multi-role schema lands.
            final router = GoRouter.of(context);
            Set<UserRole> roles = {user.role};
            try {
              final fetched = await sl<AuthRepository>().availableRoles(
                user.id,
              );
              if (fetched.isNotEmpty) roles = fetched;
            } catch (_) {
              /* fall through to the single cached role */
            }
            router.go(AppRoutes.postLoginLocation(roles));
          } else if (state.status == AuthStatus.awaitingEmailVerification) {
            context.go(AppRoutes.verifyEmail);
          } else if (state.status == AuthStatus.error &&
              state.errorCode != null) {
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
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GoogleRoleToggle(
                    busy: busy,
                    onSelected: (role) => context.read<AuthBloc>().add(
                      AuthGoogleSignInRequested(role),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Text(
                          l10n.orSeparator,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                      tooltip: _obscure
                          ? l10n.showPasswordTooltip
                          : l10n.hidePasswordTooltip,
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) => Validators.required(v) == null
                        ? null
                        : l10n.passwordRequired,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: l10n.loginSubmit,
                    busy: busy,
                    onPressed: (busy || !_hasCredentials) ? null : _submit,
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
