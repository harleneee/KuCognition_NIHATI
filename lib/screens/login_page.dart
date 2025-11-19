import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    // In a real app, you would check credentials here.
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      // TODO: Connect to backend later
      print('Attempting login for user: $username');
      Navigator.pushNamed(context, '/scan');
    } else {
      // Simple feedback for demonstration
      print('Please enter both username and password.');
      // In a real app, show a Snackbar or error message.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToSignup() {
    // TODO: Go to signup screen
    print('Navigating to sign up page...');
    Navigator.pushNamed(context, '/signup'); // Assumes '/signup' route exists
  }

  void _goToForgotPassword() {
    // TODO: Go to forgot password screen
    print('Navigating to forgot password page...');
    // Navigator.pushNamed(context, '/forgot-password');
  }

  // Helper method to build the custom-styled text fields
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
  }) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFFF1F4FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadows: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            color: Color(0xFF494949),
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Color(0xFF616161),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none, // Remove default border
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ),
    );
  }

  // Helper method to build the custom-styled buttons using InkWell for tap functionality
  Widget _buildCustomButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color shadowColor,
    required VoidCallback onPressed,
    double fontSize = 20,
    bool isOutline = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isOutline
                ? const BorderSide(width: 2, color: Color(0xFF494949))
                : BorderSide.none,
          ),
          shadows: shadowColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: Center(
        child: SingleChildScrollView(
          // Use symmetric padding for horizontal constraints
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 60.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo/Icon (Simulating the 64x54 image placeholder)
              const Icon(
                Icons.monitor_heart, // Placeholder icon
                size: 64,
                color: Color(0xFF1F41BB),
              ),
              const SizedBox(
                height: 56,
              ), // Adjusted spacing based on design flow
              // 'Login here' text
              const Text(
                'Login here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1F41BB),
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              // 'Welcome back...' text
              const Text(
                'Welcome back you’ve\nbeen missed!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              // Email Input (Replicates the styled container/text input)
              _buildCustomTextField(
                controller: _usernameController,
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 29),

              // Password Input (Replicates the styled container/text input)
              _buildCustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 10),

              // Forgot Password TextButton
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToForgotPassword,
                  child: const Text(
                    'Forgot your password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1F41BB),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Sign In Button
              _buildCustomButton(
                text: 'Sign in',
                backgroundColor: const Color(0xFF3B87D2),
                textColor: Colors.white,
                shadowColor: const Color(0xFFCAD6FF),
                onPressed: _login,
              ),
              const SizedBox(height: 20),

              // Create New Account Button
              _buildCustomButton(
                text: 'Create new account',
                backgroundColor: Colors.white,
                textColor: const Color(0xFF494949),
                shadowColor: Colors.transparent,
                onPressed: _goToSignup,
                fontSize: 14,
                isOutline: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
