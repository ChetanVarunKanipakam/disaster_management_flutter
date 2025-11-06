import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majorproject_flutter/data/models/incident_model.dart';
import '../../utils/app_routes.dart';
class IncidentCard extends StatelessWidget {
  final IncidentModel incident; // Use your actual Incident model here

  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: const Color(0xFF1F1F1F), // Dark card background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFC107), size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    incident.title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Status: ${incident.status}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _getStatusColor(incident.status),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reported at: ${incident.createdAt}', // Replace with actual data field
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.incidentDetails, arguments: incident),
                child: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFFFC107),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

    Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RESOLVED':
        return Colors.greenAccent;
      case 'IN PROGRESS':
        return Colors.orangeAccent;
      case 'NEW':
      default:
        return Colors.redAccent;
    }
  }
}