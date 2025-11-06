import 'package:dio/dio.dart';
import 'package:majorproject_flutter/utils/constants.dart';
import 'local_storage_service.dart';

class ApiService {
  final Dio _dio;
  ApiService(LocalStorageService localStorageService) : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        final token = await localStorageService.getToken();
        if (token != null) options.headers['x-access-token'] = token;
        return handler.next(options);
      }),
    );
  }
  Dio get client => _dio;
}
// class ApiService {
//   final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: AppConstants.baseUrl,
//       connectTimeout: const Duration(seconds: 10),
//       receiveTimeout: const Duration(seconds: 10),
//       headers: {
//         "Content-Type": "application/json",
//       },
//     ),
//   );

//   Dio get dio => _dio;
// }