import 'package:flutter/material.dart';

/// Canonical coin-balance chip (see CLAUDE.md §2). Shows the wallet [balance]
/// next to a coin icon and, when [onTap] is given, taps through — typically to
/// the wallet page.
///
/// Presentational only: callers feed it the balance, usually from a
/// `BlocBuilder<WalletBloc, WalletState>`, so the chip stays decoupled from any
/// feature bloc and reusable on any surface. Defaults are tuned for the
/// brand-gradient app bar (white foreground); override [foreground] for use on
/// a light surface.
class CoinChip extends StatelessWidget {
  const CoinChip({
    super.key,
    required this.balance,
    this.onTap,
    this.foreground = Colors.white,
    this.tooltip,
  });

  final int balance;
  final VoidCallback? onTap;
  final Color foreground;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final chip = TextButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.monetization_on_outlined, color: foreground),
      label: Text('$balance', style: TextStyle(color: foreground)),
    );
    if (tooltip == null) return chip;
    return Tooltip(message: tooltip!, child: chip);
  }
}
