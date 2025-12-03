import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpExtraPage extends StatefulWidget {
  const SignUpExtraPage({super.key});

  @override
  State<SignUpExtraPage> createState() => _SignUpExtraPageState();
}

class _SignUpExtraPageState extends State<SignUpExtraPage> {
  final birthdayController = TextEditingController();
  final phoneController = TextEditingController();

  String? _selectedSex;
  bool isLoading = false;

  Map<String, dynamic>? baseData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    baseData = args;
  }

  @override
  void dispose() {
    birthdayController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _createAccount() async {
    if (baseData == null) {
      showError("Missing signup data.");
      return;
    }

    final birthday = birthdayController.text.trim();
    final phone = phoneController.text.trim();

    if (birthday.isEmpty || phone.isEmpty) {
      showError("Please fill out all fields.");
      return;
    }

    if (_selectedSex == null) {
      showError("Please select your sex.");
      return;
    }

    final fullName = baseData!["fullName"];
    final email = baseData!["email"];
    final password = baseData!["password"];

    setState(() => isLoading = true);

    try {
      // 1) Create account in Firebase Auth
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 2) VERY IMPORTANT: set displayName = fullName
      await userCred.user!.updateDisplayName(fullName);

      // 3) Save extra profile data in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCred.user!.uid)
          .set({
        "fullName": fullName,
        "email": email,
        "birthday": birthday,
        "phone": phone,
        "sex": _selectedSex,
        "profileImageUrl": "",
        "totalScans": 0,
        "mostCommonResult": "None yet",
        "lastScan": "No scans yet",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // 4) Show dialog then back to Login (same as before)
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
    } catch (e) {
      showError("Signup failed: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = baseData?["fullName"] ?? "";

    return Scaffold(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F9FF),
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/logo.png",
                            width: 65,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Complete Profile",
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFF1F41BB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (fullName.isNotEmpty)
                      Text(
                        "Hi, $fullName 👋",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F41BB),
                        ),
                      ),

                    const SizedBox(height: 4),

                    const Text(
                      "Step 2 of 2 • Add your profile details",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "This helps us personalize your KuCognition experience.",
                      style: TextStyle(fontSize: 13),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      "Birthday (e.g. Jan 1, 2000)",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _bubbleInput(
                      controller: birthdayController,
                      icon: Icons.calendar_today_outlined,
                      keyboard: TextInputType.datetime,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Phone Number",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _bubbleInput(
                      controller: phoneController,
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone,
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Sex",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    _sexDropdown(),

                    const SizedBox(height: 30),

                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B87D2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: _createAccount,
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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

  // BLUE BUBBLE INPUT
  Widget _bubbleInput({
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
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
              keyboardType: keyboard,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  // DROP DOWN
  Widget _sexDropdown() {
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF5FD),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline,
                size: 20, color: Color(0xFF3B87D2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSex,
                hint: const Text("Select sex"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                  DropdownMenuItem(
                    value: "Prefer not to say",
                    child: Text("Prefer not to say"),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedSex = value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BREATHING GRADIENT
class BreathingGradient extends StatefulWidget {
  const BreathingGradient({super.key});

  @override
  State<BreathingGradient> createState() => _BreathingGradientState();
}

class _BreathingGradientState extends State<BreathingGradient>
    with TickerProviderStateMixin {
  late AnimationController _c1;
  late AnimationController _c2;

  @override
  void initState() {
    super.initState();
    _c1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _c2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_c1, _c2]),
      builder: (_, __) {
        final r1 = 0.9 + (_c1.value * 0.35);

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: r1,
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
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }
}
