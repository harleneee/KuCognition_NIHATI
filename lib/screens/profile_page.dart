import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ✅ image picker + Supabase
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isAboutSelected = true;

  // ✅ state for avatar upload
  final ImagePicker _picker = ImagePicker();
  bool _uploadingAvatar = false;

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

      // 1) Basic user document
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String fullName = user.email ?? "User";
      String email = user.email ?? "";
      String sex = "Not set";
      String birthday = "Not set";
      String profileImageUrl = "";

      if (snap.exists) {
        final data = snap.data()!;
        fullName = data["fullName"] ?? fullName;
        email = data["email"] ?? email;
        sex = data["sex"] ?? "Not set";
        birthday = data["birthday"] ?? "Not set";
        profileImageUrl = data["profileImageUrl"] ?? "";
      }

      // 2) Stats from history collection
      final historySnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .get();

      int totalScans = historySnap.docs.length;
      String mostCommonResult = "None yet";
      String lastScan = "No scans yet";

      if (historySnap.docs.isNotEmpty) {
        final lastDoc =
            historySnap.docs.first.data() as Map<String, dynamic>? ?? {};
        final String lastLabel =
            (lastDoc['predictionLabel'] as String?) ?? 'Unknown condition';
        final tsRaw = lastDoc['timestamp'];
        String datePart = "";

        if (tsRaw is Timestamp) {
          final dt = tsRaw.toDate();
          datePart = DateFormat('MMMM d, yyyy').format(dt).toUpperCase();
        }

        lastScan = datePart.isNotEmpty ? "$lastLabel • $datePart" : lastLabel;

        final Map<String, int> counts = {};
        for (final d in historySnap.docs) {
          final m = d.data() as Map<String, dynamic>? ?? {};
          final label =
              (m['predictionLabel'] as String?) ?? 'Unknown condition';
          counts[label] = (counts[label] ?? 0) + 1;
        }

        String bestLabel = "None yet";
        int maxCount = 0;
        counts.forEach((label, count) {
          if (count > maxCount) {
            maxCount = count;
            bestLabel = label;
          }
        });

        if (maxCount > 0) {
          mostCommonResult = bestLabel;
        }
      }

      setState(() {
        userData = {
          "fullName": fullName,
          "email": email,
          "sex": sex,
          "birthday": birthday,
          "profileImageUrl": profileImageUrl,
          "totalScans": totalScans,
          "mostCommonResult": mostCommonResult,
          "lastScan": lastScan,
        };
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading profile data: $e");
      setState(() {
        userData = {};
        isLoading = false;
      });
    }
  }

  // ✅ Pick image, upload to Supabase (history bucket), write URL to Firestore, update UI
  Future<void> _pickAndUploadProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _uploadingAvatar = true);

      final bytes = await File(picked.path).readAsBytes();

      // infer mime from extension
      String ext = picked.path.split('.').last.toLowerCase();
      String contentType = switch (ext) {
        'png' => 'image/png',
        'webp' => 'image/webp',
        'jpg' => 'image/jpeg',
        'jpeg' => 'image/jpeg',
        _ => 'image/jpeg',
      };

      // store under user's folder in the existing 'history' bucket
      final storagePath =
          '${user.uid}/profile_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final supabase = Supabase.instance.client;

      await supabase.storage.from('history').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType,
            ),
          );

      final publicUrl =
          supabase.storage.from('history').getPublicUrl(storagePath);

      // Save URL to Firestore so it persists across sessions
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'profileImageUrl': publicUrl,
          'profileImagePath': storagePath, // for future delete/replace
          'profileUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      // Update local state immediately
      setState(() {
        userData = {
          ...?userData,
          'profileImageUrl': publicUrl,
        };
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated.')),
        );
      }
    } catch (e) {
      debugPrint('Avatar upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update profile photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
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

    // ✅ Intercept system back to always go straight to dashboard (and clear stack)
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF5FD),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEAF5FD),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
            // ✅ Back button: also go straight to dashboard and clear stack
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            ),
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

                const SizedBox(height: 24),

                // NEW tiles
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        label: "TOTAL SCANS",
                        value: (data["totalScans"] ?? 0).toString(),
                        isNumber: true, // big centered number
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _metricCard(
                        label: "MOST COMMON RESULT",
                        value:
                            (data["mostCommonResult"] ?? "None yet").toString(),
                        isNumber: false, // wrap to two lines
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _lastScanCard(
                  title: "LAST SCAN",
                  line1: (data["lastScan"] ?? "No scans yet")
                      .toString()
                      .split(" • ")
                      .first,
                  line2: (() {
                    final parts =
                        (data["lastScan"] ?? "").toString().split(" • ");
                    return parts.length > 1 ? parts.last : null;
                  })(),
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
            onTap: () {
              // ✅ Replace current route with History to avoid stacking
              Navigator.pushReplacementNamed(context, '/history');
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
          // ✅ Avatar + small camera button overlay
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: avatarChild,
              ),
              Positioned(
                bottom: 0,
                right: 2,
                child: InkWell(
                  onTap: _uploadingAvatar ? null : _pickAndUploadProfileImage,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B87D2),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _uploadingAvatar
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.photo_camera,
                            color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
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

  // ---------- UPDATED metric tile (no ellipsis, auto-fit) ----------
  Widget _metricCard({
    required String label,
    required String value,
    bool isNumber = false,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14001372),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9EACB7),
            ),
          ),
          const SizedBox(height: 6),

          // Value area
          Expanded(
            child: isNumber
                // Big centered number
                ? Center(
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF001372),
                      ),
                    ),
                  )
                // Long single-word labels auto-scale to fit width (no ellipsis)
                : Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF001372),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _lastScanCard({
    required String title,
    required String line1,
    String? line2,
  }) {
    return Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14001372),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9EACB7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            line1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF001372),
            ),
          ),
          if (line2 != null) ...[
            const SizedBox(height: 2),
            Text(
              line2!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6D777F),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // (Old _topCard kept for compatibility; unused now)
  Widget _topCard(
    String title,
    String value, {
    double height = 120,
    bool isFullWidth = false,
  }) {
    final bool isNumberOnly = RegExp(r'^\d+$').hasMatch(value.trim());

    return Container(
      height: height,
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9EACB7),
            ),
          ),

          // VALUE
          Expanded(
            child: isNumberOnly
                ? Center(
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF001372),
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    // Shrink LONG single words to fit on ONE line — no ellipsis.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        textWidthBasis: TextWidthBasis.longestLine,
                        style: const TextStyle(
                          fontSize: 20, // will scale down as needed
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF001372),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
