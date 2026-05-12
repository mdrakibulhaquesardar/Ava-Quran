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
              dynamic profile = await ApiService().fetchCurrentUser();
              if (profile != null) {
                // Save full fresh user config to local storage
                await StorageKeysConfig.auth.save(profile);
                
                // Persist canonical onboarding flag
                bool complete = profile['onboardingComplete'] ?? false;
                await StorageKeysConfig.onboardingComplete.save(complete);
              }
            } catch (e) {
              NyLogger.error("Boot state sync failed: $e");
            }
          }
          
          // 2. COMPUTE DYNAMIC INITIAL ROUTE FOR ENTRY
          String? startRoute;
          if (activeToken != null && activeToken.isNotEmpty) {
             bool hasOnboarded = (await StorageKeysConfig.onboardingComplete.read()) == true;
             // If user is logged in but hasn't onboarded, guide to Onboarding, else go directly to Feed
             startRoute = hasOnboarded ? FeedPage.path.$1 : OnboardingPage.path.$1;
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
