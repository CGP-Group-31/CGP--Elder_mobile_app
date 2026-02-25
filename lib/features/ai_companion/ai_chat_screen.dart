import 'package:flutter/material.dart';

enum AIChatMode { voice, typing }

class AIChatScreen extends StatefulWidget {
  final AIChatMode mode;

  const AIChatScreen({super.key, required this.mode});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  _AIChatMessage({required this.text, required this.isUser, required this.time});
}

class _AIChatScreenState extends State<AIChatScreen> {
  // Palette
  static const Color teal = Color(0xFF2E7D7A);
  static const Color mintA = Color(0xFFD6EFE6);
  static const Color mintB = Color(0xFFBEE8DA);
  static const Color cream = Color(0xFFF6F7F3);
  static const Color ink = Color(0xFF243333);
  static const Color slate2 = Color(0xFF7C8B89);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scroll = ScrollController();

  final List<_AIChatMessage> _messages = [
    _AIChatMessage(
      text: "Hello 😊 I’m your companion. How can I help you today?",
      isUser: false,
      time: DateTime.now(),
    )
  ];

  bool _listening = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == AIChatMode.typing) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _sendUserMessage(String text) {
    final t = text.trim();
    if (t.isEmpty) return;

    setState(() {
      _messages.add(_AIChatMessage(text: t, isUser: true, time: DateTime.now()));
    });
    _controller.clear();

    // Fake AI reply (UI only for now)
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add(
          _AIChatMessage(
            text: "I understand. Let’s take it step by step. Can you tell me a little more?",
            isUser: false,
            time: DateTime.now(),
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollBottom());
  }

  @override
  Widget build(BuildContext context) {
    final bool isVoice = widget.mode == AIChatMode.voice;

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Companion",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mintA, cream],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Mode banner
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mintB,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: teal.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Icon(isVoice ? Icons.mic : Icons.keyboard, color: teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isVoice ? "Voice mode: Tap mic to speak" : "Typing mode: Write your message below",
                          style: const TextStyle(fontWeight: FontWeight.w700, color: ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chat list
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    return _bubble(m.text, m.isUser);
                  },
                ),
              ),

              // Bottom area depends on mode
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: isVoice ? _voiceBar() : _typingBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? teal : mintB,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingBar() {
    final canSend = _controller.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: teal.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendUserMessage(_controller.text),
              decoration: const InputDecoration(
                hintText: "Type here…",
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: canSend ? () => _sendUserMessage(_controller.text) : null,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: canSend ? teal : teal.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voiceBar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: teal.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _listening ? "Listening… speak now" : "Tap the mic and talk",
              style: TextStyle(
                color: _listening ? teal : slate2,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() => _listening = !_listening);

              // UI-only: when “listening” stops, we pretend a message was captured
              if (_listening == false) {
                _sendUserMessage("Hello companion (voice input demo)");
              }
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _listening ? teal : teal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: teal.withOpacity(0.5)),
              ),
              child: Icon(
                Icons.mic,
                color: _listening ? Colors.white : teal,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}