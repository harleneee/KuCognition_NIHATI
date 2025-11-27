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
      'confidence': '82%',
      'risk': 'High',
      'description':
          'Acral lentiginous melanoma is a rare but aggressive type of skin cancer '
          'that appears under nails. It may look like a bruise or streak. Early '
          'professional diagnosis is critical to survival.',
    },
    'Clubbing': {
      'displayName': 'Clubbing',
      'color': 'Normal or reddish',
      'texture': 'Spongy nail bed',
      'shape': 'Bulbous fingertip & curved nail',
      'confidence': '88%',
      'risk': 'Moderate',
      'description':
          'Nail clubbing is associated with cardiovascular or pulmonary disease. '
          'It may be a sign of chronic inflammation, heart defects, or cancer.',
    },
    'Healthy Nail': {
      'displayName': 'Healthy Nail',
      'color': 'Pink nail bed',
      'texture': 'Smooth surface',
      'shape': 'Even thickness, natural curve',
      'confidence': '94%',
      'risk': 'Low',
      'description':
          'This nail appears within normal visual parameters. '
          'No indication of fungal or systemic disease.',
    },
    'Onychogryphosis': {
      'displayName': 'Onychogryphosis',
      'color': 'Yellow-brown',
      'texture': 'Hard, thickened',
      'shape': 'Curved horn-like growth',
      'confidence': '90%',
      'risk': 'Moderate',
      'description':
          'Thickened and curved nail linked to trauma, poor circulation, '
          'aging, or chronic disease.',
    },
    'Pitting': {
      'displayName': 'Pitting',
      'color': 'Pale or yellow dots',
      'texture': 'Small dents',
      'shape': 'Irregular surface',
      'confidence': '87%',
      'risk': 'Moderate',
      'description':
          'Nail pitting is associated with psoriasis and autoimmune disorders. '
          'It may indicate inflammatory disease.',
    },
    'Unknown': {
      'displayName': 'Unknown Condition',
      'color': '—',
      'texture': '—',
      'shape': '—',
      'confidence': '—',
      'risk': 'Unknown',
      'description':
          'The model could not confidently match this nail to a trained class.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;

    final String? imagePath = args?['imagePath'];
    final String rawLabel = args?['label'] ?? "Unknown";
    final double? confidence = args?['confidence'];

    // Match label to known categories
    final info = diseaseInfo[rawLabel] ?? diseaseInfo['Unknown']!;
    final displayName = info['displayName'];
    final color = info['color'];
    final texture = info['texture'];
    final shape = info['shape'];
    final desc = info['description'];
    final risk = info['risk'];

    // Format confidence
    String confString;
    if (confidence != null) {
      confString = "${(confidence * 100).toStringAsFixed(1)}%";
    } else {
      confString = info['confidence'] ?? '—';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5FD),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "🩺 AI Nail Scan Result",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF001372),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 IMAGE PREVIEW
            Container(
              height: 220,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: imagePath == null
                  ? const Center(child: Icon(Icons.image, size: 40))
                  : Image.file(File(imagePath), fit: BoxFit.cover),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // CARD 1 — Prediction
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(),
              child: Column(
                children: [
                  const Text(
                    "Detected Condition",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayName ?? rawLabel,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      color: Color(0xFF001372),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==========================================
            // CARD 2 — Confidence + Risk
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(),
              child: Column(
                children: [
                  _pill(
                    "Confidence",
                    confString,
                    const Color(0xFFE3F2FD),
                    const Color(0xFF1565C0),
                  ),
                  const SizedBox(height: 8),
                  _pill(
                    "Risk Level",
                    risk ?? "—",
                    risk == "High"
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE8F5E9),
                    risk == "High"
                        ? const Color(0xFFC62828)
                        : const Color(0xFF2E7D32),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==========================================
            // CARD 3 — Physical characteristics
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(),
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
                  const SizedBox(height: 6),
                  _bullet("Color", color),
                  _bullet("Texture", texture),
                  _bullet("Shape / Pattern", shape),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ==========================================
            // CARD 4 — Medical Explanation
            // ==========================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(color: const Color(0xFFC0E4FF)),
              child: Text(
                desc ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 26),

            // DONE BUTTON
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B87D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Done"),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "DISCLAIMER: Predictions are AI-based pattern interpretations.\nThis is not a medical diagnosis.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xFFC62828)),
            ),
          ],
        ),
      ),
    );
  }

  // ======== UI Helpers =========

  BoxDecoration _card({Color color = Colors.white}) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _bullet(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "• $label: $value",
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _pill(String title, String value, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
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
}
