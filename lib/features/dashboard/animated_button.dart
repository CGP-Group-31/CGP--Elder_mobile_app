import 'package:flutter/material.dart';
import '../theme.dart';

class AnimatedWellBeingCard extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedWellBeingCard({super.key, required this.onTap});

  @override
  State<AnimatedWellBeingCard> createState() => _AnimatedWellBeingCardState();
}

class _AnimatedWellBeingCardState extends State<AnimatedWellBeingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                "Well-being check",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Click here",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedButton({super.key, required this.onPressed, required this.text});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // repeat back and forth

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: Text(widget.text),
      ),
    );
  }
}