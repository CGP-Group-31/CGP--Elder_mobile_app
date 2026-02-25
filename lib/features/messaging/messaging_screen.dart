import 'package:flutter/material.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _ChatMessage {
  final String text;
  final DateTime time;
  final bool isMe;

  _ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}

class _MessagingScreenState extends State<MessagingScreen> {
  // Color palette
  static const Color teal = Color(0xFF2E7D7A);
  static const Color mintA = Color(0xFFD6EFE6);
  static const Color mintB = Color(0xFFBEE8DA);
  static const Color cream = Color(0xFFF6F7F3);
  static const Color ink = Color(0xFF243333);
  static const Color slate = Color(0xFF6F7F7D);
  static const Color slate2 = Color(0xFF7C8B89);
  static const Color gold = Color(0xFFE6B566);
  static const Color red = Color(0xFFC62828);
  static const Color pink = Color(0xFFFBDADA);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Hello! How are you feeling today?",
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      isMe: false,
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: _controller.text.trim(),
          time: DateTime.now(),
          isMe: true,
        ),
      );
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour >= 12 ? "PM" : "AM";
    return "$h:$m $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      // CLEAN APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Messages",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
        child: Column(
          children: [

            // Quick reply chips
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _quickChip("I’m okay", mintB, ink),
                  _quickChip("I need help", pink, red),
                  _quickChip("I took my medicine", mintB, ink),
                  _quickChip("Call me", gold, ink),
                ],
              ),
            ),

            // Messages list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _messageBubble(msg);
                },
              ),
            ),

            // Input field
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: teal.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Type your message…",
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: teal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String text, Color bg, Color textColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _messages.add(
            _ChatMessage(
              text: text,
              time: DateTime.now(),
              isMe: true,
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(_ChatMessage msg) {
    final bool isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment:
            isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                color: isMe ? teal : mintB,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isMe ? Colors.white : ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.time),
              style: const TextStyle(
                fontSize: 12,
                color: slate2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}