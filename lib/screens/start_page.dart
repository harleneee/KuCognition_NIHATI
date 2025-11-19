import 'package:flutter/material.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: height * 0.05),

            /// LOGO / IMAGE
            Center(
              child: Container(
                width: width * 0.35,
                height: width * 0.30,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/200x200"),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.04),

            /// TITLE
            Text(
              "Welcome to KuCognition",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF001372),
                fontSize: width * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 10,
              ),
              child: Text(
                "Your Smart Nail Health Companion",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF3B87D2),
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Spacer(),

            /// --- LOGIN BUTTON ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B87D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),

            SizedBox(height: 15),

            /// --- SIGN UP BUTTON ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF3B87D2), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 20, color: Color(0xFF3B87D2)),
                  ),
                ),
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
