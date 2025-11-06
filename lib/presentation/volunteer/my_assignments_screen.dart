import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/user_model.dart';
import '../../providers/volunteer_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/incident_card.dart';
class MyAssingnmentsScreen extends StatefulWidget {
  final UserModel user;
  const MyAssingnmentsScreen({super.key, required this.user});

  @override
  _MyAssingnmentsScreenState createState() => _MyAssingnmentsScreenState();
}

class _MyAssingnmentsScreenState extends State<MyAssingnmentsScreen> {

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final provider = context.read<VolunteerProvider>();
      if (provider.assignedIncidents.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.fetchAssignedIncidents(widget.user.id);
        });
    }
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'My Assignment History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<VolunteerProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.assignedIncidents.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
              }
              if (provider.errorMessage != null && provider.assignedIncidents.isEmpty) {
                return Center(child: Text(provider.errorMessage!, style: GoogleFonts.poppins(color: Colors.white70)));
              }
              if (provider.assignedIncidents.isEmpty) {
                return Center(child: Text('No incidents assigned.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)));
              }
              return RefreshIndicator(
                onRefresh: () => provider.fetchAssignedIncidents(widget.user.id),
                color: const Color(0xFFFFC107),
                backgroundColor: const Color(0xFF1F1F1F),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: provider.assignedIncidents.length,
                  itemBuilder: (context, index) {
                    final incident = provider.assignedIncidents[index];
                    return IncidentCard(incident: incident);
                  },
                ),
              );
            },
          ),
    );
  }
}