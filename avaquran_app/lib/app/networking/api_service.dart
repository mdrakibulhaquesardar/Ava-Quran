import 'dart:convert';
import '/config/storage_keys.dart';
import '/config/app.dart';
import '/bootstrap/decoders.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* ApiService
| -------------------------------------------------------------------------
| Define your API endpoints
| Learn more https://nylo.dev/docs/7.x/networking
|-------------------------------------------------------------------------- */

class ApiService extends NyApiService {
  ApiService()
      : super(
          decoders: modelDecoders,
          useNetworkLogger: true,
          // baseOptions: (BaseOptions baseOptions) {
          //   return baseOptions
          //             ..connectTimeout = Duration(seconds: 5)
          //             ..sendTimeout = Duration(seconds: 5)
          //             ..receiveTimeout = Duration(seconds: 5);
          // },
        );

  @override
  String get baseUrl => getEnv('API_BASE_URL');

  @override
  Map<Type, Interceptor> get interceptors => {
    ...super.interceptors,
    // MyCustomInterceptor: MyCustomInterceptor(),
  };

  /// Authenticate a user and receive token
  Future<dynamic> loginUser({required String email, required String password}) async {
    return await network(
      request: (request) => request.post("/auth/login", data: {
        "email": email,
        "password": password,
      }),
    );
  }

  /// Register a new user profile
  Future<dynamic> registerUser({required String email, required String password, String? name}) async {
    return await network(
      request: (request) => request.post("/auth/register", data: {
        "email": email,
        "password": password,
        "name": name,
      }),
    );
  }

  /// Get current logged in user profile details
  Future<dynamic> fetchCurrentUser({String? bearerToken}) async {
    return await network(
      request: (request) => request.get("/users/me", options: Options(headers: {
        if (bearerToken != null) "Authorization": "Bearer $bearerToken"
      })),
    );
  }

  /// Set server onboarding flag complete
  Future<dynamic> updateOnboardingStatus({required bool complete}) async {
    return await network(
      request: (request) => request.patch("/users/onboarding", data: {
        "onboardingComplete": complete
      }),
    );
  }

  /// Refresh an expired access token using durable refresh token
  Future<dynamic> refreshSessionToken({required String refreshToken}) async {
    return await network(
      request: (request) => request.post("/auth/refresh", data: {
        "refreshToken": refreshToken
      }),
    );
  }

  /// Invalidates session on server and discards active tokens
  Future<dynamic> logoutUser() async {
    return await network(
      request: (request) => request.post("/auth/logout"),
    );
  }

  /// Get current logged in JWT user object (Debug Profile)
  Future<dynamic> fetchTestingProfile() async {
    return await network(
      request: (request) => request.get("/auth/profile"),
    );
  }

/* Helpers
  |-------------------------------------------------------------------------- */

  /* Authentication Headers
  |--------------------------------------------------------------------------
  | Set your auth headers
  | Authenticate your API requests using a bearer token or any other method
  |-------------------------------------------------------------------------- */

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    String? myAuthToken = await StorageKeysConfig.bearerToken.read();
    if (myAuthToken != null) {
      headers.addBearerToken(myAuthToken);
    }
    return headers;
  }

  /* Should Refresh Token
  |--------------------------------------------------------------------------
  | Check if your Token should be refreshed
  | Set `false` if your API does not require a token refresh
  |-------------------------------------------------------------------------- */

  @override
  Future<bool> shouldRefreshToken() async {
    // Verify we possess a resident refresh token to attempt restoration
    String? refresh = await StorageKeysConfig.refreshToken.read();
    return refresh != null && refresh.isNotEmpty;
  }

  @override
  refreshToken(Dio dio) async {
    String? rToken = await StorageKeysConfig.refreshToken.read();
    if (rToken == null) return;

    try {
      // Request fresh lease using localized refresh carrier with absolute base URI
      final Response response = await dio.post("${AppConfig.apiBaseUrl}/auth/refresh", data: {
        "refreshToken": rToken
      });

      if (response.statusCode != null && (response.statusCode! >= 200 && response.statusCode! < 300)) {
        final dynamic data = response.data;
        if (data != null && data['access_token'] != null) {
          // Persist fresh short-term execution lock
          await StorageKeysConfig.bearerToken.save(data['access_token']);
          
          // Commit fresh long-term refresh vector if server rotated
          if (data['refresh_token'] != null) {
            await StorageKeysConfig.refreshToken.save(data['refresh_token']);
          }
          
          // 3. Atomically refresh transient internal user descriptor cache for immediate synchronous interceptor reuse
          dynamic existingAuth = Auth.data();
          
          // ELASTIC RECOVERY: In case it is string-encoded in memory
          if (existingAuth is String && existingAuth.trim().startsWith("{")) {
             try { existingAuth = jsonDecode(existingAuth); } catch(e) {}
          }

          if (existingAuth != null && existingAuth is Map) {
            final Map<String, dynamic> updatedAuth = Map<String, dynamic>.from(existingAuth);
            updatedAuth['access_token'] = data['access_token'];
            // Re-synchronize the refreshed token into framework-managed memory
            await Auth.authenticate(data: updatedAuth);
          }

          NyLogger.debug("Silent Auth Recovery Complete: Token pair synchronized!");
        }
      }
    } catch (e) {
      NyLogger.error("Autonomous token cycle failed. Purging credentials: $e");
      // Clear compromised or rejected chain
      await StorageKeysConfig.bearerToken.save(null);
      await StorageKeysConfig.refreshToken.save(null);
    }
  }
}
