import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/masked_avatar.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../domain/chat_repository.dart';
import '../../domain/models/chat_thread.dart';

/// Inbox-style list of all chat threads for the current user. Tutors and
/// students see the same page; the counterparty masked name is what differs.
class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<ChatThread>> _threads;

  @override
  void initState() {
    super.initState();
    _threads = _load();
  }

  Future<List<ChatThread>> _load() {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return Future.value(const []);
    return sl<ChatRepository>().listMyThreads(user.id);
  }

  Future<void> _refresh() async {
    setState(() => _threads = _load());
    await _threads;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthBloc>().state.user;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatListTitle)),
      body: FutureBuilder<List<ChatThread>>(
        future: _threads,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final threads = snap.data ?? const <ChatThread>[];
          if (threads.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                    child: Column(
                      children: [
                        const Icon(Icons.forum_outlined,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: AppSpacing.md),
                        Text(l10n.chatListEmptyTitle,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.chatListEmptyHint,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => _ThreadTile(
                thread: threads[i],
                viewerId: user?.id ?? '',
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread, required this.viewerId});

  final ChatThread thread;
  final String viewerId;

  String get _name => thread.counterpartyMaskedName?.trim().isNotEmpty == true
      ? thread.counterpartyMaskedName!
      : '—';

  String _subtitle(BuildContext context) {
    final ts = thread.lastMessageAt ?? thread.createdAt;
    return DateFormat.MMMd(Localizations.localeOf(context).toString())
        .add_jm()
        .format(ts.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      leading: MaskedAvatar(name: _name, radius: 22),
      title: Text(_name),
      subtitle: Text(_subtitle(context),
          style: const TextStyle(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        final counterparty = thread.counterpartyFor(viewerId);
        final uri = Uri(
          path: AppRoutes.chat.replaceAll(':counterpartyId', counterparty),
          queryParameters: {if (_name != '—') 'name': _name},
        );
        context.push(uri.toString());
      },
    );
  }
}
