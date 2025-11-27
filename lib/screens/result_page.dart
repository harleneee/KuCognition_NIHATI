import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  /// DISEASE DATABASE — shared with Upload results
  static const Map<String, Map<String, String>> diseaseInfo = {
    'Acral Lentiginous Melanoma': {
      'displayName': 'Acral Lentiginous Melanoma',
      'color': 'Dark brown or black streak',
      'texture': 'Smooth but widening band',
      'shape': 'Irregular border, progressive widening',
      'risk': 'High',
      'description':
          'Acral lentiginous melanoma is a rare but aggressive form of melanoma that typically appears under the nails. '
          'It can look like a bruise or dark streak. Early professional diagnosis is critical.',
    },
    'Clubbing': {
      'displayName': 'Clubbing',
      'color': 'Normal or reddish',
      'texture': 'Spongy nail bed',
      'shape': 'Bulbous fingertip, curved nail',
      'risk': 'Moderate',
      'description':
          'Nail clubbing may be related to chronic heart or lung disease, inflammatory disorders, or cancer.',
    },
    'Healthy Nail': {
      'displayName': 'Healthy Nail',
      'color': 'Pink nail bed',
      'texture': 'Smooth and uniform',
      'shape': 'Even thickness, natural curve',
      'risk': 'Low',
      'description':
          'This scan shows no signs of fungal infection, inflammation, or systemic nail irregularities.',
    },
    'Onychogryphosis': {
      'displayName': 'Onychogryphosis',
      'color': 'Yellow-brown',
      'texture': 'Hard, thickened',
      'shape': 'Curved horn-like nail',
      'risk': 'Moderate',
      'description':
          'A thick, curved nail often associated with trauma, poor circulation, or long-term systemic issues.',
    },
    'Pitting': {
      'displayName': 'Nail Pitting',
      'color': 'Pale or yellow dots',
      'texture': 'Small dents',
      'shape': 'Irregular surface',
      'risk': 'Moderate',
      'description':
          'Pitting may indicate autoimmune disorders, including psoriasis or systemic inflammatory disease.',
    },
    'Unknown': {
      'displayName': 'Unknown Condition',
      'color': '—',
      'texture': '—',
      'shape': '—',
      'risk': 'Unknown',
      'description':
          'The model could not confidently classify this nail to any known category.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;

    final String? imagePath = args?['imagePath'];
    final String rawLabel = args?['label'] ?? "Unknown";
    final double? confidence = args?['confidence'];

    final info = diseaseInfo[rawLabel] ?? diseaseInfo['Unknown']!;
    final label = info['displayName']!;
    final risk = info['risk']!;
    final desc = info['description']!;
    final color = info['color'];
    final texture = info['texture'];
    final shape = info['shape'];

    final confString = confidence != null
        ? "${(confidence * 100).toStringAsFixed(1)}%"
        : "—";

    Color riskColor = Colors.grey;
    if (risk == "High") riskColor = Colors.red;
    if (risk == "Moderate") riskColor = Colors.orange;
    if (risk == "Low") riskColor = Colors.green;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFEAF5FD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "🔬 AI Nail Scan Result",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001372),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF001372)),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================
            // SCANNED IMAGE
            // ===============================
            Container(
              height: 230,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: _shadow(),
              ),
              child: imagePath == null
                  ? const Center(child: Icon(Icons.image, size: 40))
                  : Image.file(File(imagePath), fit: BoxFit.cover),
            ),

            const SizedBox(height: 18),

            // ===============================
            // PREDICTED CONDITION CARD
            // ===============================
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Detected Condition",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF001372),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===============================
            // CONFIDENCE / RISK
            // ===============================
            Row(
              children: [
                Expanded(
                  child: _badgeCard(
                    title: "Confidence",
                    value: confString,
                    color: Colors.blue.shade50,
                    textColor: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _badgeCard(
                    title: "Risk Level",
                    value: risk,
                    color: riskColor.withOpacity(.15),
                    textColor: riskColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ===============================
            // VISUAL FEATURES
            // ===============================
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Visual Characteristics",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF001372),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _detail("Color", color),
                  _detail("Texture", texture),
                  _detail("Shape / Pattern", shape),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ===============================
            // MEDICAL EXPLANATION
            // ===============================
            _infoCard(
              background: const Color(0xFFDCEFFF),
              child: Text(
                desc,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===============================
            // ACTION BUTTONS
            // ===============================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B87D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("Done"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Color(0xFF3B87D2),
                      side: const BorderSide(
                        color: Color(0xFF3B87D2),
                        width: 1.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("History"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text(
                "DISCLAIMER: This is an AI pattern analysis.\nNot a medical diagnosis.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // UI HELPERS
  // ===============================

  List<BoxShadow> _shadow() => [
    BoxShadow(
      color: Colors.black.withOpacity(.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  Widget _infoCard({required Widget child, Color background = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _shadow(),
      ),
      child: child,
    );
  }

  Widget _badgeCard({
    required String title,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: textColor.withOpacity(.7)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String? value) {
    if (value == null || value == "—") {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "• $label: $value",
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
