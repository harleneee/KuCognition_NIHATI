import 'dart:io';
import 'package:flutter/material.dart';

class UploadedResult extends StatelessWidget {
  const UploadedResult({super.key});

  /// All disease info in one map so it’s easy to hook to the model.
  /// "confidence" here is just a fallback if model confidence is missing.
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
    },
    'Clubbing': {
      'displayName': 'Clubbing',
      'color': 'Normal or slightly red',
      'texture': 'Soft spongy nail bed',
      'shape': 'Downward-curving, bulbous fingertip',
      'confidence': '88%', // fallback
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
    },
    'Healthy Nail': {
      'displayName': 'Healthy Nail',
      'color': 'Pink nail bed',
      'texture': 'Smooth surface',
      'shape': 'Even thickness, natural curve',
      'confidence': '94%', // fallback
      'risk': 'Low',
      'description':
          'A healthy nail appears smooth, evenly colored, and firmly attached to the nail bed. '
          'It does not show significant discoloration, splitting, pitting, or thickening. '
          'Healthy nails often reflect good nutrition, balanced circulation, and proper self-care. '
          'While a normal appearance does not guarantee the absence of internal health issues, '
          'it suggests that there are no obvious external signs of infection, inflammation, or '
          'underlying systemic disease. Recognizing a healthy baseline is important because it '
          'makes it easier to detect new changes that might indicate future medical concerns.',
    },
    'Onychogryphosis': {
      'displayName': 'Onychogryphosis',
      'color': 'Yellow-brown',
      'texture': 'Thick and hard',
      'shape': 'Curved or ram’s horn growth',
      'confidence': '90%', // fallback
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
    },
    'Pitting': {
      'displayName': 'Pitting',
      'color': 'Pale or yellowish spots',
      'texture': 'Pitted / dented surface',
      'shape': 'Slightly irregular edges',
      'confidence': '87%', // fallback
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
    },
    'Unknown / Not in trained classes': {
      'displayName': 'Unknown / Not in trained classes',
      'color': 'Varies',
      'texture': 'Varies',
      'shape': 'Not recognized',
      'confidence': '—',
      'risk': 'Unknown',
      'description':
          'The uploaded image does not closely match any of the five nail conditions that this model '
          'was specifically trained on. The result is therefore marked as unknown. This does not mean '
          'the nail is healthy or unhealthy—it simply indicates that the pattern falls outside the '
          'model’s trained categories. For unusual, rapidly changing, or worrying nail appearances, '
          'a consultation with a healthcare professional is strongly recommended.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)!.settings.arguments;

    String? imagePath;
    String predictionKey = 'Healthy Nail'; // default
    String? rawLabelFromModel;
    double? modelConfidence; // 0–1 from backend

    // 🔹 Read arguments passed from UploadedPage
    if (args is String) {
      // old style: only imagePath string
      imagePath = args;
    } else if (args is Map) {
      imagePath = args['imagePath'] as String?;
      final dynamic labelArg = args['label'];
      final dynamic confArg = args['confidence'];

      if (labelArg is String) {
        rawLabelFromModel = labelArg;
      }

      if (confArg is num) {
        modelConfidence = confArg.toDouble();
      } else if (confArg is String) {
        // just in case backend returns as string
        modelConfidence = double.tryParse(confArg);
      }
    }

    // 🔹 Decide which disease key to use
    if (rawLabelFromModel != null) {
      if (diseaseInfo.containsKey(rawLabelFromModel)) {
        predictionKey = rawLabelFromModel!;
      } else {
        // label came from model but not in our five classes
        predictionKey = 'Unknown / Not in trained classes';
      }
    }

    final Map<String, String> info =
        diseaseInfo[predictionKey] ?? diseaseInfo['Healthy Nail']!;
    final String displayName = info['displayName'] ?? predictionKey;
    final String? color = info['color'];
    final String? texture = info['texture'];
    final String? shape = info['shape'] ?? info['pattern'];
    final String description = info['description'] ?? '';
    final String risk = info['risk'] ?? '—';

    // 🔹 Confidence text: use model value if available, else fallback from map
    String confidenceText;
    if (modelConfidence != null) {
      confidenceText = '${(modelConfidence * 100).toStringAsFixed(1)}%';
    } else {
      confidenceText = info['confidence'] ?? '—';
    }

    final String fileName = imagePath != null
        ? imagePath.split(Platform.pathSeparator).last
        : 'nail_photo.jpeg';

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Upload Image',
          style: TextStyle(
            color: Color(0xFF0E0E0E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // "Uploaded" label + filename box
            const Text(
              'Uploaded',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF676767),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF11AF22),
                  width: 1,
                ),
              ),
              child: Text(
                fileName,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF0E0E0E),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Second "Uploaded" label + image preview
            const Text(
              'Uploaded',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF676767),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0x4C384EB7),
                  width: 1,
                ),
              ),
              height: 190,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              child: imagePath != null
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              '$fileName uploaded successfully',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF006737),
              ),
            ),

            const SizedBox(height: 18),

            // --- Prediction card ---
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    offset: Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Prediction line
                  Text(
                    'Prediction: $displayName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Features
                  if (color != null || texture != null || shape != null)
                    Text(
                      [
                        if (color != null) 'Color: $color',
                        if (texture != null) 'Texture: $texture',
                        if (shape != null) 'Shape: $shape',
                      ].join('\n'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Confidence & risk row
                  Row(
                    children: [
                      Expanded(
                        child: _pill(
                          label: 'Confidence',
                          value: confidenceText,
                          bgColor: const Color(0xFFE3F2FD),
                          textColor: const Color(0xFF1E88E5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _pill(
                          label: 'Risk level',
                          value: risk,
                          bgColor: risk == 'High'
                              ? const Color(0xFFFFEBEE)
                              : (risk == 'Moderate'
                                  ? const Color(0xFFFFF8E1)
                                  : risk == 'Unknown'
                                      ? const Color(0xFFE0E0E0)
                                      : const Color(0xFFE8F5E9)),
                          textColor: risk == 'High'
                              ? const Color(0xFFC62828)
                              : (risk == 'Moderate'
                                  ? const Color(0xFFEF6C00)
                                  : risk == 'Unknown'
                                      ? const Color(0xFF424242)
                                      : const Color(0xFF2E7D32)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description card (light blue bubble)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFC0E4FF),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$displayName ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // View full results button (stub)
            SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B87D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  // To be wired later to a detailed report screen
                },
                child: const Text(
                  'View full results here',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

  // Small helper pill widget for confidence & risk
  static Widget _pill({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}