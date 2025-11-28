import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isAboutSelected = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          userData = {};
          isLoading = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snap.exists) {
        final data = snap.data()!;
        setState(() {
          userData = {
            "fullName": data["fullName"] ?? "No name",
            "email": data["email"] ?? user.email ?? "",
            "sex": data["sex"] ?? "Not set",
            "birthday": data["birthday"] ?? "Not set",
            "profileImageUrl": data["profileImageUrl"] ?? "",
            "totalScans": data["totalScans"] ?? 0,
            "mostCommonResult": data["mostCommonResult"] ?? "None yet",
            "lastScan": data["lastScan"] ?? "No scans yet",
          };
          isLoading = false;
        });
      } else {
        setState(() {
          userData = {
            "fullName": user.email ?? "User",
            "email": user.email ?? "",
            "sex": "Not set",
            "birthday": "Not set",
            "profileImageUrl": "",
            "totalScans": 0,
            "mostCommonResult": "None yet",
            "lastScan": "No scans yet",
          };
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userData = {};
        isLoading = false;
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAF5FD),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = userData ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _aboutHistoryTabs(),

            const SizedBox(height: 24),

            if (isAboutSelected) ...[
              _profileHeaderCard(data),

              const SizedBox(height: 18),

              _editProfileButton(),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _topCard(
                      "Total Scans",
                      (data["totalScans"] ?? 0).toString(),
                      height: 120,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _topCard(
                      "Most Common Result",
                      data["mostCommonResult"] ?? "None yet",
                      height: 120,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _topCard(
                "Last Scan",
                data["lastScan"] ?? "No scans yet",
                height: 110,
                isFullWidth: true,
              ),

              const SizedBox(height: 40),

              _logoutButton(),
            ] else ...[
              // This else block won't really be hit anymore once we always
              // navigate to /history, but it's safe to leave it for now.
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Scan History",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF001372),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "No scans yet.\nYour past nail scans will appear here.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6D777F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _aboutHistoryTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => isAboutSelected = true),
            child: _tabChip("ABOUT", isActive: isAboutSelected),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            // 🔹 Instead of toggling the state, go to the dedicated HistoryPage
            onTap: () {
              Navigator.pushNamed(context, '/history');
            },
            child: _tabChip("HISTORY", isActive: !isAboutSelected),
          ),
        ],
      ),
    );
  }

  Widget _tabChip(String text, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B87D2) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: isActive ? Colors.white : const Color(0xFF6D777F),
        ),
      ),
    );
  }

  Widget _profileHeaderCard(Map<String, dynamic> data) {
    final String fullName = data["fullName"] ?? "No name";
    final String email = data["email"] ?? "";
    final String sex = data["sex"] ?? "Not set";
    final String birthday = data["birthday"] ?? "Not set";
    final String profileImageUrl = data["profileImageUrl"] ?? "";

    Widget avatarChild;
    if (profileImageUrl.isNotEmpty) {
      avatarChild = CircleAvatar(
        radius: 46,
        backgroundImage: NetworkImage(profileImageUrl),
      );
    } else {
      avatarChild = const CircleAvatar(
        radius: 46,
        backgroundColor: Color(0xFFEAF5FD),
        child: Icon(
          Icons.person,
          size: 40,
          color: Color(0xFF6D777F),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(26, 28, 22, 28),
      constraints: const BoxConstraints(minHeight: 190),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: avatarChild,
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF001372),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF79838B),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Sex:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001372),
                  ),
                ),
                Text(
                  sex,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6D777F),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Date of Birth:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001372),
                  ),
                ),
                Text(
                  birthday,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6D777F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editProfileButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B87D2),
        minimumSize: const Size(double.infinity, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      onPressed: () {
        // TODO: Add edit profile screen later
      },
      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
      label: const Text(
        "Edit Profile",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return FractionallySizedBox(
      widthFactor: 0.5,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 238, 142, 142),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 3,
        ),
        onPressed: _logout,
        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        label: const Text(
          "Log Out",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _topCard(
    String title,
    String value, {
    double height = 120,
    bool isFullWidth = false,
  }) {
    return Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6D777F),
              ),
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9EACB7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
