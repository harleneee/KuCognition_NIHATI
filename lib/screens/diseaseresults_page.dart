import 'package:flutter/material.dart';
import '../data/disease_data.dart';

class DiseaseDetailsPage extends StatelessWidget {
  final String disease;

  const DiseaseDetailsPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final DiseaseInfo info = diseaseDatabase[disease]!;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Whole page scrolls except bottom button
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 🔹 IMAGE AT TOP — FULL WIDTH
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                      child: Image.asset(
                        info.image,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 DISEASE NAME
                    Text(
                      info.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF001372),
                        fontSize: 22,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // 🔹 DESCRIPTION BOX
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Color(0xFF001372), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What is ${info.name}?",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            info.description,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔹 SIGNS BOX
                    Container(
                      width: 350,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Color(0xFF001372), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Key Visual Signs",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...info.signs.map(
                            (sign) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                "• $sign",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // 🔹 BUTTON + DISCLAIMER (FIXED AT BOTTOM)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B87D2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Done",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "MEDICAL DISCLAIMER: This information is for educational purposes only and not a substitute for medical advice.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD91313),
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}