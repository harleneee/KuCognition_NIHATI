import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ⛔️ If the file is actually named `dashboard_screen.dart`, palitan mo 'dashboard_page.dart'
import 'dashboard_page.dart'; // or 'dashboard_screen.dart' – depende sa file name mo

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;
  bool loading = false;

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter email and password.");
      return;
    }

    setState(() => loading = true);

    try {
      // sign in and get user
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      final displayName = user?.displayName;

      if (!mounted) return;

      // go to dashboard WITH username from Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(username: displayName),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Login failed.");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: const BreathingGradient(),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F9FF),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 25,
                    spreadRadius: 8,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset("assets/images/logo.png", width: 65),
                    const SizedBox(height: 12),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F41BB),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Sign in to continue checking your\nnail health with KuCognition.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 35),

                    // EMAIL
                    _roundedField(
                      controller: emailController,
                      hint: "Email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 18),

                    // PASSWORD
                    _roundedField(
                      controller: passwordController,
                      hint: "Password",
                      obscure: obscure,
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B87D2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: loading ? null : loginUser,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/signup"),
                      child: const Text(
                        "Create new account",
                        style: TextStyle(
                          color: Color(0xFF1F41BB),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: const Color(0xFFD6E8FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),

          // 🔧 FIX: use the `icon` parameter, not always email
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEAF5FD),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF3B87D2),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle:
                    const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
          ),
          if (suffix != null) suffix,
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class BreathingGradient extends StatefulWidget {
  const BreathingGradient({super.key});
  @override
  State<BreathingGradient> createState() => _BreathingGradientState();
}

class _BreathingGradientState extends State<BreathingGradient>
    with TickerProviderStateMixin {
  late AnimationController _c1;
  late AnimationController _c2;

  @override
  void initState() {
    super.initState();

    _c1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _c2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2]),
      builder: (_, __) {
        final r1 = 0.90 + (_c1.value * 0.35);

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: r1,
              colors: const [
                Color(0xFF3B87D2),
                Color(0xFFEAF5FD),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }
}