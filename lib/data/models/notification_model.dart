// lib/data/models/notification_model.dart

/// Represents a notification received by a user.
///
/// This model corresponds to the Notification entity in the backend database.
/// It's used in the NotificationsPage to display alerts to the user.
class NotificationModel {
  /// The unique identifier for the notification.
  final String id;

  /// The title of the notification.
  /// Example: "New High Severity Incident Reported"
  final String title;

  /// The detailed message body of the notification.
  /// Example: "A 'FIRE' incident has been reported 2km away from your location."
  final String body;

  /// A flag indicating whether the user has read the notification.
  /// This is used to visually distinguish read/unread notifications in the UI.
  final bool isRead;

  /// The timestamp when the notification was created on the server.
  final DateTime createdAt;
  
  /// An optional reference to the incident ID that this notification pertains to.
  /// This allows the app to navigate to the specific IncidentDetailsPage when a
  /// notification is tapped.
  final String? incidentId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.incidentId,
  });

  /// A factory constructor to create a `NotificationModel` instance from a JSON map.
  ///
  /// This is used to parse the response from the backend API (`GET /notifications`).
  /// It safely handles data types and potential null values.
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      // Safely access incidentId, which might be null
      incidentId: json['incidentId'] as String?,
    );
  }
}