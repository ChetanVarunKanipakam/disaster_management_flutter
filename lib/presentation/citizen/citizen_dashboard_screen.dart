import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/citizen_provider.dart';
import '../../utils/app_routes.dart';
import '../widgets/incident_card.dart'; // Assuming you have this widget
import 'my_reports_screen.dart'; // Import the MyReportsScreen

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});
  @override
  _CitizenDashboardScreenState createState() => _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState extends State<CitizenDashboardScreen> {
  int _selectedIndex = 0;

  // List of widgets to display in the body
  static final List<Widget> _widgetOptions = <Widget>[
    const IncidentList(), // Main dashboard view
    const MyReportsScreen(), // User's reported incidents view
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Citizen Dashboard' : 'My Reports',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Ensures the drawer icon is white
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
        ],
      ),
      drawer: const AppDrawer(), // Add the side drawer
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.reportIncident),
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add, color: Color(0xFF121212)),
        elevation: 2.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1F1F1F),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.dashboard_outlined, color: _selectedIndex == 0 ? const Color(0xFFFFC107) : Colors.white70),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(Icons.receipt_long_outlined, color: _selectedIndex == 1 ? const Color(0xFFFFC107) : Colors.white70),
                onPressed: () => _onItemTapped(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Main content of the dashboard
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

// Reusable Side Drawer Widget
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings1),
          ),
          const Divider(color: Colors.white24),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: GoogleFonts.poppins(color: Colors.white)),
      onTap: onTap,
    );
  }
}