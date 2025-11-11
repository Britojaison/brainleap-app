import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_view.dart';
import '../main.dart';

/// AuthWrapper checks authentication state and routes accordingly
/// This is the entry point of the app after initialization
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Load saved authentication state
    final authProvider = context.read<AuthProvider>();
    await authProvider.initialize();
    
    // Add small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      // Show splash screen while checking auth
      print('🔄 AuthWrapper: Initializing...');
      return const SplashScreen();
    }

    // Watch authentication state
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        print('🔍 AuthWrapper: Checking auth state...');
        print('   - isAuthenticated: ${authProvider.isAuthenticated}');
        print('   - token: ${authProvider.token != null ? "exists" : "null"}');
        print('   - user: ${authProvider.user?.email ?? "null"}');
        
        if (authProvider.isAuthenticated) {
          // User is logged in, show main app
          print('✅ AuthWrapper: User authenticated → Showing MainNavigationView');
          return const MainNavigationView();
        } else {
          // User is not logged in, show login screen
          print('🔒 AuthWrapper: Not authenticated → Showing LoginView');
          return const LoginView();
        }
      },
    );
  }
}

/// Splash screen shown while checking authentication
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'BrainLeap',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'AI-Powered Learning',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

