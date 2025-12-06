import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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

  final ImagePicker _picker = ImagePicker();
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ---------------------- LOAD USER DATA + HISTORY (PH TIME FIXED) ----------------------

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

      // --- Basic User Document ---
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

      // --- History Stats ---
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
            lastDoc['predictionLabel'] ?? 'Unknown condition';

        final tsRaw = lastDoc['timestamp'];
        String datePart = "";

        // ⭐⭐⭐ PH TIME FIX HERE ⭐⭐⭐
        if (tsRaw is Timestamp) {
          final utc = tsRaw.toDate();
          final phTime = utc.add(const Duration(hours: 8)); // PH TIME
          datePart =
              DateFormat('MMMM d, yyyy – h:mm a').format(phTime);
        }

        lastScan = datePart.isNotEmpty ? "$lastLabel • $datePart" : lastLabel;

        // Count Frequent Labels
        final Map<String, int> counts = {};
        for (final d in historySnap.docs) {
          final m = d.data() as Map<String, dynamic>? ?? {};
          final label = m['predictionLabel'] ?? 'Unknown condition';
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

        mostCommonResult = bestLabel;
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
      debugPrint("Error loading user data: $e");
      setState(() {
        userData = {};
        isLoading = false;
      });
    }
  }

  // ---------------------- PROFILE IMAGE UPLOAD ----------------------

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

      String ext = picked.path.split('.').last.toLowerCase();
      String contentType = ext == "png"
          ? "image/png"
          : ext == "webp"
              ? "image/webp"
              : "image/jpeg";

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

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'profileImageUrl': publicUrl,
          'profileImagePath': storagePath,
          'profileUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

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
      debugPrint("Avatar upload error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not upload photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  // ---------------------- LOGOUT ----------------------

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  // ---------------------- UI BUILD (WITH BACKGROUND IMAGE) ----------------------

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEAF5FD),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = userData ?? {};

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF5FD),
        body: Stack(
          children: [
            // ⭐ BACKGROUND IMAGE
            Positioned.fill(
              child: Image.asset(
                'assets/images/bgg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // MAIN PAGE CONTENT
            SingleChildScrollView(
              child: Column(
                children: [
                  _header(),

                  const SizedBox(height: 20),

                  _avatarAndProfileCard(data),

                  const SizedBox(height: 25),

                  if (isAboutSelected) ...[
                    _editProfileButton(),
                    const SizedBox(height: 24),

                    // METRICS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Row(
                        children: [
                          Expanded(
                            child: _metricCard(
                              label: "TOTAL SCANS",
                              value: (data["totalScans"] ?? 0).toString(),
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _metricCard(
                              label: "MOST COMMON RESULT",
                              value: (data["mostCommonResult"] ?? "None yet")
                                  .toString(),
                              isNumber: false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // LAST SCAN CARD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: _lastScanCard(
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
                    ),

                    const SizedBox(height: 40),
                    _logoutButton(),
                    const SizedBox(height: 80),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- HEADER UI ----------------------

  Widget _header() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9FCCFF),
            Color(0xFF5E95E8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/dashboard', (_) => false);
                  },
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),

            const SizedBox(height: 6),

            // ABOUT | HISTORY TABS
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => isAboutSelected = true),
                    child:
                        _tabChip("ABOUT", isActive: isAboutSelected),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/history'),
                    child:
                        _tabChip("HISTORY", isActive: !isAboutSelected),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- AVATAR + PROFILE CARD ----------------------

  Widget _avatarAndProfileCard(Map<String, dynamic> data) {
    final fullName = data["fullName"] ?? "User";
    final email = data["email"] ?? "";
    final sex = data["sex"] ?? "Not set";
    final birthday = data["birthday"] ?? "Not set";
    final profileImageUrl = data["profileImageUrl"] ?? "";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 22),
          padding: const EdgeInsets.only(top: 80, bottom: 26),
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
          child: Column(
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF001372),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF79838B),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoColumn("Sex", sex),
                  _infoColumn("Birthday", birthday),
                ],
              ),
            ],
          ),
        ),

        // Avatar Overlap
        Positioned(
          top: -55,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.white,
                  child: profileImageUrl.isNotEmpty
                      ? CircleAvatar(
                          radius: 48,
                          backgroundImage: NetworkImage(profileImageUrl),
                        )
                      : const CircleAvatar(
                          radius: 48,
                          backgroundColor: Color(0xFFEAF5FD),
                          child: Icon(Icons.person,
                              size: 40, color: Color(0xFF6D777F)),
                        ),
                ),

                // Camera Button
                Positioned(
                  bottom: 3,
                  right: 3,
                  child: InkWell(
                    onTap: _uploadingAvatar ? null : _pickAndUploadProfileImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B87D2),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: _uploadingAvatar
                          ? const Padding(
                              padding: EdgeInsets.all(7),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.camera_alt,
                              size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------- SMALL HELPERS ----------------------

  Widget _infoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF001372),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6D777F),
          ),
        ),
      ],
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

  Widget _editProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B87D2),
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 5,
        ),
        onPressed: () {},
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required bool isNumber,
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
          Expanded(
            child: isNumber
                ? Center(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF001372),
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        maxLines: 1,
                        softWrap: false,
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
        icon: const Icon(Icons.logout, color: Colors.white),
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
}
