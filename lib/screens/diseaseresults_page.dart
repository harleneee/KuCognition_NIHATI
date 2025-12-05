import 'package:flutter/material.dart';
import 'chatbot_page.dart';

const Color _primaryBlue = Color(0xFF3B70B9);
const Color _darkBlue = Color(0xFF001372);
const Color _bgBlue = Color(0xFFEAF5FD);

class DiseaseDetailsPage extends StatelessWidget {
  final String disease;

  const DiseaseDetailsPage({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    final info = _diseaseData[disease] ?? _defaultInfo;

    return Scaffold(
      backgroundColor: _bgBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // Blue gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A4FA3), Color(0xFF6BA5F2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _HeaderImage(info: info),

                      // CONTENT
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // OVERVIEW TITLE
                            Text(
                              info.overviewTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // DESCRIPTION
                            Text(
                              info.description,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // KEY SIGNS
                            if (info.keySigns.isNotEmpty)
                              const Text(
                                "Key Visual Signs",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            const SizedBox(height: 8),

                            ...info.keySigns.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("• ", style: TextStyle(fontSize: 14)),
                                    Expanded(
                                      child: Text(
                                        s,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Ask KuBot Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  final conditionCode =
                                      _diseaseToConditionCode[disease];

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatbotPage(
                                        initialPrompt:
                                            "Hi KuBot, can you tell me more about ${info.displayTitle}? What causes it, and what should I do?",
                                        initialCondition: conditionCode,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF4C8CDA),
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  "Ask KuBot About This",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // DONE BUTTON
                            Center(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Done",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              'MEDICAL DISCLAIMER: This information is for educational purposes only and should not replace professional medical advice.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: Colors.redAccent,
                                height: 1.22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ******** HEADER IMAGE + TITLE BELOW ********
class _HeaderImage extends StatelessWidget {
  final _DiseaseInfo info;

  const _HeaderImage({required this.info});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // BIG CLEAN NAIL IMAGE
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: Image.asset(
                info.imagePath,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // TITLE BELOW PHOTO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                info.displayTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Nail health indicator",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

//
// ******** DATA MODEL + NEW EXPANDED DESCRIPTIONS ********
//

class _DiseaseInfo {
  final String displayTitle;
  final String imagePath;
  final String overviewTitle;
  final String description;
  final List<String> keySigns;

  const _DiseaseInfo({
    required this.displayTitle,
    required this.imagePath,
    required this.overviewTitle,
    required this.description,
    required this.keySigns,
  });
}

const _DiseaseInfo _defaultInfo = _DiseaseInfo(
  displayTitle: 'Nail Condition',
  imagePath: 'assets/images/healthy.jpg',
  overviewTitle: 'Overview',
  description:
      'This nail condition may be associated with changes in nail health, circulation, or nutrition.',
  keySigns: [],
);

// NEW: map UI disease keys → backend condition codes
const Map<String, String> _diseaseToConditionCode = {
  "Blue Finger/Bluish nail (Cyanosis)": "bluish_nail",
  "Clubbing": "clubbing_nail",
  "Onychomycosis": "onychomycosis",
  "Psoriasis": "psoriasis",
  "Healthy Nail": "healthy_nail",
  "Acral Lentiginous Melanoma": "acral_lentiginous_melanoma",
  "Onychogryphosis": "onychogryphosis",
  "Pitting": "pitting",
  "Yellow Nail": "yellow_nail",
  "White Nail": "white_nail",
  "Beau’s line": "beau_s_line",
  "Koilonychia": "koilonychia",
};

final Map<String, _DiseaseInfo> _diseaseData = {
  "Blue Finger/Bluish nail (Cyanosis)": _DiseaseInfo(
    displayTitle: "Blue Finger / Cyanosis",
    imagePath: "assets/images/cyanosis.jpg",
    overviewTitle: "What is Blue Finger / Cyanosis?",
    description:
        "Cyanosis is a bluish or purplish discoloration of the fingertips caused by low oxygen levels in the blood. "
        "It may occur from heart or lung problems, circulation issues, cold exposure, or restricted blood flow. "
        "Sudden or persistent cyanosis should be checked immediately as it may indicate a serious underlying condition.",
    keySigns: [
      "Bluish or purplish nail beds",
      "Cold fingers or hands",
      "Low oxygen circulation",
      "Possible numbness or tingling",
    ],
  ),

  "Clubbing": _DiseaseInfo(
    displayTitle: "Clubbing",
    imagePath: "assets/images/clubbing.jpg",
    overviewTitle: "What is Nail Clubbing?",
    description:
        "Nail clubbing involves enlargement of the fingertips and downward curving of the nails. "
        "It is commonly linked to chronic heart or lung diseases and is considered a sign of long-term reduced oxygen in the blood. "
        "Evaluation is recommended if clubbing develops or worsens.",
    keySigns: [
      "Rounded, bulb-like fingertips",
      "Nails curve downward",
      "Loss of normal nail angle",
    ],
  ),

  "Onychomycosis": _DiseaseInfo(
    displayTitle: "Onychomycosis",
    imagePath: "assets/images/onychomycosis.jpg",
    overviewTitle: "What is Onychomycosis?",
    description:
        "A fungal infection of the nail leading to thickening, discoloration, and brittleness. "
        "It may progress slowly and can cause nail distortion or separation. Early treatment helps prevent severe damage.",
    keySigns: [
      "Yellow or white nail discoloration",
      "Thick or brittle nails",
      "Crumbling nail edges",
      "Nail lifting in severe cases",
    ],
  ),

  "Psoriasis": _DiseaseInfo(
    displayTitle: "Nail Psoriasis",
    imagePath: "assets/images/psoriasis.jpg",
    overviewTitle: "What is Nail Psoriasis?",
    description:
        "Nail psoriasis affects nail growth and structure, causing pitting, discoloration, and thickening. "
        "It often appears alongside skin psoriasis but may develop independently. Long-term care helps manage symptoms.",
    keySigns: [
      "Small pits or dents",
      "Yellow-brown discoloration",
      "Nail thickening or splitting",
    ],
  ),

  "Healthy Nail": _DiseaseInfo(
    displayTitle: "Healthy Nail",
    imagePath: "assets/images/healthy.jpg",
    overviewTitle: "What Does a Healthy Nail Look Like?",
    description:
        "Healthy nails are smooth, evenly colored, and firmly attached to the nail bed. "
        "They typically appear light pink with no major abnormalities. Sudden nail changes may suggest health issues.",
    keySigns: [
      "Smooth and firm surface",
      "Light pink color",
      "Even growth pattern",
    ],
  ),

  "Acral Lentiginous Melanoma": _DiseaseInfo(
    displayTitle: "Acral Lentiginous Melanoma",
    imagePath: "assets/images/melanoma.jpg",
    overviewTitle: "What is Acral Lentiginous Melanoma?",
    description:
        "A serious type of skin cancer appearing under the nails as a dark streak or band. "
        "It may widen, darken, or spread to the cuticle. This condition requires urgent medical evaluation.",
    keySigns: [
      "Dark brown or black streak",
      "Irregular borders",
      "Color spreading to the cuticle",
    ],
  ),

  "Onychogryphosis": _DiseaseInfo(
    displayTitle: "Onychogryphosis",
    imagePath: "assets/images/onychogryphosis.jpg",
    overviewTitle: "What is Onychogryphosis?",
    description:
        "A severe thickening and curving of the nail, often called 'ram’s horn nail'. "
        "It is usually due to chronic trauma, poor circulation, or aging, and often requires podiatric care.",
    keySigns: [
      "Extremely thick nails",
      "Curved or twisted shape",
      "Difficult to trim",
    ],
  ),

  "Pitting": _DiseaseInfo(
    displayTitle: "Nail Pitting",
    imagePath: "assets/images/pitting.jpg",
    overviewTitle: "What is Nail Pitting?",
    description:
        "Small depressions or pinprick holes on the nail surface. "
        "Commonly seen in psoriasis or autoimmune conditions, and may signal inflammation.",
    keySigns: [
      "Tiny pits on the nail",
      "Rough surface texture",
      "Uneven nail growth",
    ],
  ),

  "Yellow Nail": _DiseaseInfo(
    displayTitle: "Yellow Nail",
    imagePath: "assets/images/yellownail.jpg",
    overviewTitle: "What is Yellow Nail?",
    description:
        "Yellow nails may develop from fungal infection, smoking, chronic respiratory issues, or certain medications. "
        "Persistent yellowing should be monitored for underlying conditions.",
    keySigns: [
      "Yellow or yellow-green tint",
      "Slow-growing nails",
      "Possible thickening",
    ],
  ),

  "White Nail": _DiseaseInfo(
    displayTitle: "White Nail",
    imagePath: "assets/images/whitenail.jpg",
    overviewTitle: "What is White Nail?",
    description:
        "White nails can appear due to trauma, fungal infection, nutritional deficiency, or systemic conditions such as liver disease. "
        "The whiteness pattern helps determine the possible cause.",
    keySigns: [
      "White patches or full whiteness",
      "Bands or streaks",
    ],
  ),

  "Beau’s line": _DiseaseInfo(
    displayTitle: "Beau’s Lines",
    imagePath: "assets/images/beausline.jpg",
    overviewTitle: "What are Beau’s Lines?",
    description:
        "Horizontal grooves that appear when nail growth temporarily stops due to illness, fever, stress, or injury. "
        "The position of the groove can help estimate when the health event occurred.",
    keySigns: [
      "Horizontal grooves across the nail",
      "Often linked to past illness or trauma",
    ],
  ),

  "Koilonychia": _DiseaseInfo(
    displayTitle: "Koilonychia",
    imagePath: "assets/images/koilonychia.jpg",
    overviewTitle: "What is Koilonychia?",
    description:
        "Koilonychia or 'spoon nails' occurs when the nail becomes thin and concave. "
        "It is often associated with iron deficiency anemia and may improve after correcting iron levels.",
    keySigns: [
      "Spoon-shaped nails",
      "Thin and soft texture",
    ],
  ),
};
