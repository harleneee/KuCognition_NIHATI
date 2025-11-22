import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final birthdayController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final birthday = birthdayController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        birthday.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      showError("Please fill out all fields.");
      return;
    }

    setState(() => isLoading = true);

    try {
      // CREATE USER AUTH
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // SAVE USER IN FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
            "username": username,
            "email": email,
            "birthday": birthday,
            "phone": phone,
            "createdAt": DateTime.now().toIso8601String(),
          });

      // SUCCESS POPUP
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Account Created!"),
          content: const Text(
            "Your profile has been successfully created.\nYou may now log in.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Signup failed.");
    } catch (e) {
      showError("Unexpected error: $e");
    }

    setState(() => isLoading = false);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text(
              "Sign Up",
              style: TextStyle(
                color: Color(0xFF1F41BB),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Create an account to continue",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 25),

            // FORM INPUTS
            _inputField("Username", usernameController),
            const SizedBox(height: 15),

            _inputField("Email", emailController),
            const SizedBox(height: 15),

            _inputField("Birthday (e.g. Jan 1, 2000)", birthdayController),
            const SizedBox(height: 15),

            _inputField(
              "Phone Number",
              phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            _inputField("Password", passwordController, obscure: true),
            const SizedBox(height: 30),

            // REGISTER BUTTON
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B87D2),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: registerUser,
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

            const SizedBox(height: 20),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, "/login");
                },
                child: const Text(
                  "Already have an account? Login",
                  style: TextStyle(
                    color: Color(0xFF1F41BB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4,
                color: Colors.black12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
