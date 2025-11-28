import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  ///  Unified Disease Database with Recommendations
  static const Map<String, Map<String, String>> diseaseInfo = {
    'Acral Lentiginous Melanoma': {
      'displayName': 'Acral Lentiginous Melanoma',
      'color': 'Dark brown or black streak',
      'texture': 'Smooth but widening band',
      'pattern': 'Irregular borders / widening over time',
      'confidence': '82%', // fallback only
      'risk': 'High',
      'description':
          'Acral lentiginous melanoma is a serious form of skin cancer that '
          'can appear under the fingernails or toenails. It often looks like '
          'a dark streak or patch that gradually becomes wider or more irregular. '
          'Because it occurs in areas that are not exposed to the sun, it is easy '
          'to mistake it for a bruise, stain, or injury. If this type of melanoma '
          'is not detected early, the cancer cells can grow deeper and spread to '
          'the lymph nodes and other organs, which can be life-threatening. '
          'Early recognition is important because treatment is more effective in '
          'the early stages. Detecting suspicious nail changes during analysis '
          'can guide someone to seek medical evaluation sooner, which significantly '
          'improves outcomes.',
      'recommendations':
          '⚠️ Seek urgent evaluation by a dermatologist or medical professional. '
          'Do not attempt home treatment. If the streak widens, darkens, or grows irregular, '
          'schedule a biopsy and follow medical guidance immediately.',
    },

    'Clubbing': {
      'displayName': 'Clubbing',
      'color': 'Normal or slightly red',
      'texture': 'Soft spongy nail bed',
      'shape': 'Downward-curving, bulbous fingertip',
      'confidence': '88%',
      'risk': 'Moderate',
      'description':
          'Nail clubbing is a change in the shape of the fingertips where the nails '
          'curve more than usual and the tips of the fingers become rounder and swollen. '
          'This occurs because of increased blood flow and tissue growth beneath the nail. '
          'Clubbing is often linked to long-term conditions that affect the heart, lungs, '
          'or blood circulation. These include chronic lung diseases, congenital heart '
          'problems, liver disorders, and some gastrointestinal diseases. Since clubbing '
          'develops gradually and may not cause pain, it can be an early visible sign of '
          'an internal health issue. Detecting this pattern encourages earlier medical '
          'evaluation, which can lead to timely treatment of underlying conditions.',
      'recommendations':
          'Schedule a medical checkup to screen for heart or lung disease. '
          'If you smoke, reduce or stop. Monitor your breathing and exercise tolerance. '
          'Do not file or press the nail—focus on investigating underlying causes.',
    },

    'Healthy Nail': {
      'displayName': 'Healthy Nail',
      'color': 'Pink nail bed',
      'texture': 'Smooth surface',
      'shape': 'Even thickness, natural curve',
      'confidence': '94%',
      'risk': 'Low',
      'description':
          'A healthy nail appears smooth, evenly colored, and firmly attached to the nail bed. '
          'It does not show significant discoloration, splitting, pitting, or thickening. '
          'Healthy nails often reflect good nutrition, balanced circulation, and proper self-care. '
          'While a normal appearance does not guarantee the absence of internal health issues, '
          'it suggests that there are no obvious external signs of infection, inflammation, or '
          'underlying systemic disease. Recognizing a healthy baseline is important because it '
          'makes it easier to detect new changes that might indicate future medical concerns.',
      'recommendations':
          'Maintain basic nail hygiene, moisturize, trim regularly, avoid biting.'
          'Report sudden color change, pain, or streaks to a doctor.',
    },

    'Onychogryphosis': {
      'displayName': 'Onychogryphosis',
      'color': 'Yellow-brown',
      'texture': 'Thick and hard',
      'shape': 'Curved or horn-like growth',
      'confidence': '90%',
      'risk': 'Moderate',
      'description':
          'Onychogryphosis is a condition where the nail becomes thick, overgrown, and curved in '
          'a horn-like shape. It commonly affects toenails that experience repeated pressure, '
          'friction, or lack of regular trimming. This condition may also occur in older adults '
          'or in people with difficulties maintaining nail care. Onychogryphosis can be associated '
          'with poor circulation, skin disorders, or trauma to the nail. In some cases, it appears '
          'together with fungal infections or other nail diseases. Early detection can help address '
          'discomfort, prevent secondary infections, and identify whether circulation problems or '
          'mobility issues are contributing to the nail changes.',
      'recommendations':
          'Consult a podiatrist or dermatologist for safe trimming.'
          ' Wear wide shoes and do not cut the nail aggressively at home.',
    },

    'Pitting': {
      'displayName': 'Nail Pitting',
      'color': 'Pale or yellowish spots',
      'texture': 'Tiny dents or pits',
      'shape': 'Irregular edges',
      'confidence': '87%',
      'risk': 'Moderate',
      'description':
          'Nail pitting refers to tiny indentations or dents in the surface of the nail. It is often '
          'linked to psoriasis, an inflammatory skin condition that can also affect the nails. People '
          'with nail pitting may be at higher risk of developing psoriatic arthritis, an inflammatory '
          'joint condition. Pitting can also appear in other autoimmune or inflammatory disorders. '
          'Although nail pitting itself is not dangerous, it may reflect underlying immune system '
          'activity or chronic inflammation. Detecting this pattern early can support earlier evaluation '
          'for psoriasis, joint symptoms, or other autoimmune conditions, which makes treatment more effective '
          'and reduces the risk of long-term complications.',
      'recommendations':
          'Monitor for psoriasis symptoms on the skin or joints (pain, stiffness). '
          'Keep nails short and moisturized to reduce brittleness. '
          'Avoid nail hardeners or acrylic nails. If pitting worsens or pain appears, '
          'consult a dermatologist for evaluation.',
    },

    'Unknown / Not in trained classes': {
      'displayName': 'Unknown / Not in trained classes',
      'color': 'Varies',
      'texture': 'Varies',
      'shape': 'Not recognized',
      'confidence': '—',
      'risk': 'Unknown',
      'description':
          'This image does not match any of the known trained nail categories.'
          ' This result does not mean the nail is healthy or unhealthy.',
      'recommendations':
          'Retake the photo in good lighting and centered on the nail.'
          ' If the nail is painful, rapidly changing, or infected—consult a professional.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;

    final String? imagePath = args?['imagePath'];
    final String rawLabel =
        args?['label'] ?? "Unknown / Not in trained classes";
    final double? confidence = args?['confidence'];

    /// Smart fallback
    final info =
        diseaseInfo[rawLabel] ??
        diseaseInfo['Unknown / Not in trained classes']!;
    final label = info['displayName']!;
    final risk = info['risk']!;
    final desc = info['description']!;
    final recs = info['recommendations']!;
    final color = info['color'];
    final texture = info['texture'];
    final shape = info['shape'] ?? info['pattern'];

    final confString = confidence != null
        ? "${(confidence * 100).toStringAsFixed(1)}%"
        : info['confidence'] ?? "—";

    /// Dynamic risk color
    Color riskColor = Colors.grey;
    if (risk == "High") riskColor = Colors.red.shade700;
    if (risk == "Moderate") riskColor = Colors.orange.shade700;
    if (risk == "Low") riskColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "AI Nail Scan Result",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF001372),
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
        child: Column(
          children: [
            /// IMAGE CARD
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 240,
                color: Colors.white,
                child: imagePath == null
                    ? const Center(child: Icon(Icons.image, size: 50))
                    : Image.file(File(imagePath), fit: BoxFit.cover),
              ),
            ),

            const SizedBox(height: 20),

            /// CONDITION HEADER
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("Detected Condition"),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF001372),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            /// CONFIDENCE + RISK
            Row(
              children: [
                Expanded(
                  child: _badgeCard(
                    title: "Confidence",
                    value: confString,
                    textColor: Colors.blue.shade700,
                    color: Colors.blue.shade50,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _badgeCard(
                    title: "Risk Level",
                    value: risk,
                    textColor: riskColor,
                    color: riskColor.withOpacity(.15),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// VISUAL FEATURES
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("Visual Characteristics"),
                  const SizedBox(height: 10),
                  _detail("Color", color),
                  _detail("Texture", texture),
                  _detail("Shape / Pattern", shape),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// DESCRIPTION
            _infoCard(
              background: const Color(0xFFDCEFFF),
              child: Text(
                desc,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.black87,
                  height: 1.45,
                ),
              ),
            ),

            const SizedBox(height: 18),

            /// RECOMMENDATIONS
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("Recommendations"),
                  const SizedBox(height: 10),
                  Text(
                    recs,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: _buttonStyle(primary: const Color(0xFF3B87D2)),
                    child: const Text("Done"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    style: _buttonOutline(),
                    child: const Text("History"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              "This is AI pattern analysis — NOT a medical diagnosis.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // Helpers
  // ============================

  Widget _header(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Color(0xFF001372),
    ),
  );

  Widget _infoCard({required Widget child, Color background = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _badgeCard({
    required String title,
    required String value,
    required Color textColor,
    required Color color,
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
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.5,
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String? value) {
    if (value == null || value == "—") return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        "• $label: $value",
        style: const TextStyle(fontSize: 13.5, color: Colors.black87),
      ),
    );
  }

  ButtonStyle _buttonStyle({required Color primary}) {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    );
  }

  ButtonStyle _buttonOutline() {
    return OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF3B87D2),
      padding: const EdgeInsets.symmetric(vertical: 14),
      side: const BorderSide(width: 1.6, color: Color(0xFF3B87D2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
