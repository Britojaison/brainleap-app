import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/environment.dart';
import 'providers/ai_assistant_provider.dart';
import 'providers/auth_provider.dart';
import 'services/supabase_service.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/settings_view.dart';

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
        ),
        home: const MainNavigationView(),
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
      page: SettingsView(),
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

