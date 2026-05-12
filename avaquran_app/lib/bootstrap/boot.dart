import 'package:flutter/material.dart';
import '/config/app.dart';
import '/resources/widgets/splash_screen.dart';
import '../resources/widgets/main_widget.dart';
import '/bootstrap/providers.dart';
import 'package:nylo_framework/nylo_framework.dart';
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
          String? activeToken = await StorageKeysConfig.bearerToken.read();
          if (activeToken != null && activeToken.isNotEmpty) {
            try {
              // Explicitly pass activeToken to overcome intermittent race conditions during initial boot interception sync
              dynamic profile = await ApiService().fetchCurrentUser(bearerToken: activeToken);
              if (profile != null) {
                // Inject current bearer into synchronized record for consistent interceptor access
                final Map<String, dynamic> userMap = Map<String, dynamic>.from(profile);
                userMap['access_token'] = activeToken;
                
                // Fully synchronize the newly verified cache with Nylo's dynamic Auth layer
                await Auth.authenticate(data: userMap);
                // NOTE: We no longer sync onboardingComplete from server as it is strictly local-only per requirements
              }
            } catch (e) {
              NyLogger.error("Boot state sync failed: $e");
            }
          }
          
          // 2. COMPUTE DYNAMIC INITIAL ROUTE FOR ENTRY
          String? startRoute;
          if (activeToken != null && activeToken.isNotEmpty) {
             // PER USER DIRECTIVE: If user is logged in, bypass ALL checks and send directly to the Feed
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
