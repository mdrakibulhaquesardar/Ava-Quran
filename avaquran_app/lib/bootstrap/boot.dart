import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/config/app.dart';
import '/resources/widgets/splash_screen.dart';
import '../resources/widgets/main_widget.dart';
import '/bootstrap/providers.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:dio/dio.dart';
import '/app/networking/api_service.dart';
import '/config/storage_keys.dart';
import '/resources/pages/feed_page.dart';
import '/resources/pages/onboarding_page.dart';

/* Boot
|--------------------------------------------------------------------------
| The boot class is used to initialize your application.
| Providers are booted in the order they are defined.
|-------------------------------------------------------------------------- */

class Boot {
  /// Returns a [BootConfig] containing the setup and boot functions.
  static BootConfig nylo() => BootConfig(
        setup: () async {
          if (AppConfig.showSplashScreen) {
            runApp(SplashScreen.app());
          }

          await _init();
          return await setupApplication(providers);
        },
        boot: (Nylo nylo) async {
          // SYNC LATEST USER STATE IF LOGGED IN
          // Use direct SharedPreferences read for maximum reliability across restarts
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          String? activeToken = prefs.getString('SK_BEARER_TOKEN');
          NyLogger.debug("[Boot] SharedPreferences Read: $activeToken");
          
          bool isSessionValid = false;

          if (activeToken != null && activeToken.isNotEmpty) {
            try {
              // Explicitly verify the token by fetching current user profile
              dynamic profile = await ApiService().fetchCurrentUser(bearerToken: activeToken);
              if (profile != null) {
                final Map<String, dynamic> userMap = Map<String, dynamic>.from(profile);
                userMap['access_token'] = activeToken;
                
                // Fully synchronize with Nylo Auth layer
                await Auth.authenticate(data: userMap);
                isSessionValid = true;
                NyLogger.debug("[Boot] Session Validated for user: ${userMap['email']}");
              } else {
                throw Exception("Invalid profile payload");
              }
            } catch (e) {
              NyLogger.error("Boot session verification failed: $e");
              
              bool isAuthError = false;
              if (e is DioException) {
                if (e.response?.statusCode == 401) {
                  isAuthError = true;
                }
              }

              if (isAuthError) {
                NyLogger.error("Auth rejection detected during boot. Purging compromised session.");
                await prefs.remove('SK_BEARER_TOKEN');
                await prefs.remove('SK_REFRESH_TOKEN');
                await Auth.logout();
              } else {
                // Network issue? Keep the token and let the app try to load the Feed anyway
                isSessionValid = true; 
              }
            }
          }
          
          // 2. COMPUTE DYNAMIC INITIAL ROUTE
          String? startRoute;
          if (isSessionValid) {
             startRoute = FeedPage.path.$1;
          }
          
          await bootFinished(nylo, providers);
 
          runApp(Main(nylo, overrideInitialRoute: startRoute));
        },
      );
}

/* Init
|--------------------------------------------------------------------------
| You can use _init to initialize classes, variables, etc.
| It's run before your app providers are booted.
|-------------------------------------------------------------------------- */

Future<void> _init() async {
  /// Example: Initializing StorageConfig
  // StorageConfig.init(
  //   androidOptions: AndroidOptions(
  //     resetOnError: true,
  //     encryptedSharedPreferences: false
  //   )
  // );
}
