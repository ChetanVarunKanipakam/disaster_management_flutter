import '../models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService;
  UserRepository(this._apiService);

  Future<UserModel> getCurrentUser() async {
    final response = await _apiService.client.get('/users/me');
    return UserModel.fromJson(response.data);
  }

  Future<void> updateUser(String name, String phone) async {
    await _apiService.client.put('/users/me', data: {'name': name, 'phone': phone});
  }
}