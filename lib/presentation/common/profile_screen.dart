import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_routes.dart';
import '../../utils/constants.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
   
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: Text("My Profile", style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: const Color(0xFF1F1F1F),
        ),
        body: Center(
          child: Text(
            "User not found. Please log in again.",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
      
    }
    print(user.profilePictureUrl);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFFFC107),
              backgroundImage: (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty)
                              ? NetworkImage(AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 3) + user.profilePictureUrl!)
                              : null,
              // child: user.profilePictureUrl==null? Text(
              //   user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              //   style: GoogleFonts.poppins(
              //     fontSize: 48,
              //     fontWeight: FontWeight.bold,
              //     color: const Color(0xFF121212),
              //   ),): Image.network(
              //     AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 3) + (user.profilePictureUrl?? ""),
              //     height: 250,
              //     width: double.infinity,
              //     fit: BoxFit.cover,
              //     loadingBuilder: (context, child, loadingProgress) {
              //       if (loadingProgress == null) return child;
              //       return const SizedBox(
              //         height: 250,
              //         child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
              //       );
              //     },
              //     errorBuilder: (context, error, stackTrace) {
              //       return const SizedBox(
              //         height: 250,
              //         child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.white24),
              //       );
              //     },
              //   ),
              ),
            ),
        
          const SizedBox(height: 16),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 32),
          // Role-specific card for history or reports
          // if (isVolunteer)
          //   _buildProfileCard(
          //     title: 'My Assignment History',
          //     icon: Icons.work_history_outlined,
          //     onTap: () => Navigator.pushNamed(context, AppRoutes.myAssignments),
          //   )
          // else
          //   _buildProfileCard(
          //     title: 'My Reports',
          //     icon: Icons.receipt_long_outlined,
          //     onTap: () => Navigator.pushNamed(context, AppRoutes.myReports),
          //   ),
          const SizedBox(height: 12),
          // Edit Profile Card
          _buildProfileCard(
            title: 'Edit Profile Information',
            icon: Icons.edit_note_outlined,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.updateProfile);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard({required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFC107)),
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}