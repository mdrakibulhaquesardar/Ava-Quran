import '/config/storage_keys.dart';
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
  Future<dynamic> fetchCurrentUser() async {
    return await network(
      request: (request) => request.get("/users/me"),
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

  // @override
  // Future<bool> shouldRefreshToken() async {
  //   return false;
  // }

  /* Refresh Token
  |--------------------------------------------------------------------------
  | If `shouldRefreshToken` returns true then this method
  | will be called to refresh your token. Save your new token to
  | local storage and then use the value in `setAuthHeaders`.
  |-------------------------------------------------------------------------- */

  // @override
  // refreshToken(Dio dio) async {
  //  dynamic response = (await dio.get("https://example.com/refresh-token")).data;
  //  // Save the new token
  //   await StorageKeysConfig.bearerToken.save(response['token']);
  // }
}
