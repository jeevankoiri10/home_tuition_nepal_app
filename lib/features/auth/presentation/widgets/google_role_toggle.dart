import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/models/user_role.dart';

/// Notion-style disclosure for "Continue with Google". Collapsed it shows a
/// single button; tapping it expands two role choices ("…as a student" /
/// "…as a tutor"). Picking one calls [onSelected] with that [UserRole].
class GoogleRoleToggle extends StatefulWidget {
  const GoogleRoleToggle({
    super.key,
    required this.onSelected,
    this.busy = false,
  });

  /// Invoked with the chosen role when the user taps one of the two options.
  final ValueChanged<UserRole> onSelected;

  /// While a sign-in is in flight the control is disabled and shows a spinner.
  final bool busy;

  @override
  State<GoogleRoleToggle> createState() => _GoogleRoleToggleState();
}

class _GoogleRoleToggleState extends State<GoogleRoleToggle> {
  bool _expanded = false;

  void _toggle() {
    if (widget.busy) return;
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: AppRadii.cardBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  const _GoogleGlyph(),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.googleContinue,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.busy)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Divider(height: 1),
                      _RoleOption(
                        icon: Icons.school_outlined,
                        label: l10n.googleAsStudent,
                        onTap: widget.busy
                            ? null
                            : () => widget.onSelected(UserRole.student),
                      ),
                      const Divider(height: 1),
                      _RoleOption(
                        icon: Icons.person_outline,
                        label: l10n.googleAsTutor,
                        onTap: widget.busy
                            ? null
                            : () => widget.onSelected(UserRole.tutor),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// A single role choice row inside the expanded toggle.
class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

/// The official four-colour Google "G" mark, rendered without bundling an
/// asset by painting the canonical 48×48 logo paths directly.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CustomPaint(painter: _GoogleLogoPainter()),
      ),
    );
  }
}

/// Paints the official multi-colour Google "G", translated from the canonical
/// 48×48 SVG logo paths and scaled to the available [Size].
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const Color _blue = Color(0xFF4285F4);
  static const Color _red = Color(0xFFEA4335);
  static const Color _yellow = Color(0xFFFBBC05);
  static const Color _green = Color(0xFF34A853);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48.0;
    canvas.save();
    canvas.scale(scale);
    final paint = Paint()..isAntiAlias = true;

    canvas.drawPath(_bluePath(), paint..color = _blue);
    canvas.drawPath(_redPath(), paint..color = _red);
    canvas.drawPath(_yellowPath(), paint..color = _yellow);
    canvas.drawPath(_greenPath(), paint..color = _green);

    canvas.restore();
  }

  Path _bluePath() => Path()
    ..moveTo(46.98, 24.55)
    ..relativeCubicTo(0, -1.57, -0.15, -3.09, -0.38, -4.55)
    ..lineTo(24, 20)
    ..relativeLineTo(0, 9.02)
    ..relativeLineTo(12.94, 0)
    ..relativeCubicTo(-0.58, 2.96, -2.26, 5.48, -4.78, 7.18)
    ..relativeLineTo(7.73, 6)
    ..relativeCubicTo(4.51, -4.18, 7.09, -10.36, 7.09, -17.65)
    ..close();

  Path _redPath() => Path()
    ..moveTo(24, 9.5)
    ..relativeCubicTo(3.54, 0, 6.71, 1.22, 9.21, 3.6)
    ..relativeLineTo(6.85, -6.85)
    ..cubicTo(35.9, 2.38, 30.47, 0, 24, 0)
    ..cubicTo(14.62, 0, 6.51, 5.38, 2.56, 13.22)
    ..relativeLineTo(7.98, 6.19)
    ..cubicTo(12.43, 13.72, 17.74, 9.5, 24, 9.5)
    ..close();

  Path _yellowPath() => Path()
    ..moveTo(10.53, 28.59)
    ..relativeCubicTo(-0.48, -1.45, -0.76, -2.99, -0.76, -4.59)
    ..cubicTo(9.77, 22.4, 10.04, 20.86, 10.53, 19.41)
    ..relativeLineTo(-7.98, -6.19)
    ..cubicTo(0.92, 16.46, 0, 20.12, 0, 24)
    ..relativeCubicTo(0, 3.88, 0.92, 7.54, 2.56, 10.78)
    ..relativeLineTo(7.97, -6.19)
    ..close();

  Path _greenPath() => Path()
    ..moveTo(24, 48)
    ..relativeCubicTo(6.48, 0, 11.93, -2.13, 15.89, -5.81)
    ..relativeLineTo(-7.73, -6)
    ..relativeCubicTo(-2.15, 1.45, -4.92, 2.3, -8.16, 2.3)
    ..relativeCubicTo(-6.26, 0, -11.57, -4.22, -13.47, -9.91)
    ..relativeLineTo(-7.98, 6.19)
    ..cubicTo(6.51, 42.62, 14.62, 48, 24, 48)
    ..close();

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
