import 'package:flutter/material.dart';

import '../../config/practice_theme.dart';

/// Custom app bar header for practice flow screens
/// Shows: Back button | Title | Cancel button
class PracticeFlowHeader extends StatelessWidget implements PreferredSizeWidget {
  const PracticeFlowHeader({
    super.key,
    required this.title,
    required this.onCancel,
  });

  final String title;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text(
            'Cancel',
            style: PracticeTextStyles.cancelButton,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

