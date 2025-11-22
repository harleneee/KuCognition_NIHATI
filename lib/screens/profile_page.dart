import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfilePage(),
  ));
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final bool useMockData = true;

  final Map<String, dynamic> mockUserData = {
    "username": "Emily Nelson",
    "email": "emily.n@hotmail.com",
    "sex": "Female",
    "birthday": "December 07, 2001",
    "profileImageUrl": "https://picsum.photos/395/588",
    "totalScans": 3,
    "mostCommonResult": "Healthy Nails",
    "lastScan": "No scans yet",
  };

  bool isAboutSelected = true;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        useMockData ? mockUserData : <String, dynamic>{};

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
                      data["totalScans"].toString(),
                      height: 120,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _topCard(
                      "Most Common Result",
                      data["mostCommonResult"],
                      height: 120,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _topCard(
                "Last Scan",
                data["lastScan"],
                height: 110,
                isFullWidth: true,
              ),

              const SizedBox(height: 40),

              _logoutButton(),
            ] else ...[
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

  // ABOUT / HISTORY TABS
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
            onTap: () => setState(() => isAboutSelected = false),
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

  // PROFILE CARD — with highlighted labels
  Widget _profileHeaderCard(Map<String, dynamic> data) {
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
            child: CircleAvatar(
              radius: 46,
              backgroundImage: NetworkImage(data["profileImageUrl"]),
            ),
          ),
          const SizedBox(width: 26),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["username"],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF001372),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data["email"],
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
                  data["sex"],
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
                  data["birthday"],
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

  // EDIT PROFILE BUTTON (text back to white)
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
      onPressed: () {},
      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
      label: const Text(
        "Edit Profile",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white, // <- back to white
        ),
      ),
    );
  }

  // LOGOUT BUTTON — narrower + smaller
  Widget _logoutButton() {
    return FractionallySizedBox(
      widthFactor: 0.5, // 60% of available width
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 238, 142, 142),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 3,
        ),
        onPressed: () {
          // TODO: Add logout logic
        },
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

  // STAT CARDS – with FittedBox to avoid overflow
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
