import 'package:flutter/material.dart';

class NearbyIncidentsScreen extends StatelessWidget {
  const NearbyIncidentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Incidents')),
      body: Column(
        children: [
          // Add filter chips for severity, type, etc.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterChip(label: Text('High'), onSelected: (b){}),
                FilterChip(label: Text('Medium'), onSelected: (b){}),
                FilterChip(label: Text('Low'), onSelected: (b){}),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with actual data from provider
              itemBuilder: (context, index) {
                return ListTile(title: Text('Nearby Incident $index'));
              },
            ),
          ),
        ],
      ),
    );
  }
}