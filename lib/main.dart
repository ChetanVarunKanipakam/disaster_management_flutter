// lib/main.dart
import 'package:flutter/material.dart';
import 'package:majorproject_flutter/data/repositories/incident_repository.dart';
import 'package:majorproject_flutter/data/repositories/volunteer_repository.dart';
import 'package:majorproject_flutter/providers/settings_provider.dart';
import 'package:majorproject_flutter/providers/volunteer_provider.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/local_storage_service.dart';
import 'providers/auth_provider.dart';

import 'utils/theme.dart';
import 'providers/citizen_provider.dart';
import 'data/services/location_service.dart';
import 'routes.dart';
import 'utils/app_routes.dart';
void main() {
  // --- Dependency Injection Setup ---
  // Create instances of services and repositories
  final localStorageService = LocalStorageService();
  final apiService = ApiService(localStorageService);
  final authRepository = AuthRepository(apiService,localStorageService);
  final incidentRepository = IncidentRepository(apiService);
  final volunteerRepository = VolunteerRepository(apiService);
  final locationService=LocationService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider(create: (_) => CitizenProvider(incidentRepository,locationService)),
        // Add other providers here, e.g., for incidents, profile, etc.
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_)=> VolunteerProvider(incidentRepository, volunteerRepository,locationService))
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disaster Response App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

