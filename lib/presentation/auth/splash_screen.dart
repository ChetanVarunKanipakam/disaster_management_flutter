import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_routes.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_navigated) return;
    _navigated = true;

    final authProvider = context.watch<AuthProvider>();

    Future.delayed(const Duration(seconds: 3), () {
      String currHome = AppRoutes.login;
      if (authProvider.status == AuthStatus.Authenticated) {
        final role = authProvider.user?.role;
        if (role == 'VOLUNTEER') {
          currHome = AppRoutes.volunteerDashboard;
        } else {
          currHome = AppRoutes.citizenDashboard;
        }
      }
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, currHome, (route) => false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.shield_outlined,
                color: Color(0xFFFFC107),
                size: 100.0,
              ),
              const SizedBox(height: 24.0),
              Text(
                'Community Alert',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                'Be Prepared. Stay Safe.',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 40.0),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}