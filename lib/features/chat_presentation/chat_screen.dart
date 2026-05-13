import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/ai_service_provider.dart';
import '../../data/services/donation_faq_bot.dart';
import '../../theme/app_theme.dart';

class ChatMessage {
  ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessage>[
    ChatMessage(
      text:
          'مرحباً، أنا مساعد «لا تهدر، تبرع». اسأل عن التبرع، الصور، الفئات، أو الأمان — أو اكتب بالإنجليزية.\n'
          'Hi — ask how to donate, AI photo analysis, categories, or safety.',
      isUser: false,
    ),
  ];
  var _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _busy) return;
    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _busy = true;
    });
    _scrollToEnd();

    final faq = DonationFaqBot.match(text);
    final reply = faq ?? await ref.read(aiServiceProvider).chatDonationAssistant(text);

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: reply, isUser: false));
      _busy = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مساعد التبرع', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.brown,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/add-donation'),
            icon: const Icon(Icons.volunteer_activism, color: Colors.white, size: 20),
            label: const Text('تبرع', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _Bubble(message: _messages[i]),
            ),
          ),
          if (_busy) const LinearProgressIndicator(minHeight: 2, color: AppTheme.brown),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'اكتب سؤالك…',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    style: IconButton.styleFrom(backgroundColor: AppTheme.brown, foregroundColor: Colors.white),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final align = message.isUser
        ? AlignmentDirectional.centerStart
        : AlignmentDirectional.centerEnd;
    final bg = message.isUser ? AppTheme.brown.withValues(alpha: 0.12) : Colors.white;
    final border = message.isUser ? null : Border.all(color: AppTheme.brown.withValues(alpha: 0.2));

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.86),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.35,
            color: message.isUser ? AppTheme.textBlack : AppTheme.textBlack,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
