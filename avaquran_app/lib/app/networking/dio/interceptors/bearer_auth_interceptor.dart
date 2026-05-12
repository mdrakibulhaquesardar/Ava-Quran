import 'dart:convert';
import '/config/storage_keys.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BearerAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Read validated user metadata synchronously from internal cache
    dynamic authData = Auth.data();
    if (authData == null) return super.onRequest(options, handler);
    
    // ELASTIC DESERIALIZATION: If Nylo returns stored complex object as string, recover it
    if (authData is String && authData.trim().startsWith("{")) {
      try {
         authData = jsonDecode(authData);
      } catch (e) {
         // Non-JSON string detected, skip decoding
      }
    }

    // Final Guard: Ensure object is addressable before indexing
    if (authData is! Map) return super.onRequest(options, handler);

    // Attempt to locate resolution hash from internal nested dictionary
    final dynamic token = authData['token'] ?? authData['access_token'];
    
    if (token != null && token.toString().isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }
    
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await Auth.logout();
      routeToInitial();
    }
    handler.next(err);
  }
}
