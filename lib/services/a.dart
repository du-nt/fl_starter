import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  AuthInterceptor(this._dio, this._accessToken, this._refreshToken);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Add the token to the request headers if available
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    // If the response is successful, simply pass it along
    return super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
      DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401 && !_isRefreshing) {
      // Token might be expired; initiate token refresh
      _isRefreshing = true;

      try {
        final newTokens = await refreshToken();
        _accessToken = newTokens['accessToken'];
        _refreshToken = newTokens['refreshToken'];

        // Retry the original request with the new access token
        final requestOptions = error.response!.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $_accessToken';

        final response = await _dio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        _isRefreshing = false;
        return handler.resolve(response);
      } on DioException catch (e) {
        _isRefreshing = false;
        return handler.reject(e);
      }
    } else {
      // Pass the error along if it's not a token expiration error
      return super.onError(error, handler);
    }
  }

  Future<Map<String, String>> refreshToken() async {
    // Replace with your actual refresh token logic
    final response =
        await _dio.post('/refresh', data: {'refresh_token': _refreshToken});
    return response.data;
  }

  bool _isRefreshing = false;
}
