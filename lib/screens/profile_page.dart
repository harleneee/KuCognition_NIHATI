import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("No logged-in user found.");
    }

    return FirebaseFirestore.instance.collection("users").doc(user.uid).get();
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B87D2),
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),

      // BODY
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF3B87D2)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Unable to load profile data.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final userData = snapshot.data!.data()!;
          final username = userData["username"] ?? "Unknown";
          final email = userData["email"] ?? "Unknown";
          final birthday = userData["birthday"] ?? "Unknown";
          final phone = userData["phone"] ?? "Unknown";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // PROFILE ICON
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF3B87D2),
                  child: Icon(Icons.person, color: Colors.white, size: 60),
                ),
                const SizedBox(height: 20),

                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001372),
                  ),
                ),
                const SizedBox(height: 30),

                // INFO CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _infoTile(Icons.email, "Email", email),
                      const Divider(),
                      _infoTile(Icons.cake, "Birthday", birthday),
                      const Divider(),
                      _infoTile(Icons.phone, "Phone Number", phone),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // LOGOUT BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB62828),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _logout(context),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Reusable info row widget
  Widget _infoTile(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF3B87D2), size: 26),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
