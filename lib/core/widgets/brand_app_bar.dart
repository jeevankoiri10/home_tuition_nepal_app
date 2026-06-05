import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../theme/app_spacing.dart';

/// App bar branded with the Home Tuition Nepal logo on the left.
///
/// On root pages (no back button) the logo sits in the leading corner and the
/// title stays centered, matching the app's [AppBarTheme]. On pushed pages the
/// system back button (or a custom [leading]) keeps the corner, and the logo is
/// shown just before the left-aligned title — so the brand mark appears on
/// every app bar without hiding navigation.
///
/// Drop-in replacement for [AppBar] for the props this app uses: [title],
/// [actions], [bottom], [leading], and [automaticallyImplyLeading].
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  static const double _logoHeight = 30;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    // Is the leading corner already taken by a back/custom button?
    final hasLeading = leading != null || (automaticallyImplyLeading && canPop);

    final logo = Image.asset(
      AppConstants.appLogoWhiteAsset,
      height: _logoHeight,
      fit: BoxFit.contain,
    );

    if (!hasLeading) {
      // Root-style bar: logo in the corner, title centered (per AppBarTheme).
      return AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: logo,
        ),
        title: title,
        actions: actions,
        bottom: bottom,
      );
    }

    // Sub-page bar: keep the back/custom leading; show the logo before the
    // left-aligned title so the brand still appears on this app bar.
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      titleSpacing: 0,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          if (title != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Flexible(child: title!),
          ],
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }
}
