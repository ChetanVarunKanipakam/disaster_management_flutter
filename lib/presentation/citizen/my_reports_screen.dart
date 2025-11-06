import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/citizen_provider.dart';
import '../widgets/incident_card.dart';
class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});
  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitizenProvider>().fetchMyReports();
    });
  }
  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration - replace with actual data from your provider

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'My Reported Incidents',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<CitizenProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myReports.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
          }
          if (provider.errorMessage != null && provider.myReports.isEmpty) {
            return Center(
              child: Text(
                provider.errorMessage!,
                style: GoogleFonts.poppins(color: Colors.white70),
              ),
            );
          }
          if (provider.myReports.isEmpty) {
            return Center(
              child: Text(
                'No incidents reported nearby.',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchMyReports(),
            color: const Color(0xFFFFC107),
            backgroundColor: const Color(0xFF1F1F1F),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.myReports.length,
              itemBuilder: (context, index) {
                final incident = provider.myReports[index];
                return IncidentCard(incident: incident);
              },
            ),
          );}),
    );
  }
}
