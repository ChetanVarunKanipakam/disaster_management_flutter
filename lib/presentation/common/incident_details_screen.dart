import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:majorproject_flutter/utils/constants.dart';
import '../../data/models/incident_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/volunteer_provider.dart'; // Import the IncidentProvider

class IncidentDetailsScreen extends StatelessWidget {
  final IncidentModel incident; // Passed via navigation

  const IncidentDetailsScreen({super.key, required this.incident});

  // Helper method to show a snackbar
  void _showSnackBar(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // Access the IncidentProvider
    final incidentProvider = context.watch<VolunteerProvider>();
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(title: Text(incident.title)),
        body: Center(
          child: Text(
            "Page not found. Please log in again.",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
      );
    }

    final isVolunteer = user.role == "VOLUNTEER";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Incident Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Incident Image
            if (incident.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  AppConstants.baseUrl.substring(0, AppConstants.baseUrl.length - 4) + (incident.photoUrl ?? ""),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 250,
                      child: Icon(Icons.broken_image_outlined, size: 60, color: Colors.white24),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),

            // Incident Title and Status
            Text(
              incident.title,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusChip('Status', incident.status, _getStatusColor(incident.status)),
                const SizedBox(width: 12),
                _buildStatusChip('Severity', incident.severity, _getSeverityColor(incident.severity)),
              ],
            ),
            const SizedBox(height: 24),

            // Incident Details
            _buildSectionHeader('Details'),
            _buildDetailRow('Type', incident.type, Icons.category_outlined),
            const Divider(color: Colors.white24),
            _buildDetailRow('Description', incident.description, Icons.description_outlined, isMultiline: true),
            const SizedBox(height: 24),

            // Location Map
            _buildSectionHeader('Location'),
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(incident.latitude, incident.longitude),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('incidentLocation'),
                      position: LatLng(incident.latitude, incident.longitude),
                    ),
                  },
                ),
              ),
            ),

            // Volunteer Actions
            if (isVolunteer) ...[
              const SizedBox(height: 24),
              _buildSectionHeader('Volunteer Actions'),
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: [
                  _buildActionChip('Acknowledge', () async {
                    final success = await incidentProvider.updateIncidentStatus(incident.id, 'ACKNOWLEDGED');
                     if (success) {
                      _showSnackBar(context, 'Incident acknowledged!', false);
                    } else {
                      _showSnackBar(context, incidentProvider.errorMessage ?? 'Failed to update.', true);
                    }
                  }),
                  _buildActionChip('In Progress', () async {
                     final success = await incidentProvider.updateIncidentStatus(incident.id, 'IN_PROGRESS');
                      if (success) {
                      _showSnackBar(context, 'Incident in progress.', false);
                    } else {
                      _showSnackBar(context, incidentProvider.errorMessage ?? 'Failed to update.', true);
                    }
                  }),
                  _buildActionChip('Mark as Resolved', () async {
                     final success = await incidentProvider.updateIncidentStatus(incident.id, 'RESOLVED');
                      if (success) {
                        _showSnackBar(context, 'Incident resolved!', false);
                        // Optionally navigate back after resolving
                        Navigator.of(context).pop();
                      } else {
                         _showSnackBar(context, incidentProvider.errorMessage ?? 'Failed to update.', true);
                      }
                  }, isPrimary: true),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Chip(
      label: Text('$label: $value', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87)),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    );
  }

  Widget _buildDetailRow(String title, String content, IconData icon, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, VoidCallback onPressed, {bool isPrimary = false}) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      labelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        color: isPrimary ? const Color(0xFF121212) : const Color(0xFFFFC107),
      ),
      backgroundColor: isPrimary ? const Color(0xFFFFC107) : Colors.white.withOpacity(0.1),
      side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFFFFC107)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RESOLVED':
        return Colors.greenAccent;
      case 'IN_PROGRESS':
        return Colors.orangeAccent;
      case 'ACKNOWLEDGED':
        return Colors.blueAccent;
      case 'NEW':
      default:
        return Colors.redAccent;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH':
        return Colors.redAccent;
      case 'MEDIUM':
        return Colors.orangeAccent;
      case 'LOW':
      default:
        return Colors.yellowAccent;
    }
  }
}