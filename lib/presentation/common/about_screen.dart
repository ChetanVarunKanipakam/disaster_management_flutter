import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'About',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Disaster Response',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This app connects citizens, volunteers, and authorities during emergencies. Our mission is to provide a reliable platform for reporting incidents, coordinating volunteer efforts, and disseminating critical information to ensure community safety and resilience.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Emergency Helpline Numbers',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildHelplineCard(
              context,
              title: 'Ambulance',
              number: '102',
              icon: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: 12),
            _buildHelplineCard(
              context,
              title: 'Fire Department',
              number: '101',
              icon: Icons.local_fire_department_outlined,
            ),
            const SizedBox(height: 12),
            _buildHelplineCard(
              context,
              title: 'Police',
              number: '100',
              icon: Icons.local_police_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelplineCard(BuildContext context, {required String title, required String number, required IconData icon}) {
    return Card(
      color: const Color(0xFF1F1F1F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFFFC107), size: 30),
        title: Text(
          title,
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          number,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_outlined, color: Colors.white70),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: number));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title number copied to clipboard')),
            );
          },
        ),
      ),
    );
  }
}