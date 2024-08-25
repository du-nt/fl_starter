import 'package:dio/dio.dart';

final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com/',
    headers: {'Content-Type': 'application/json'}))
  ..interceptors.add(QueuedInterceptorsWrapper(
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        try {
          // Refresh the token
          final newToken = await refreshToken();

          // Update the token in storage
          await updateStoredToken(newToken);

          // Update the header
          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          // Retry the request
          final response = await dio.fetch(error.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          // If refresh fails, propagate the error
          return handler.reject(error);
        }
      }
      return handler.next(error);
    },
  ));

Future<String> refreshToken() async {
  // Implement your token refresh logic here
  // This might involve making an API call to your auth server
  return '';
}

Future<void> updateStoredToken(String newToken) async {
  // Update the token in your local storage (e.g., SharedPreferences)
}
