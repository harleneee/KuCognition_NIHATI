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

  Map<String, dynamic>? baseData; // from page 1

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
      showError("Missing signup data. Please go back and try again.");
      return;
    }

    final birthday = birthdayController.text.trim();
    final phone = phoneController.text.trim();

    if (birthday.isEmpty || phone.isEmpty) {
      showError("Please fill out all fields.");
      return;
    }

    if (_selectedSex == null || _selectedSex!.isEmpty) {
      showError("Please select your sex.");
      return;
    }

    final fullName = baseData!["fullName"] as String;
    final email = baseData!["email"] as String;
    final password = baseData!["password"] as String;

    setState(() => isLoading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
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
      String msg = "Signup failed.";

      switch (e.code) {
        case 'email-already-in-use':
          msg = "This email is already registered.";
          break;
        case 'invalid-email':
          msg = "The email address is not valid.";
          break;
        case 'weak-password':
          msg = "The password is too weak.";
          break;
        case 'operation-not-allowed':
          msg = "Email/password sign-up is not enabled.";
          break;
        default:
          msg = e.message ?? "Signup failed. Please try again.";
      }
      showError(msg);
    } catch (e) {
      showError("Unexpected error: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = baseData != null ? baseData!["fullName"] as String : "";

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          "Complete Profile",
          style: TextStyle(
            color: Color(0xFF1F41BB),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fullName.isNotEmpty) ...[
              Text(
                "Hi, $fullName 👋",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F41BB),
                ),
              ),
              const SizedBox(height: 4),
            ],
            const Text(
              "Step 2 of 2 • Add your profile details",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "This helps us personalize your KuCognition experience.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Birthday
            _inputField(
              "Birthday (e.g. Jan 1, 2000)",
              birthdayController,
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 15),

            // Phone
            _inputField(
              "Phone Number",
              phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),

            // Sex dropdown
            const Text(
              "Sex",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.black12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSex,
                  hint: const Text("Select sex"),
                  items: const [
                    DropdownMenuItem(
                      value: "Male",
                      child: Text("Male"),
                    ),
                    DropdownMenuItem(
                      value: "Female",
                      child: Text("Female"),
                    ),
                    DropdownMenuItem(
                      value: "Prefer not to say",
                      child: Text("Prefer not to say"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSex = value;
                    });
                  },
                ),
              ),
            ),

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
                        elevation: 3,
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
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
            keyboardType: keyboardType,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
