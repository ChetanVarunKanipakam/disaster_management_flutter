import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSettingsCard(
                child: SwitchListTile(
                  title: Text('Enable Dark Mode', style: GoogleFonts.poppins(color: Colors.white)),
                  value: settings.isDarkMode,
                  onChanged: (value) => settings.toggleDarkMode(value),
                  activeColor: const Color(0xFFFFC107),
                  secondary: const Icon(Icons.dark_mode_outlined, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                child: SwitchListTile(
                  title: Text('Enable Notifications', style: GoogleFonts.poppins(color: Colors.white)),
                  value: settings.areNotificationsEnabled,
                  onChanged: (value) => settings.toggleNotifications(value),
                  activeColor: const Color(0xFFFFC107),
                  secondary: const Icon(Icons.notifications_active_outlined, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsCard(
                child: ListTile(
                  title: Text('Language', style: GoogleFonts.poppins(color: Colors.white)),
                  subtitle: Text('English', style: GoogleFonts.poppins(color: Colors.white70)),
                  leading: const Icon(Icons.language_outlined, color: Colors.white70),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                  onTap: () {
                    // Navigate to language selection screen or show a dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Language selection coming soon!')),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: child,
    );
  }
}