import '../services/api_service.dart';
import '../models/volunteer_model.dart';
import 'package:dio/dio.dart';
class VolunteerRepository {
  final ApiService _apiService;
  VolunteerRepository(this._apiService);

  Future<void> updateAvailability(String userId, double latitude, double longitude,bool isAvailable) async {
    print(userId);
    print(latitude);print(longitude);
    print(isAvailable);
    await _apiService.client.put('/volunteers/$userId', data: {'isAvailable': isAvailable,'latitude': latitude, 'longitude': longitude});
  }
   Future<VolunteerProfileModel> getVolunteerProfile() async {
    try {
      final response = await _apiService.client.get('/volunteers/me');
      return VolunteerProfileModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Failed to load volunteer profile.';
      throw errorMessage;
    }
  }

  // Add other volunteer-specific methods here if needed
}