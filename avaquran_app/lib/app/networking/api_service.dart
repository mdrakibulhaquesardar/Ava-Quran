import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
        );

  @override
  Map<Type, Interceptor> get interceptors => {
    _AuthInterceptor: _AuthInterceptor(),
  };

  @override
  String get baseUrl => getEnv('API_BASE_URL');

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

  /// Complete the Quran.Foundation OAuth authorization exchange
  Future<dynamic> exchangeQuranCode({required String code, String? state, String? bearerToken}) async {
    return await network(
      request: (request) => request.get("/auth/quran/callback", 
        queryParameters: {
          "code": code,
          if (state != null) "state": state,
        },
        options: Options(headers: {
          if (bearerToken != null) "Authorization": "Bearer $bearerToken"
        })
      ),
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

  /// Fetch paginated, personalized vertical feed
  Future<dynamic> fetchFeed({String mood = '', int page = 1, int limit = 10}) async {
    return await network(
      request: (request) => request.get("/feed", queryParameters: {
        "mood": mood,
        "page": page.toString(),
        "limit": limit.toString(),
      }),
    );
  }

  /// Log analytic signals from frontend (loved, saved, swiped, etc.)
  Future<dynamic> trackInteraction({required String ayahKey, required String interactionType}) async {
    return await network(
      request: (request) => request.post("/feed/interactions", data: {
        "ayahKey": ayahKey,
        "interactionType": interactionType,
      }),
    );
  }

  /// Fetch top reels sorted by love engagement DESC
  Future<dynamic> fetchMostLoved({int page = 1, int limit = 10, String lang = 'en'}) async {
    return await network(
      request: (request) => request.get("/feed/most-loved", queryParameters: {
        "page": page.toString(),
        "limit": limit.toString(),
        "lang": lang,
      }),
    );
  }

  /// Fetch a paginated list of creators to discover and follow
  Future<dynamic> fetchDiscoverUsers({int page = 1, int limit = 20}) async {
    return await network(
      request: (request) => request.get("/users/discover", queryParameters: {
        "page": page.toString(),
        "limit": limit.toString(),
      }),
    );
  }

  /// Follow a user by their ID
  Future<dynamic> followUser({required String targetUserId}) async {
    return await network(
      request: (request) => request.post("/users/follow/$targetUserId"),
    );
  }

  /// Unfollow a user by their ID
  Future<dynamic> unfollowUser({required String targetUserId}) async {
    return await network(
      request: (request) => request.delete("/users/follow/$targetUserId"),
    );
  }
  /// Fetch a paginated list of public community blogs
  Future<dynamic> fetchBlogs({int page = 1, int limit = 10}) async {
    return await network(
      request: (request) => request.get("/blogs", queryParameters: {
        "page": page.toString(),
        "limit": limit.toString(),
      }),
    );
  }

  /// Fetch a single blog article's full details by ID
  Future<dynamic> fetchBlogDetails({required String blogId}) async {
    return await network(
      request: (request) => request.get("/blogs/$blogId"),
    );
  }

  /// Create and publish a new blog entry
  Future<dynamic> createBlog({required String title, required String content}) async {
    return await network(
      request: (request) => request.post("/blogs", data: {
        "title": title,
        "content": content,
      }),
    );
  }

  /// Fetch list of user collections
  Future<dynamic> fetchCollections() async {
    return await network(
      request: (request) => request.get("/collections"),
    );
  }

  /// Create a new collection
  Future<dynamic> createCollection({required String title}) async {
    return await network(
      request: (request) => request.post("/collections", data: {
        "title": title,
      }),
    );
  }

  /// Add an Ayah to a collection
  Future<dynamic> addAyahToCollection({required String collectionId, required String ayahKey}) async {
    return await network(
      request: (request) => request.post("/collections/$collectionId/ayahs", data: {
        "ayahKey": ayahKey,
      }),
    );
  }

  /// Remove an Ayah from a collection
  Future<dynamic> removeAyahFromCollection({required String collectionId, required String ayahKey}) async {
    return await network(
      request: (request) => request.delete("/collections/$collectionId/ayahs/$ayahKey"),
    );
  }

  /// Fetch all Ayahs inside a collection
  Future<dynamic> fetchCollectionAyahs({required String collectionId}) async {
    return await network(
      request: (request) => request.get("/collections/$collectionId/ayahs"),
    );
  }
  
  /// Fetch user activity streak
  Future<dynamic> fetchMyStreak() async {
    return await network(
      request: (request) => request.get("/streaks/me"),
    );
  }
  
  /// Update/Increment daily streak activity
  Future<dynamic> updateStreak() async {
    return await network(
      request: (request) => request.post("/streaks/update"),
    );
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

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    NyLogger.debug("[Interceptor] Processing request: ${options.path}");
    
    // 1. Read token directly from native SharedPreferences for reliability
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('SK_BEARER_TOKEN');
    
    // 2. Inject Bearer token if present
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
      NyLogger.debug("[Interceptor] SUCCESS: Injected token for ${options.path}");
    } else {
      NyLogger.debug("[Interceptor] WARNING: No token found in SharedPreferences for ${options.path}");
    }

    return handler.next(options);
  }
}
