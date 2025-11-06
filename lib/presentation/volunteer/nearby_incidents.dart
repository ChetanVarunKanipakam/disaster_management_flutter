import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/citizen_provider.dart';
import '../widgets/incident_card.dart';

class IncidentList extends StatefulWidget {
  const IncidentList({super.key});

  @override
  State<IncidentList> createState() => _IncidentListState();
}

class _IncidentListState extends State<IncidentList> {
    @override
  void initState() {
    super.initState();
    // Fetch initial data only if the list is empty
    final provider = context.read<CitizenProvider>();
    if(provider.nearbyIncidents.isEmpty){
       WidgetsBinding.instance.addPostFrameCallback((_) {
         provider.fetchNearbyIncidents();
       });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CitizenProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.nearbyIncidents.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
        }
        if (provider.errorMessage != null && provider.nearbyIncidents.isEmpty) {
          return Center(child: Text(provider.errorMessage!, style: GoogleFonts.poppins(color: Colors.white70)));
        }
        if (provider.nearbyIncidents.isEmpty) {
          return Center(child: Text('No incidents reported nearby.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)));
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchNearbyIncidents(),
          color: const Color(0xFFFFC107),
          backgroundColor: const Color(0xFF1F1F1F),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.nearbyIncidents.length,
            itemBuilder: (context, index) {
              final incident = provider.nearbyIncidents[index];
              return IncidentCard(incident: incident);
            },
          ),
        );
      },
    );
  }
}
