// lib/data/models/incident_model.dart
class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String type;
  final String severity;
  final String status;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final DateTime createdAt;
  final String reportedById;
  final String? assignedToId;
  final double? distance; // UI-only

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.severity,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.createdAt,
    required this.reportedById,
    this.assignedToId,
    this.distance,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    return IncidentModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      severity: json['severity'],
      status: json['status'],
      latitude: (json['location']['coordinates'][1] as num).toDouble(),
      longitude: (json['location']['coordinates'][0] as num).toDouble(),
      photoUrl: json['photoUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      reportedById: json['reportedById'],
      assignedToId: json['assignedToId'],
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}