import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- HEADER ----------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.network("https://placehold.co/61x51", height: 50),
                      const SizedBox(width: 10),
                      const Text(
                        "KuCognition",
                        style: TextStyle(
                          color: Color(0xFF001372),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, "/login");
                      }
                    },
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                        color: Color(0xFFB62828),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Text(
                "Welcome!",
                style: TextStyle(
                  color: Color(0xFF001372),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Scan your nail to detect early signs of possible health conditions.",
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),

              const SizedBox(height: 20),

              // ---------------- CHECK NAIL HEALTH INDEX ----------------
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B87D2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "Check Nail Health Index",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------- SCAN NOW CARD ----------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Check your health now!",
                      style: TextStyle(
                        color: Color(0xFF001372),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Last Scan: None",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 15),

                    // 👉 Scan Now button
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/scan");
                      },
                      child: Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B87D2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Scan Now",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ---------------- RECENT SCANS ----------------
              const Text(
                "Recent Scans",
                style: TextStyle(
                  color: Color(0xFF001372),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "No recent scans",
                  style: TextStyle(
                    color: Color(0xFF6C7278),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- HEALTH TIPS ----------------
              const Text(
                "Health Tips",
                style: TextStyle(
                  color: Color(0xFF001372),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Image.network("https://placehold.co/31x44", height: 40),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        "White spots on nails can indicate a zinc deficiency.",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ---------------- FAQ ----------------
              const Text(
                "FAQs",
                style: TextStyle(
                  color: Color(0xFF001372),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              _faq("How do I use KuCognition to scan my nails?"),
              _faq("What health conditions can KuCognition detect?"),
              _faq("How accurate are the results?"),
              _faq("Can I view my previous scan results?"),
              _faq("What can I do if the app detects an abnormality?"),

              const SizedBox(height: 30),

              // ---------------- ABOUT US ----------------
              const Text(
                "About Us",
                style: TextStyle(
                  color: Color(0xFF001372),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      "KuCognition is an AI-powered health detection app designed "
                      "to help users monitor well-being through nail analysis.\n\n"
                      "We detect early signs of vitamin deficiency, anemia, and "
                      "other conditions using advanced image analysis.",
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      "https://placehold.co/133x133",
                      height: 120,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // FAQ tile widget
  Widget _faq(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF001372),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF001372)),
        ],
      ),
    );
  }
}
