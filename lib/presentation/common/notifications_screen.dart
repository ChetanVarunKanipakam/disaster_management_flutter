import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago; // For user-friendly dates
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/services/api_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../utils/app_routes.dart'; // For navigation

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // We use a Future to hold the result of our API call
  late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationRepository _repository = NotificationRepository(ApiService(LocalStorageService()));

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _repository.getNotifications();
    });
  }

  // Helper function to determine the icon based on the title
  IconData _getIconForNotification(String title) {
    if (title.toLowerCase().contains('assignment') || title.toLowerCase().contains('assigned')) {
      return Icons.assignment_ind_outlined;
    }
    if (title.toLowerCase().contains('status')) {
      return Icons.info_outline;
    }
    if (title.toLowerCase().contains('welcome')) {
      return Icons.check_circle_outline;
    }
    return Icons.notifications_outlined; // Default icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: GoogleFonts.poppins(color: Colors.redAccent)));
          }

          // 3. No Data or Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications found.', style: GoogleFonts.poppins(color: Colors.white70)));
          }

          // 4. Success State
          final notifications = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadNotifications(),
            color: const Color(0xFFFFC107),
            backgroundColor: const Color(0xFF1F1F1F),
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final bool isRead = notification.isRead;

                return Card(
                  color: isRead ? const Color(0xFF1F1F1F) : const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isRead ? BorderSide.none : const BorderSide(color: Color(0xFFFFC107), width: 1.5),
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    leading: CircleAvatar(
                      backgroundColor: isRead ? Colors.white24 : const Color(0xFFFFC107),
                      child: Icon(_getIconForNotification(notification.title), color: isRead ? Colors.white70 : const Color(0xFF121212)),
                    ),
                    title: Text(
                      notification.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      // Use the timeago package for "2 hours ago", "1 day ago" etc.
                      timeago.format(notification.createdAt),
                      style: GoogleFonts.poppins(color: Colors.white70),
                    ),
                    onTap: () {
                      // Mark as read and then navigate if there's an incidentId
                      if (!isRead) {
                        _repository.markAsRead(notification.id).then((_) => _loadNotifications());
                      }
                      if (notification.incidentId != null) {
                        
                        Navigator.pushNamed(context, AppRoutes.incidentDetails, arguments: notification.incidentId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Navigate to incident ${notification.incidentId}')),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}