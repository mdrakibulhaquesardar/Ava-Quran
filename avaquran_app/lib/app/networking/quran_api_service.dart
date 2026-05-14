import 'package:nylo_framework/nylo_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* QuranApiService
| -------------------------------------------------------------------------
| Quran Foundation User Related APIs
| Documentation: https://api-docs.quran.foundation
|-------------------------------------------------------------------------- */

class QuranApiService extends NyApiService {
  QuranApiService() : super(useNetworkLogger: true);

  @override
  String get baseUrl => "https://api.quran.com/api/v4";

  @override
  Map<Type, Interceptor> get interceptors => {
    _QuranAuthInterceptor: _QuranAuthInterceptor(),
  };

  /// Fetch total streak history
  /// https://api-docs.quran.foundation/docs/user_related_apis_versioned/get-streaks/
  Future<dynamic> fetchStreaks() async {
    final response = await network(
      request: (request) => request.get("https://apis.quran.foundation/v1/streaks"),
    );
    NyLogger.debug("fetchStreaks Response: $response");
    return response;
  }

  /// Fetch current active streak days
  /// https://api-docs.quran.foundation/docs/user_related_apis_versioned/get-current-streak-days/
  Future<dynamic> fetchCurrentStreakDays() async {
    final response = await network(
      request: (request) => request.get("https://apis.quran.foundation/v1/streaks/current-streak-days"),
    );
    NyLogger.debug("fetchCurrentStreakDays Response: $response");
    return response;
  }

  /// Log activity to update streaks, goals and calendar
  /// https://api-docs.quran.foundation/docs/user_related_apis_versioned/log-activity-day/
  Future<dynamic> logActivity({
    required String date, // ISO YYYY-MM-DD
    required int seconds,
    List<String>? ranges, // e.g. ["1:1-1:2"]
  }) async {
    final response = await network(
      request: (request) => request.post("https://apis.quran.foundation/v1/activity-days", data: {
        "type": "QURAN",
        "date": date,
        "mushafId": 4, // Default to UthmaniHafs
        if (ranges != null) "ranges": ranges,
        "seconds": seconds,
      }),
    );
    NyLogger.debug("logActivity Response: $response");
    return response;
  }

  /// Fetch list of available Tafsir resources
  /// https://api-docs.quran.foundation/docs/tafsirs/get-all-tafsirs/
  Future<dynamic> fetchTafsirResources({String? language}) async {
    final response = await network(
      request: (request) => request.get("/resources/tafsirs", queryParameters: {
        if (language != null) "language": language,
      }),
    );
    NyLogger.debug("fetchTafsirResources Response: $response");
    return response;
  }

  /// Fetch Tafsir for a specific Surah (Chapter)
  /// https://api-docs.quran.foundation/docs/tafsirs/get-tafsir-by-chapter/
  Future<dynamic> fetchTafsirByChapter({
    required int resourceId,
    required int chapterNumber,
  }) async {
    final response = await network(
      request: (request) => request.get("/tafsirs/$resourceId/by_chapter/$chapterNumber", queryParameters: {
        "per_page": 300,
      }),
    );
    NyLogger.debug("fetchTafsirByChapter Response: $response");
    return response;
  }

  /// Fetch word-by-word morphological analysis for a verse
  /// https://api-docs.quran.foundation/docs/word_morphology/get-word-morphology/
  Future<dynamic> fetchWordMorphology({
    required String ayahKey,
  }) async {
    final response = await network(
      request: (request) => request.get("/verses/by_key/$ayahKey", queryParameters: {
        "words": "true",
        "word_fields": "text_uthmani,text_simple,root,lemma,grammatical_features",
      }),
    );
    NyLogger.debug("fetchWordMorphology Response: $response");
    return response;
  }
}

class _QuranAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('SK_BEARER_TOKEN');
    String? clientId = getEnv('QURAN_CLIENT_ID');

    // Skip x-auth-token for public content resources to avoid 403 or 400 errors
    bool isPublicResource = options.path.contains("resources") || 
                           options.path.contains("tafsirs") ||
                           options.path.contains("verses");

    if (token != null && token.isNotEmpty && !isPublicResource) {
      options.headers["x-auth-token"] = token;
    }
    
    if (clientId != null && clientId.isNotEmpty) {
      options.headers["x-client-id"] = clientId;
    }

    NyLogger.debug("[QuranInterceptor] Path: ${options.path}, Headers: ${options.headers.keys.join(', ')}");
    return handler.next(options);
  }
}
