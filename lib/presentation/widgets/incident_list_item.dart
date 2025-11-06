import 'package:flutter/material.dart';
import '../../data/models/incident_model.dart';
import 'package:intl/intl.dart';

class IncidentListItem extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const IncidentListItem({super.key, required this.incident, required this.onTap});

  Color _getSeverityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'HIGH': return Colors.red;
      case 'MEDIUM': return Colors.orange;
      case 'LOW': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(incident.severity),
          child: Icon(Icons.warning_amber_rounded, color: Colors.white),
        ),
        title: Text(incident.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${incident.type} - Status: ${incident.status}'),
        trailing: Text(DateFormat.yMd().add_jm().format(incident.createdAt)),
      ),
    );
  }
}