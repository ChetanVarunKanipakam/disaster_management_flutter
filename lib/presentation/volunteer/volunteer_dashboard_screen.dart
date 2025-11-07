import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:majorproject_flutter/data/models/incident_model.dart';
import 'package:provider/provider.dart';
import '../../data/models/user_model.dart'; // Ensure you have a UserModel
import '../../providers/auth_provider.dart';
import '../../providers/volunteer_provider.dart';
import '../../utils/app_routes.dart';
import '../widgets/incident_card.dart'; // Make sure this path is correct
import 'my_assignments_screen.dart';
import 'nearby_incidents.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  const VolunteerDashboardScreen({super.key});
  @override
  _VolunteerDashboardScreenState createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // This callback runs after the first frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // *** FIX IS HERE ***
      // Use context.read() inside callbacks like initState.
      // This calls the method without trying to 'listen' for changes, preventing the crash.
      context.read<VolunteerProvider>().fetchVolunteerProfile();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      });
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107))),
      );
    }

    final List<Widget> widgetOptions = <Widget>[
      VolunteerDashboardContent(user: user),
      const IncidentList(), // Assuming IncidentList is a defined widget
      MyAssingnmentsScreen(user: user)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Volunteer Dashboard'
              : (_selectedIndex == 1
                  ? 'Nearby Incidents'
                  : 'My Assignment History'),
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            // The Consumer widget ensures the Switch rebuilds when the provider state changes.
            child: Consumer<VolunteerProvider>(
              builder: (context, provider, child) {
                if (provider.isProfileLoading && provider.volunteerProfile == null) {
                  return const SizedBox(
                      width: 48,
                      child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))));
                }
                return Switch(
                  value: provider.volunteerProfile?.isAvailable ?? false,
                  onChanged: (val) {
                    // Use context.read() here as well, for the same reason:
                    // onChanged is a callback for triggering an action.
                    context
                        .read<VolunteerProvider>()
                        .toggleAvailability(user.id, val);
                  },
                  activeThumbColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.grey,
                  activeColor: Colors.green,
                );
              },
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Nearby',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_history_outlined),
            label: 'Assignments',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF1F1F1F),
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),
    );
  }
}

// Main content of the volunteer dashboard (Assigned Incidents)
class VolunteerDashboardContent extends StatefulWidget {
  final UserModel user;
  const VolunteerDashboardContent({super.key, required this.user});

  @override
  _VolunteerDashboardContentState createState() =>
      _VolunteerDashboardContentState();
}

class _VolunteerDashboardContentState extends State<VolunteerDashboardContent> {
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<VolunteerProvider>();
    if (provider.assignedIncidents.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use read here as well, following the rule.
        provider.fetchAssignedIncidents(widget.user.id);
      });
    }
  }

  Set<Marker> _createMarkers(List<IncidentModel> incidents) {
    return incidents.map((incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.latitude, incident.longitude),
        infoWindow: InfoWindow(
          title: incident.title,
          snippet: 'Status: ${incident.status}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }).toSet();
  }

  void _focusOnIncident(IncidentModel incident) {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(incident.latitude, incident.longitude),
        16.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VolunteerProvider>(
      builder: (context, provider, child) {
        final pendingIncidents = provider.assignedIncidents
            .where((e) => e.status.toUpperCase() != "RESOLVED")
            .toList();

        final Set<Marker> markers = _createMarkers(pendingIncidents);

        return Column(
          children: [
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.7749, -122.4194),
                  zoom: 11,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                markers: markers,
              ),
            ),
            Expanded(
              child: _buildIncidentList(provider, pendingIncidents),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncidentList(
      VolunteerProvider provider, List<IncidentModel> incidents) {
    if (provider.isLoading && incidents.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFC107)));
    }

    if (provider.errorMessage != null && incidents.isEmpty) {
      return Center(
          child: Text(provider.errorMessage!,
              style: GoogleFonts.poppins(color: Colors.white70)));
    }

    if (incidents.isEmpty) {
      return Center(
          child: Text('No pending incidents assigned.',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchAssignedIncidents(widget.user.id),
      color: const Color(0xFFFFC107),
      backgroundColor: const Color(0xFF1F1F1F),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: incidents.length,
        itemBuilder: (context, index) {
          final incident = incidents[index];
          return GestureDetector(
            onTap: () => _focusOnIncident(incident),
            child: IncidentCard(incident: incident),
          );
        },
      ),
    );
  }
}

// Reusable Side Drawer Widget (Top-level)
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1F1F1F),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFFFC107)),
            child: Text(
              'Menu',
              style: GoogleFonts.poppins(
                color: const Color(0xFF121212),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.about);
            },
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.settings1);
            },
          ),
          const Divider(color: Colors.white24),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      onTap: onTap,
    );
  }
}