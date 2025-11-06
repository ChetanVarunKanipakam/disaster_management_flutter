import 'package:flutter/material.dart';
import 'package:majorproject_flutter/presentation/common/update_user_details_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/signup_screen.dart';
import 'presentation/auth/splash_screen.dart';
import 'presentation/citizen/citizen_dashboard_screen.dart';
import 'presentation/citizen/my_reports_screen.dart';
import 'presentation/citizen/report_incident_screen.dart';
import 'presentation/common/about_screen.dart';
import 'presentation/common/incident_details_screen.dart';
import 'presentation/common/notifications_screen.dart';
import 'presentation/common/profile_screen.dart';
import 'presentation/common/settings_screen.dart';
import 'presentation/volunteer/my_assignments_screen.dart';
import 'presentation/volunteer/volunteer_dashboard_screen.dart';
import 'data/models/incident_model.dart';
import 'utils/app_routes.dart';
import 'data/models/user_model.dart';
class AppRouter {
  
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case AppRoutes.citizenDashboard:
        return MaterialPageRoute(builder: (_) => const CitizenDashboardScreen());
      case AppRoutes.volunteerDashboard:
        return MaterialPageRoute(builder: (_) => const VolunteerDashboardScreen());
      case AppRoutes.reportIncident:
        return MaterialPageRoute(builder: (_) => const ReportIncidentScreen());
      case AppRoutes.myReports:
        return MaterialPageRoute(builder: (_) => const MyReportsScreen());
      case AppRoutes.myAssignments:
        if (settings.arguments is UserModel) {
          return MaterialPageRoute(builder: (_) => MyAssingnmentsScreen(user : settings.arguments as UserModel));
        }
        return _errorRoute();
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.settings1:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case AppRoutes.updateProfile:
        return MaterialPageRoute(builder: (_) => const UpdateProfileScreen());
      case AppRoutes.incidentDetails:
        if (settings.arguments is IncidentModel) {
          return MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incident: settings.arguments as IncidentModel));
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Page not found')));
    });
  }
}