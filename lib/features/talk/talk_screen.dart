import 'package:flutter/material.dart';
import 'ai_companion.dart';

class TalkToCompanionScreen extends StatelessWidget {
  const TalkToCompanionScreen({super.key});

  // Palette
  static const Color teal = Color(0xFF2E7D7A);
  static const Color mintA = Color(0xFFD6EFE6);
  static const Color mintB = Color(0xFFBEE8DA);
  static const Color ink = Color(0xFF243333);
  static const Color slate = Color(0xFF6F7F7D);

  static const Color warmGold = Color(0xFFE6B566);
  static const Color warmBlush = Color(0xFFFBDADA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mintA,

      // ✅ Solid green top like Messages (no white blend)
      appBar: AppBar(
        backgroundColor: teal,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Talk to Companion",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
          child: Column(
            children: [
              Text(
                "I’m listening…",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: ink,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),

              const _WaveBar(color: warmGold),
              const SizedBox(height: 36),

              // START TALKING BUTTON
              SizedBox(
                width: double.infinity,
                height: 68,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIChatScreen(
                          mode: AIChatMode.voice,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic, size: 28),
                  label: const Text(
                    "Start Talking",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: warmGold,
                    foregroundColor: ink,
                    elevation: 4,
                    shadowColor: warmGold.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // TYPE MESSAGE BUTTON
              SizedBox(
                width: double.infinity,
                height: 68,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIChatScreen(
                          mode: AIChatMode.typing,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 26,
                    color: teal,
                  ),
                  label: const Text(
                    "Type Message",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: ink,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: warmBlush,
                    side: const BorderSide(color: teal, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                "Tap to speak or type with your companion",
                style: TextStyle(
                  color: slate,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // SUPPORT CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mintB,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: warmGold.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: warmGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: warmGold.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: warmGold,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        "Your companion can help you feel supported and guide you with simple steps.",
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  final Color color;
  const _WaveBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _bar(12),
          _gap(),
          _bar(18),
          _gap(),
          _bar(28),
          _gap(),
          _bar(40),
          _gap(),
          _bar(28),
          _gap(),
          _bar(18),
          _gap(),
          _bar(12),
        ],
      ),
    );
  }

  Widget _gap() => const SizedBox(width: 10);

  Widget _bar(double h) {
    return Container(
      width: 10,
      height: h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}