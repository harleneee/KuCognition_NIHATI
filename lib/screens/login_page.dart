import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacementNamed(context, "/dashboard");
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Login failed.");
    }

    setState(() => loading = false);
  }

  void showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.monitor_heart, size: 64, color: Color(0xFF1F41BB)),

            const SizedBox(height: 40),

            const Text(
              "Login",
              style: TextStyle(
                fontSize: 30,
                color: Color(0xFF1F41BB),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _input("Email", emailController),
            const SizedBox(height: 20),

            _input("Password", passwordController, obscure: true),
            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B87D2),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: loginUser,
                    child: const Text("Sign In"),
                  ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/signup");
              },
              child: const Text("Create new account"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
