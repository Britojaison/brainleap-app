import 'package:flutter/material.dart';

import 'config/environment.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';
import 'views/ai_hint_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Environment.load();
  runApp(const BrainLeapApp());
}

class BrainLeapApp extends StatefulWidget {
  const BrainLeapApp({super.key});

  @override
  State<BrainLeapApp> createState() => _BrainLeapAppState();
}

class _BrainLeapAppState extends State<BrainLeapApp> {
  int _selectedIndex = 0;

  final _pages = const [
    HomeView(),
    HistoryPlaceholderView(),
    SettingsPlaceholderView(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrainLeap',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Scaffold(
        appBar: AppBar(title: Text(_titleForIndex(_selectedIndex))),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AiHintView(
                  questionId: 'demo-question',
                  canvasState: 'serialized-canvas-state',
                ),
              ),
            );
          },
          label: const Text('AI Hint'),
          icon: const Icon(Icons.smart_toy_outlined),
        ),
      ),
      routes: {
        LoginView.routeName: (_) => const LoginView(),
      },
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'History';
      case 2:
        return 'Settings';
      default:
        return 'BrainLeap';
    }
  }
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
    return const Center(
      child: Text('Settings will appear here.'),
    );
  }
}
