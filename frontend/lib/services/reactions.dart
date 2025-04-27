import 'package:flutter/material.dart';

class Reaction extends StatefulWidget {
  final String emoji;
  final String label;
  final void Function() onTap; // Add onTap parameter

  const Reaction({
    super.key,
    required this.emoji,
    required this.label,
    required this.onTap, // Include onTap in the constructor
  });

  @override
  State<Reaction> createState() => _ReactionState();
}

class _ReactionState extends State<Reaction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: -4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4, end: 4), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4, end: 0), weight: 1),
    ]).animate(_controller);
  }

  void _vibrate() {
    _controller.forward(from: 0);
    widget.onTap(); // Call the onTap function passed from the parent
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _vibrate, // Trigger _vibrate method on tap
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _offsetAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_offsetAnimation.value, 0),
                child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
