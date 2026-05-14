import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '/config/app.dart';
import '/config/storage_keys.dart';
import '/resources/pages/feed_page.dart';
import '/resources/pages/onboarding_page.dart';
import '/app/networking/api_service.dart';

class QuranAuthPage extends NyStatefulWidget {
  final bool isLinking;
  static RouteView path = ("/quran-auth", (context) => QuranAuthPage());

  QuranAuthPage({super.key, this.isLinking = false}) : super(child: () => _QuranAuthPageState());
}

class _QuranAuthPageState extends NyPage<QuranAuthPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isHandlingCallback = false;

  @override
  get init => () async {
    // Detect if we are in LINK mode or generic LOGIN mode
    final dynamic routeData = widget.data();
    final bool isLinking = widget.isLinking || (routeData != null && routeData['isLinking'] == true);

    final String apiEndpoint = isLinking ? "/auth/quran/link" : "/auth/quran/login";
    final String authUrl = "${AppConfig.apiBaseUrl}$apiEndpoint";
    
    Map<String, String> headers = {};
    
    // If explicitly linking an existing account, we MUST deliver current authorization vector
    if (isLinking) {
      String? currentToken = await StorageKeysConfig.bearerToken.read();
      if (currentToken != null) {
         headers["Authorization"] = "Bearer $currentToken";
      }
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkForCallback(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkForCallback(url);
          },
          onWebResourceError: (WebResourceError error) {
             NyLogger.error("WebView Error: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains("/auth/quran/callback")) {
              _handleDirectCallbackFetch(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Execute loading sequence utilizing injected headers
    await _controller.loadRequest(Uri.parse(authUrl), headers: headers);
  };

  /// Periodically intercepts URL to detect server callback
  Future<void> _checkForCallback(String url) async {
    if (_isHandlingCallback) return;

    // Detect if URL is finalized back into our backend domain callback
    if (url.contains("/auth/quran/callback")) {
      _isHandlingCallback = true;
      NyLogger.debug("[OAuth] Callback detected: $url");
      setState(() => _isLoading = true); // Show spinner while parsing final result
      
      try {
        // Wait brief moment to ensure browser loaded the JSON dump
        await Future.delayed(const Duration(milliseconds: 800));

        // Extract text from browser body (the JSON returned by backend)
        final Object result = await _controller.runJavaScriptReturningResult(
          "document.body.innerText || document.body.textContent"
        );

        // Flutter Webview sometimes includes escaped quotes around the string
        String rawString = result.toString();
        if (rawString.startsWith("\"") && rawString.endsWith("\"")) {
          // Unescape the double-wrapped string
          rawString = rawString.substring(1, rawString.length - 1).replaceAll("\\\"", "\"").replaceAll("\\\\", "\\");
        }

        // Check for typical JSON opening brace
        if (!rawString.trim().startsWith("{")) {
           // Try querying pre tag specifically if present
           final Object preResult = await _controller.runJavaScriptReturningResult(
             "document.querySelector('pre')?.innerText"
           );
           String preString = preResult.toString();
           if (preString.isNotEmpty && preString != "null") {
              if (preString.startsWith("\"") && preString.endsWith("\"")) {
                  preString = preString.substring(1, preString.length - 1).replaceAll("\\\"", "\"").replaceAll("\\\\", "\\");
              }
              if (preString.trim().startsWith("{")) {
                rawString = preString;
              }
           }
        }

        // Attempt real JSON parse
        final response = jsonDecode(rawString);

        if (response != null && response['access_token'] != null) {
          // 1. Commit durable tokens using direct SharedPreferences for maximum reliability
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('SK_BEARER_TOKEN', response['access_token']);
          if (response['refresh_token'] != null) {
             await prefs.setString('SK_REFRESH_TOKEN', response['refresh_token']);
          }
          
          NyLogger.debug("[OAuth] Token stored via SharedPreferences. Verifying...");
          String? check = prefs.getString('SK_BEARER_TOKEN');
          NyLogger.debug("[OAuth] SharedPreferences verification: ${check != null ? 'SUCCESS' : 'FAILED'}");

          // 2. Commit user meta and retrieve onboarding flag
          bool hasOnboarded = false;
          if (response['user'] != null) {
            final Map<String, dynamic> userMap = Map<String, dynamic>.from(response['user']);
            userMap['access_token'] = response['access_token'];
            
            // Unify local user profile data inside the global Nylo Auth lifecycle
            await Auth.authenticate(data: userMap);
            
            // 3. Uphold local device tracking directive: Check if we are already onboarded on device
            hasOnboarded = await StorageKeysConfig.onboardingComplete.read() == true;
            
            // Explicitly cache that we STILL preserve that state if necessary
            if (hasOnboarded) {
              await StorageKeysConfig.onboardingComplete.save(true);
            }
          }

          // Detect context once more for navigation fork
          final dynamic routeData = widget.data();
          final bool isLinking = routeData != null && routeData['isLinking'] == true;

          showToastSuccess(description: isLinking ? "Account linked successfully!" : "Securely connected with Quran.Foundation!");

          // 3. Handle Intelligent Navigation Exit
          if (isLinking) {
            // Simply pop back to previous context (e.g., Profile) delivering success payload
            Navigator.pop(context, true);
          } else {
            // PER USER DIRECTIVE: Hard reset directly into primary application grid
            routeTo(FeedPage.path, navigationType: NavigationType.pushAndForgetAll);
          }
        } else {
          throw Exception("Invalid server payload");
        }

      } catch (e) {
        NyLogger.error("OAuth Parse Failed: $e");
        showToastWarning(description: "Could not finalize link. Please try again.");
        Navigator.pop(context); // Take user back to login screen
      }
    }
  }

  /// Manually performs the callback exchange by calling our API direct instead of web page load
  Future<void> _handleDirectCallbackFetch(String url) async {
    if (_isHandlingCallback) return;
    _isHandlingCallback = true;
    
    // Brief delay ensures loading state propagates correctly across threads
    await Future.delayed(const Duration(milliseconds: 50));
    setState(() => _isLoading = true);

    try {
      NyLogger.debug("[OAuth] Hijacked URL for Native Fetch: $url");
      final Uri uri = Uri.parse(url);
      final String? code = uri.queryParameters['code'];
      final String? state = uri.queryParameters['state'];
      final String? error = uri.queryParameters['error'];

      NyLogger.debug("[OAuth] Parsed queryParams: code=$code, state=$state, error=$error");

      if (error != null) {
        throw Exception("Authorization Server Error: $error");
      }

      if (code == null) {
        // Check if URL is just a generic loader page or needs to be ignored
        if (!url.contains("?")) {
           NyLogger.debug("[OAuth] Intercepted non-parameterized callback path. Skipping automatic fetch.");
           _isHandlingCallback = false;
           setState(() => _isLoading = false);
           return;
        }
        throw Exception("No authorization code present in callback");
      }

      // For Linking, extract current bearer token to bind appropriately
      String? currentToken;
      final dynamic routeData = widget.data();
      final bool isLinking = widget.isLinking || (routeData != null && routeData['isLinking'] == true);
      
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      if (isLinking) {
        currentToken = prefs.getString('SK_BEARER_TOKEN');
      }

      // Execute standard network transaction bypassing web browser runtime
      final dynamic response = await ApiService().exchangeQuranCode(
        code: code,
        state: state,
        bearerToken: currentToken,
      );

      if (response != null && response['access_token'] != null) {
        // 1. Commit durable auth tokens via direct SharedPreferences
        await prefs.setString('SK_BEARER_TOKEN', response['access_token']);
        if (response['refresh_token'] != null) {
          await prefs.setString('SK_REFRESH_TOKEN', response['refresh_token']);
        }

        // 2. Persist global user ecosystem state
        if (response['user'] != null) {
          final Map<String, dynamic> userMap = Map<String, dynamic>.from(response['user']);
          userMap['access_token'] = response['access_token'];
          await Auth.authenticate(data: userMap);
          
          // Retain previous local device tracking states if they exist
          bool hasOnboarded = prefs.getBool('SK_ONBOARDING_COMPLETE') == true;
          if (hasOnboarded) {
            await prefs.setBool('SK_ONBOARDING_COMPLETE', true);
          }
        }

        showToastSuccess(description: isLinking ? "Account linked successfully!" : "Securely connected with Quran.Foundation!");

        // 3. Execute navigation lifecycle completions
        if (isLinking) {
          Navigator.pop(context, true);
        } else {
          routeTo(FeedPage.path, navigationType: NavigationType.pushAndForgetAll);
        }
      } else {
        throw Exception("Invalid response data format from server");
      }
    } catch (e) {
      NyLogger.error("OAuth Direct Manual Fetch Failed: $e");
      showToastWarning(description: "Could not complete link. Please try again.");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isThemeDark ? const Color(0xFF03141C) : Colors.white,
      appBar: AppBar(
        backgroundColor: context.isThemeDark ? const Color(0xFF03141C) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.isThemeDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          (widget.data() != null && widget.data()['isLinking'] == true) 
              ? "Connect Account" 
              : "Quran.Foundation Sign In",
          style: TextStyle(
            color: context.isThemeDark ? Colors.white : const Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _isLoading 
              ? const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF267B92)),
                )
              : const SizedBox(height: 2),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: context.isThemeDark ? const Color(0xFF03141C) : Colors.white,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF267B92)),
              ),
            ),
        ],
      ),
    );
  }
}
