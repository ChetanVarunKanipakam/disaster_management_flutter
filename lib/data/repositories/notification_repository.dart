import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationRepository {
  final ApiService _apiService;

  NotificationRepository(this._apiService);

  /// Fetches a list of notifications for the current user from the API.
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiService.client.get('/notifications/me');
      
      if (response.data is List) {
        final List<dynamic> dataList = response.data;
        // Map the list of JSON objects to a list of NotificationModel objects
        return dataList.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        // Handle cases where the response is not a list
        throw 'Invalid response format: Expected a list of notifications.';
      }
    } on DioException catch (e) {
      // Re-throw the error to be handled by the UI layer (e.g., FutureBuilder)
      final errorMessage = e.response?.data?['message'] ?? 'Failed to load notifications.';
      throw errorMessage;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.client.put('/notifications/$notificationId/read');
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? 'Failed to update notification.';
      throw errorMessage;
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }
}