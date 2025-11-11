import 'package:flutter/material.dart';

/// Displays the BrainLeap settings experience with toggleable notifications,
/// quick links for content pages, and a logout affordance.
class SettingsView extends StatefulWidget {
  /// Creates a new settings view.
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;

  static const List<_SettingsLinkItem> _linkItems = [
    _SettingsLinkItem(label: 'Privacy Policy', icon: Icons.verified_user_outlined),
    _SettingsLinkItem(label: 'Feedback', icon: Icons.chat_bubble_outline),
    _SettingsLinkItem(label: 'Terms and Conditions', icon: Icons.description_outlined),
    _SettingsLinkItem(label: 'Rate Us', icon: Icons.star_border_rounded),
    _SettingsLinkItem(label: 'Share with your friends', icon: Icons.send_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 20),
            _SettingsCard(
              child: Column(
                children: [
                  _NotificationToggleRow(
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                  const Divider(height: 28),
                  for (final item in _linkItems) ...[
                    _SettingsLinkTile(item: item),
                    if (item != _linkItems.last) const Divider(height: 28),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: _LogoutButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout action will be implemented soon.'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NotificationToggleRow extends StatelessWidget {
  const _NotificationToggleRow({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _SettingsIcon(
          icon: Icons.notifications_none_outlined,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Notification',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Switch.adaptive(
          key: const ValueKey('settings_notification_toggle'),
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF111827),
        ),
      ],
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({required this.item});

  final _SettingsLinkItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _SettingsIcon(icon: item.icon),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            item.label,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: Color(0xFF111827),
        ),
      ],
    );
  }
}

class _SettingsIcon extends StatelessWidget {
  const _SettingsIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF111827),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            key: const ValueKey('settings_logout_button'),
            onPressed: onPressed,
            icon: const Icon(
              Icons.power_settings_new,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Logout',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _SettingsLinkItem {
  const _SettingsLinkItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

