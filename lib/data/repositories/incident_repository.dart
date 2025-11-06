import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../models/incident_model.dart';
import '../services/api_service.dart';

class IncidentRepository {
  final ApiService _apiService;
  IncidentRepository(this._apiService);

  Future<List<IncidentModel>> getNearbyIncidents(double lat, double lon, {double radius = 10000}) async {
    final response = await _apiService.client.get('/incidents/nearby', queryParameters: {'lat': lat, 'lon': lon, 'radius': radius});
    return (response.data as List).map((item) => IncidentModel.fromJson(item)).toList();
  }

  Future<List<IncidentModel>> getMyReports() async {
    final response = await _apiService.client.get('/incidents/my-reports');
    return (response.data as List).map((item) => IncidentModel.fromJson(item)).toList();
  }

  Future<List<IncidentModel>> getAssignedIncidents(String volunteerId) async {
    final response = await _apiService.client.get('/incidents/assigned-to/$volunteerId');
    return (response.data as List).map((item) => IncidentModel.fromJson(item)).toList();
  }

  Future<IncidentModel> getIncidentDetails(String id) async {
    final response = await _apiService.client.get('/incidents/$id');
    return IncidentModel.fromJson(response.data);
  }

  Future<void> reportIncident({
    required String title, required String description, required String type,
    required String severity, required double latitude, required double longitude, required XFile image
  }) async {
    String fileName = image.path.split('/').last;
    FormData formData = FormData.fromMap({
      'title': title, 'description': description, 'type': type, 'severity': severity,
      'latitude': latitude, 'longitude': longitude,
      'photo': await MultipartFile.fromFile(image.path, filename: fileName),
    });
    await _apiService.client.post('/incidents', data: formData);
  }

  Future<void> updateIncidentStatus(String id, String status) async {
     await _apiService.client.put('/incidents/$id/status', data: {'status': status});
  }
}