import 'package:flutter/material.dart';
import '../../../../core/widgets/brand_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../contracts/presentation/blocs/contract_bloc.dart';
import '../../../contracts/presentation/widgets/contract_banner.dart';
import '../../domain/models/chat_message.dart';
import '../blocs/chat_bloc.dart';
import '../widgets/chat_presence_status.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.counterpartyId,
    this.counterpartyMaskedName,
  });

  final String counterpartyId;
  final String? counterpartyMaskedName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  bool _opened = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_opened) return;
      _opened = true;
      context.read<ChatBloc>().add(ChatOpened(widget.counterpartyId));
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final body = _input.text.trim();
    if (body.isEmpty) return;
    context.read<ChatBloc>().add(ChatMessageSent(body));
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  void _scrollToEnd() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: BrandAppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.counterpartyMaskedName ?? l10n.chatTitleFallback),
            ChatPresenceStatus(userId: widget.counterpartyId),
          ],
        ),
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listenWhen: (a, b) =>
            a.messages.length != b.messages.length ||
            a.sendError != b.sendError ||
            a.thread?.id != b.thread?.id,
        listener: (context, state) {
          if (state.sendError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.sendError!)));
            context.read<ChatBloc>().add(const ChatSendErrorCleared());
          }
          // Once the thread is known, point the contract banner at it.
          final threadId = state.thread?.id;
          if (threadId != null) {
            context.read<ContractBloc>().add(ContractThreadOpened(threadId));
          }
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
        },
        builder: (context, state) {
          if (state.status == ChatStatus.error) {
            return _GateError(
              message: state.errorMessage ?? l10n.chatOpenError,
            );
          }
          if (state.status == ChatStatus.opening ||
              state.status == ChatStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final viewerId = context.read<AuthBloc>().state.user?.id ?? '';
          final thread = state.thread;
          return Column(
            children: [
              if (thread != null)
                ContractBanner(
                  threadId: thread.id,
                  studentId: thread.studentId,
                  tutorId: thread.tutorId,
                  viewerId: viewerId,
                  counterpartyName:
                      widget.counterpartyMaskedName ??
                      thread.counterpartyMaskedName ??
                      '',
                ),
              Expanded(
                child: state.messages.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (_, i) {
                          final m = state.messages[i];
                          final mine = m.senderId == viewerId;
                          return _Bubble(message: m, mine: mine);
                        },
                      ),
              ),
              _Composer(controller: _input, onSend: _send),
            ],
          );
        },
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});
  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final bg = mine ? const Color(0xFFDCEDC8) : const Color(0xFFF1F8E9);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.body,
              style: const TextStyle(color: AppColors.chatMessageText),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hhmm(message.sentAt),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: message.isRead
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _hhmm(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).chatComposerHint,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: AppRadii.pillBorder,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Center(
        child: Text(
          AppLocalizations.of(context).chatEmptyHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _GateError extends StatelessWidget {
  const _GateError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
