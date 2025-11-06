import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
class AuthRepository {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;
  AuthRepository(this._apiService, this._localStorageService);

  Future<UserModel> login(String email, String password) async {
    print(email+password);
    final response = await _apiService.client.post('/auth/login', data: {'email': email, 'password': password});
    print(response);
    await _localStorageService.saveToken(response.data['accessToken']);
    return UserModel.fromJson(response.data);
  }

  Future<void> signup({required String name, required String email, required String password, required String role}) async {
    await _apiService.client.post('/auth/signup', data: {'name': name, 'email': email, 'password': password, 'role': role});
  }
  Future<UserModel> getUser() async {
    final response = await _apiService.client.get('/users/me');
    print(response.data);
    return UserModel.fromJson(response.data);
  }
 Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    required String phone,
    XFile? imageFile,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'phone': phone,
      };

      if (imageFile != null) {
        data['photo'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
        );
      }

      final formData = FormData.fromMap(data);

      final response = await _apiService.client.put(
        '/users/me',
        data: formData,
      );
      print(response);
      return {'success': true, 'data': response.data};

    } on DioException catch (e) {
      // THE FIX IS IN THIS CATCH BLOCK
      String errorMessage = 'An unknown error occurred.';

      // CORRECTED: First, check if the response data is a Map.
      if (e.response?.data is Map<String, dynamic>) {
        // If it is a Map, now it's safe to try and access the 'message' key.
        final responseData = e.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('message') && responseData['message'] is String) {
          errorMessage = responseData['message'];
        }
      } 
      // Add more specific checks for connection errors
      else if (e.type == DioExceptionType.connectionTimeout || 
               e.type == DioExceptionType.sendTimeout || 
               e.type == DioExceptionType.receiveTimeout || 
               e.type == DioExceptionType.connectionError) {
        errorMessage = 'Failed to connect to the server. Please check your connection.';
      } 
      // If the response data is not a Map, we can't get a specific message from it.
      // The generic error message will be used.
      print(errorMessage);
      return {'success': false, 'error': errorMessage};

    } catch (e) {
      // Handle any other unexpected errors
      return {'success': false, 'error': 'An unexpected error occurred: $e'};
    }
  }

  Future<void> logout() => _localStorageService.deleteToken();
  Future<String?> getToken() => _localStorageService.getToken();
}