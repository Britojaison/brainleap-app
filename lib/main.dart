import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/environment.dart';
import 'providers/ai_assistant_provider.dart';
import 'providers/auth_provider.dart';
import 'views/auth_wrapper.dart';
import 'views/login_view.dart';
import 'views/practice_view.dart';
import 'views/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.load();
  runApp(const BrainLeapApp());
}

class BrainLeapApp extends StatelessWidget {
  const BrainLeapApp({super.key, this.initialIndex = 0});

  final int initialIndex;

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
  const MainNavigationView({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  late int _selectedIndex;

  static const List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      icon: Icons.brush,
      label: 'Home',
      page: const PracticeView(),
      appBarTitle: null,
    ),
    _NavigationItem(
      icon: Icons.history,
      label: 'History',
      page: HistoryPlaceholderView(),
      appBarTitle: 'History',
    ),
    _NavigationItem(
      icon: Icons.settings,
      label: 'Settings',
      page: const SettingsView(),
      appBarTitle: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, _navigationItems.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final current = _navigationItems[_selectedIndex];
    return Scaffold(
      appBar: current.appBarTitle == null
          ? null
          : AppBar(title: Text(current.appBarTitle!)),
      body: current.page,
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
  final String? appBarTitle;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.page,
    this.appBarTitle,
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
