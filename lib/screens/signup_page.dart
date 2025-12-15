import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmVisible = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _goToExtraPage() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showError("Please fill all fields.");
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      showError("Enter a valid email.");
      return;
    }

    if (password.length < 6) {
      showError("Password must be at least 6 characters.");
      return;
    }

    if (password != confirmPassword) {
      showError("Passwords do not match.");
      return;
    }

    Navigator.pushNamed(
      context,
      "/signup_extra",
      arguments: {
        "fullName": fullName,
        "email": email,
        "password": password,
      },
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
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
            decoration: BoxDecoration(
              color: Colors.white,
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),
                  Image.asset("assets/images/logo.png", width: 65),
                  const SizedBox(height: 15),
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 28,
                      color: Color(0xFF1F41BB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Step 1 of 2 • Create your account",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "You'll add your profile details on the next step.",
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 22),

                  _roundedField(
                    controller: fullNameController,
                    hint: "Full Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 18),

                  _roundedField(
                    controller: emailController,
                    hint: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 18),

                  _roundedField(
                    controller: passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    obscure: !_passwordVisible,
                    suffix: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  _roundedField(
                    controller: confirmPasswordController,
                    hint: "Confirm Password",
                    icon: Icons.lock_outline,
                    obscure: !_confirmVisible,
                    suffix: IconButton(
                      icon: Icon(
                        _confirmVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _confirmVisible = !_confirmVisible;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

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
                      onPressed: _goToExtraPage,
                      child: const Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, "/login"),
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        color: Color(0xFF1F41BB),
                        fontWeight: FontWeight.bold,
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
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF5FD),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF3B87D2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
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
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();

    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller1, _controller2]),
      builder: (_, __) {
        final rate1 = 0.85 + (_controller1.value * 0.25);

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: rate1,
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
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }
}