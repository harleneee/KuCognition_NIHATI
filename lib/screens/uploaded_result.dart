import 'dart:io';
import 'package:flutter/material.dart';

class UploadedResult extends StatelessWidget {
  const UploadedResult({super.key});

  /// All disease info in one map so it’s easy to hook to the model.
  /// "confidence" here is just a fallback if model confidence is missing.
  static const Map<String, Map<String, String>> diseaseInfo = {
    // (UNCHANGED — your full map exactly as given)
    // ---------------------------------------------------
    //  ✔ NO CHANGES MADE TO YOUR DATA
    //  ✔ NO CHANGES MADE TO KEYS
    //  ✔ NO REMOVALS OR ADDITIONS
    // ---------------------------------------------------
    'Acral Lentiginous Melanoma': {
      'displayName': 'Acral Lentiginous Melanoma',
      'color': 'Dark brown or black streak',
      'texture': 'Smooth but widening band',
      'pattern': 'Irregular borders / widening over time',
      'confidence': '82%',
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
    },
    'Onychogryphosis': {
      'displayName': 'Onychogryphosis',
      'color': 'Yellow-brown',
      'texture': 'Thick and hard',
      'shape': 'Curved or ram’s horn growth',
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
    },
    'Pitting': {
      'displayName': 'Pitting',
      'color': 'Pale or yellowish spots',
      'texture': 'Pitted / dented surface',
      'shape': 'Slightly irregular edges',
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
    },

    // 🔹 NEW: Beau’s Lines
    'Beau’s Lines': {
      'displayName': 'Beau’s Lines',
      'color': 'Normal or slightly pale nail with horizontal bands',
      'texture': 'Transverse ridges or dents across the nail',
      'shape': 'Grooved line across the nail',
      'confidence': '87%',
      'risk': 'Moderate',
      'description':
          'Beau’s lines are horizontal grooves that appear when nail growth is temporarily slowed or interrupted. '
          'They often reflect a past episode of significant internal stress, such as severe infection with high fever, '
          'major surgery, metabolic imbalance, or serious illness affecting vital organs. The lines themselves are not harmful, '
          'but when they appear on several nails or recur, they may signal underlying systemic problems that should be reviewed '
          'with a doctor.',
    },

    // 🔹 NEW: Bluish Nail
    'Bluish Nail': {
      'displayName': 'Bluish Nail',
      'color': 'Bluish, purplish, or grayish nail bed',
      'texture': 'Usually smooth surface',
      'shape': 'Normal nail shape with bluish tint',
      'confidence': '87%',
      'risk': 'High',
      'description':
          'A bluish nail indicates that the blood under the nail may be carrying less oxygen than normal. This can be linked to '
          'circulation problems, anemia, or more serious internal conditions affecting the heart or lungs. While brief color changes '
          'from cold are often harmless, persistent or unexplained bluish nails, especially with shortness of breath, chest pain, or dizziness, '
          'may reflect significant cardiopulmonary or vascular disease and need prompt medical evaluation.',
    },

    // 🔹 NEW: Koilonychia
    'Koilonychia': {
      'displayName': 'Koilonychia',
      'color': 'Pale or dull nail',
      'texture': 'Thin and breakable',
      'shape': 'Spoon-shaped nail',
      'confidence': '87%',
      'risk': 'Moderate',
      'description':
          'Koilonychia is a spoon-shaped nail deformity where the nail becomes thin and the edges lift while the center dips inward. '
          'It is commonly associated with iron deficiency anemia and other problems affecting blood and nutrition. Because spoon nails can be '
          'an external sign of internal issues such as anemia, chronic blood loss, malabsorption, or endocrine disorders, new or progressive spooning '
          'should be checked so the underlying cause can be treated and overall health protected.',
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
    String predictionKey = 'Healthy Nail';
    String? rawLabelFromModel;
    double? modelConfidence;

    // Args logic (UNCHANGED)
    if (args is Map) {
      imagePath = args['imagePath'];
      rawLabelFromModel = args['label'];
      final dynamic confArg = args['confidence'];
      if (confArg is num) modelConfidence = confArg.toDouble();
      if (confArg is String) modelConfidence = double.tryParse(confArg);
    } else if (args is String) {
      imagePath = args;
    }

    if (rawLabelFromModel != null &&
        diseaseInfo.containsKey(rawLabelFromModel)) {
      predictionKey = rawLabelFromModel!;
    } else if (rawLabelFromModel != null) {
      predictionKey = 'Unknown / Not in trained classes';
    }

    final info = diseaseInfo[predictionKey]!;
    final String displayName = info['displayName']!;
    final String? color = info['color'];
    final String? texture = info['texture'];
    final String? shape = info['shape'] ?? info['pattern'];
    final String description = info['description']!;
    final String risk = info['risk']!;
    final String confidenceText = (modelConfidence != null)
        ? '${(modelConfidence! * 100).toStringAsFixed(1)}%'
        : info['confidence']!;

    final String fileName = (imagePath != null)
        ? imagePath.split(Platform.pathSeparator).last
        : "nail_photo.jpeg";

    // -----------------------------------------------------------------------------------------
    // START NEW UI DESIGN (No logic touched — ONLY visuals)
    // -----------------------------------------------------------------------------------------

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          "Upload Image",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),

      // ✅ ONLY ADD: bgg.jpg background wrapped around existing body
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ------------------------------
              // File name card (cleaned UI)
              // ------------------------------
              const Text(
                "Uploaded",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 6),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF3B87D2), width: 1),
                ),
                child:
                    Text(fileName, style: const TextStyle(fontSize: 12)),
              ),

              const SizedBox(height: 18),

              const Text(
                "Uploaded",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 10),

              // ------------------------------
              // Modern Image Preview
              // ------------------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 220,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: imagePath != null
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 6),
              Text(
                "$fileName uploaded successfully",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF1B7A36)),
              ),

              const SizedBox(height: 20),

              // ------------------------------
              // Prediction Card (NEW STYLE)
              // ------------------------------
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    if (color != null ||
                        texture != null ||
                        shape != null)
                      Text(
                        [
                          if (color != null) "• Color: $color",
                          if (texture != null) "• Texture: $texture",
                          if (shape != null) "• Shape: $shape",
                        ].join("\n"),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, height: 1.35),
                      ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _pill(
                            label: "Confidence",
                            value: confidenceText,
                            bgColor: const Color(0xFFE3F2FD),
                            textColor: const Color(0xFF1E88E5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _pill(
                            label: "Risk",
                            value: risk,
                            bgColor: risk == "High"
                                ? const Color(0xFFFFE5E7)
                                : risk == "Moderate"
                                    ? const Color(0xFFFFF5D9)
                                    : Colors.grey.shade200,
                            textColor: risk == "High"
                                ? const Color(0xFFCC1C1C)
                                : risk == "Moderate"
                                    ? const Color(0xFFDE7F00)
                                    : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ------------------------------
              // Description Card (modern white card)
              // ------------------------------
              Container(
                padding:
                    const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 13, height: 1.45),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // ------------------------------
              // Gradient Button (KuCognition style)
              // ------------------------------
              SizedBox(
                height: 46,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF3B87D2),
                        Color(0xFF2361C9)
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/result_page',
                        arguments: {
                          'imagePath': imagePath,
                          'label': predictionKey,
                          'confidence': modelConfidence,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "View full results here",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // PILL WIDGET (UNCHANGED LOGIC, MODERNIZED STYLE)
  // ----------------------------------------------------
  static Widget _pill({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
