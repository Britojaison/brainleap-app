import 'package:flutter/material.dart';

class AiHintButton extends StatelessWidget {
  const AiHintButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.smart_toy_outlined),
      label: const Text('Ask AI for Help'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
