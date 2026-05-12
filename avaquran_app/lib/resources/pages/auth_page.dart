import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/pages/feed_page.dart';
import '/resources/pages/onboarding_page.dart';
import '/resources/pages/quran_auth_page.dart';
import '/app/networking/api_service.dart';
import '/config/storage_keys.dart';

class AuthPage extends NyStatefulWidget {
  static RouteView path = ("/auth", (_) => AuthPage());
  AuthPage({super.key}) : super(child: () => _AuthPageState());
}

class _AuthPageState extends NyPage<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoginMode = true; // Toggles UI between login and signup
  bool _isLoading = false;

  @override
  get init => () {};

  @override
  bool get stateManaged => false;

  void _toggleAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  Future<void> _handleAuthSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showToastDanger(description: "Please enter all credentials.");
      return;
    }
    
    if (!_isLoginMode && name.isEmpty) {
      showToastDanger(description: "Please enter your name.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      dynamic response;
      if (_isLoginMode) {
        response = await ApiService().loginUser(email: email, password: password);
      } else {
        response = await ApiService().registerUser(email: email, password: password, name: name);
      }

      // Verify successful load of token from JSON
      if (response != null && response['access_token'] != null) {
        // 1. Save the tokens for future auto-attaching and manual rotation
        await StorageKeysConfig.bearerToken.save(response['access_token']);
        
        if (response['refresh_token'] != null) {
          await StorageKeysConfig.refreshToken.save(response['refresh_token']);
        }
        
        // 2. Immediately request full canonical profile to prime local cache state (name, email, etc.)
        dynamic fullUser;
        try {
           // Proactively pass the newly received token to instantly Prime the local profile cache safely
           fullUser = await ApiService().fetchCurrentUser(bearerToken: response['access_token']);
        } catch (e) {
           NyLogger.error("Initial verification profile prime failed: $e");
        }

        // Preserve execution token inside in-memory mapped user representation
        final Map<String, dynamic> finalUserMap = Map<String, dynamic>.from(fullUser ?? response['user'] ?? {});
        finalUserMap['access_token'] = response['access_token'];
        // Commit the user data into framework-managed Auth ecosystem (this updates Auth.data() instantly)
        await Auth.authenticate(data: finalUserMap);
        
        // 3. PER USER DIRECTIVE: Upon logging in, we bypass ALL onboarding checks and drive directly into the Feed
        showToastSuccess(description: _isLoginMode ? "Logged in successfully!" : "Account created!");
        
        // Strict redirection protocol: User is logged in -> go to Feed
        routeTo(FeedPage.path, navigationType: NavigationType.pushAndRemoveUntil, removeUntilPredicate: (route) => false);
      } else {
        showToastWarning(description: "Could not process login. Try again.");
      }
    } catch (e) {
      // Specific network exceptions caught by Nylo network() bubble here
      showToastDanger(description: "Connection failed. Check credentials.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BEAUTIFUL FULL SCREEN BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/auth_background.png",
              fit: BoxFit.cover,
            ),
          ),

          // 2. RICH DYNAMIC OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.3, 0.6, 1.0],
                  colors: [
                    Colors.black.withAlpha(100),
                    Colors.transparent,
                    const Color(0xFF03141C).withAlpha(200),
                    const Color(0xFF03141C),
                  ],
                ),
              ),
            ),
          ),

          // 3. SCROLLABLE AUTH FORM
          SafeArea(
            child: Column(
              children: [
                // Static top row (optional: logo or back)
                

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // LOGO / BRANDING HEADLINE
                          const Text(
                            "Ava Qurania",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isLoginMode 
                              ? "Welcome back! Please sign in to continue." 
                              : "Join our community today.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),

                          const SizedBox(height: 60),

                          // ANIMATED AUTH SWITCHER FOR FIELDS
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Column(
                              children: [
                                // FULL NAME (ONLY FOR SIGNUP)
                                if (!_isLoginMode) ...[
                                  _buildModernTextField(
                                    controller: _nameController,
                                    hintText: "Full Name",
                                    icon: Icons.person_outline,
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // EMAIL
                                _buildModernTextField(
                                  controller: _emailController,
                                  hintText: "Email Address",
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),

                                // PASSWORD
                                _buildModernTextField(
                                  controller: _passwordController,
                                  hintText: "Password",
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                ),
                              ],
                            ),
                          ),

                          // FORGOT PASSWORD (ONLY FOR LOGIN)
                          if (_isLoginMode)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Color(0xFF2CA5C4),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 24),

                          const SizedBox(height: 20),

                          // MAIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF267B92).withAlpha(70),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleAuthSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF267B92),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Text(
                                          _isLoginMode ? "Login" : "Sign Up",
                                          key: ValueKey(_isLoginMode),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // OR SEPARATOR
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white.withAlpha(40))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("OR", style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                              ),
                              Expanded(child: Divider(color: Colors.white.withAlpha(40))),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // QURAN FOUNDATION DYNAMIC LOGIN
                          SizedBox(
                            height: 54,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : () => routeTo(QuranAuthPage.path),
                              icon: const Icon(Icons.account_balance_wallet_outlined, size: 20, color: Colors.white),
                              label: const Text("Sign In with Quran.Foundation", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withAlpha(50), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.white.withAlpha(15),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // BOTTOM ALTERNATIVE ACTION ROW
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoginMode 
                                  ? "Don't have an account? " 
                                  : "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.white.withAlpha(160),
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: _toggleAuthMode,
                                child: Text(
                                  _isLoginMode ? "Sign Up" : "Login",
                                  style: const TextStyle(
                                    color: Color(0xFF2CA5C4),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MODULAR METHOD TO BUILD LUXURY TRANSLUCENT TEXT FIELD
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(30),
          width: 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF2CA5C4),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white60, size: 22),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withAlpha(90),
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white60,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
