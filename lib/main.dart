import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/environment.dart';
import 'providers/auth_provider.dart';
import 'providers/ai_assistant_provider.dart';
import 'services/supabase_service.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.load();
  await SupabaseService.instance.initialize();
  runApp(const BrainLeapApp());
}

class BrainLeapApp extends StatelessWidget {
  const BrainLeapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BrainLeap',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          // Enhanced theme for better UI
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        home: const AuthWrapper(), // Start with AuthWrapper
        routes: {
          LoginView.routeName: (_) => const LoginView(),
        },
      ),
    );
  }
}

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.home,
      label: 'Home',
      page: HomeView(),
    ),
    _NavigationItem(
      icon: Icons.history,
      label: 'History',
      page: HistoryPlaceholderView(),
    ),
    _NavigationItem(
      icon: Icons.settings,
      label: 'Settings',
      page: SettingsPlaceholderView(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_navigationItems[_selectedIndex].label)),
      body: _navigationItems[_selectedIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final String label;
  final Widget page;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

class HistoryPlaceholderView extends StatelessWidget {
  const HistoryPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('History timeline will appear here.'),
    );
  }
}

class SettingsPlaceholderView extends StatelessWidget {
  const SettingsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Profile Section
            if (authProvider.user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          authProvider.user!.displayName?.substring(0, 1).toUpperCase() ?? 
                          authProvider.user!.email.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        authProvider.user!.displayName ?? 'User',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user!.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Settings Options
            const Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification settings coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: const Text('Language'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Language settings coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Mode'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Theme settings coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About Section
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outlined),
                    title: const Text('About BrainLeap'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'BrainLeap',
                        applicationVersion: '0.0.1',
                        applicationIcon: const Icon(Icons.psychology, size: 48),
                        children: [
                          const Text('AI-Powered Learning Platform'),
                          const SizedBox(height: 8),
                          const Text('Helping students learn better with AI assistance.'),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy policy coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms of service coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                // Show confirmation dialog
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && context.mounted) {
                  await authProvider.logout();
                  // AuthWrapper will automatically navigate to login screen
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // App Version
            Center(
              child: Text(
                'Version 0.0.1',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
