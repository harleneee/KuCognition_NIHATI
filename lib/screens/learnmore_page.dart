import 'package:flutter/material.dart';
import 'diseaseresults_page.dart'; // <-- IMPORT THE NEW PAGE

class LearnMorePage extends StatelessWidget {
  LearnMorePage({super.key});

  final List<String> items = [
    "Blue Finger/Bluish nail (Cyanosis)",
    "Clubbing",
    "Onychomycosis",
    "Psoriasis",
    "Healthy Nail",
    "Acral Lentiginous Melanoma",
    "Onychogryphosis",
    "Pitting",
    "Yellow Nail",
    "White Nail",
    "Beau’s line",
    "Koilonychia",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
              ),
            ),

            const Text(
              "NAIL HEALTH INDEX",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: 'Montserrat',
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Explore indicators and their potential meanings",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                color: Color(0xFF626262),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (_) => DiseaseDetailsPage(disease: items[index]),
                      ),
                    );
                  },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5FD),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFF001372),
                          width: 2.3,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          items[index],
                          style: const TextStyle(
                            fontSize: 15,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
