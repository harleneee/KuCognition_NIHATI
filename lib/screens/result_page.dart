import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  ///  Unified Disease Database with Detailed Analysis
  static const Map<String, Map<String, String>> diseaseInfo = {
    'Acral Lentiginous Melanoma': {
      'displayName': 'Acral Lentiginous Melanoma',
      'confidence': '82%',
      'risk': 'High',
      'scannedColor':
          'The nail displays a dark brown to black pigment band that may vary in intensity, showing uneven or irregular shading as it extends from the base toward the tip. In some areas, the streak may deepen in color or appear darker than the surrounding nail plate.',
      'scannedTexture':
          'The nail surface may show slight irregularities such as subtle ridging, lifting, or separation from the nail bed over time. The pigmented band may gradually widen, and the growth pattern may appear distorted as the pigmentation spreads or becomes more defined.',
      'underlyingIntro':
          'The presence of a dark, persistent, or widening pigmentation band may indicate an acral pigment abnormality associated with melanocyte activity changes. While the streak appears on the nail surface, deeper internal factors may influence pigment cell behavior or tissue response. These changes may correlate with:',
      'underlyingMetabolic':
          'Metabolic / circulatory: irregular blood flow or oxidative stress affecting pigment distribution and nail-bed integrity.',
      'underlyingImmune':
          'Immune function: altered immune activity that may interfere with melanocyte behavior or trigger abnormal pigment reactions.',
      'underlyingNutrient':
          'Nutrient / endocrine: hormonal fluctuations or nutritional imbalances that can influence pigmentation patterns and nail growth dynamics.',
      'underlyingOrgan':
          'Organ health: underlying systemic inflammation or organ stress that may reflect changes in cell renewal or tissue stability.',
      'nextSteps':
          '• Professional pigment assessment: schedule a dermatology consultation for dermoscopic evaluation of the pigment band to determine whether deeper testing or biopsy is needed.\n'
          '• Internal health screening: discuss recent nail changes with a general physician and consider screening for metabolic stress, immune irregularities, or endocrine imbalance.',
      'whyMatters':
          'Persistent dark streaks under the nail can indicate abnormal pigment activity that may be influenced by deeper internal factors. While the streak itself appears externally, changes that do not improve or continue to widen may reflect immune or metabolic stress affecting how the cells beneath the nail behave. Early evaluation is important because nail pigmentation can sometimes signal significant internal irregularities that require thorough medical assessment to prevent serious complications.',
    },
    'Clubbing': {
      'displayName': 'Clubbing',
      'confidence': '88%',
      'risk': 'Moderate',
      'scannedColor':
          'The nail maintains a generally normal color but may appear slightly reddish or flushed, reflecting increased blood flow to the fingertips. The overall tone is typically uniform and may appear shinier than usual.',
      'scannedTexture':
          'The nail bed feels soft, spongy, or pliable when pressed, and the nails curve downward as the fingertip becomes rounded and enlarged. Over time, the growth pattern becomes more pronounced as the angle between the nail and the cuticle increases.',
      'underlyingIntro':
          'Clubbing is often linked to long-term internal health changes and may correlate with digital structural changes associated with circulatory and oxygen imbalances. These characteristics may be associated with deeper systemic concerns, including:',
      'underlyingMetabolic':
          'Metabolic / circulatory: reduced oxygen levels, chronic circulatory strain, or conditions impacting blood flow to extremities.',
      'underlyingImmune':
          'Immune function: chronic inflammation or immune-mediated disorders affecting tissues around the nail.',
      'underlyingNutrient':
          'Nutrient / endocrine: thyroid imbalance, malabsorption, or metabolic disruption influencing tissue growth.',
      'underlyingOrgan':
          'Organ health: potential involvement of heart, lung, or liver function changes that may affect blood oxygen distribution.',
      'nextSteps':
          '• Functional assessment: consult with a healthcare provider to evaluate oxygen levels, respiratory function, and circulatory efficiency.\n'
          '• Organ function screening: diagnostic tests may include heart evaluation, lung imaging, or liver function assessment to identify underlying contributors.',
      'whyMatters':
          'Clubbing is rarely a surface-level issue and often reflects long-standing changes inside the body. The rounded fingertip and increased curvature of the nail can be the body’s response to reduced oxygen levels, circulation problems, or chronic inflammation. Identifying this early is crucial because it may signal hidden issues in the heart, lungs, or liver that need further examination before more serious symptoms appear.',
    },
    'Healthy Nail': {
      'displayName': 'Healthy Nail',
      'confidence': '94%',
      'risk': 'Low',
      'scannedColor':
          'The nail exhibits a consistent, evenly distributed pinkish tone across the entire nail plate, indicating adequate oxygen supply and balanced blood circulation under the nail bed.',
      'scannedTexture':
          'The surface appears smooth, firm, and free from pits, ridges, or thickening, with the nail growing steadily at a normal rate. The nail remains firmly attached to the nail bed and maintains an even curve and thickness throughout.',
      'underlyingIntro':
          'A healthy nail suggests balanced internal function across multiple systems:',
      'underlyingMetabolic':
          'Metabolic / circulatory: strong oxygen delivery and stable blood flow to the nail bed.',
      'underlyingImmune':
          'Immune function: no visible signs of chronic inflammation or immune overactivity.',
      'underlyingNutrient':
          'Nutrient / endocrine: adequate nutrient absorption and proper hormonal regulation supporting nail growth.',
      'underlyingOrgan':
          'Organ health: no outward indications of liver, kidney, or cardiovascular stress.',
      'nextSteps':
          '• Maintain good nail hygiene and moisture.\n'
          '• Avoid frequent trauma or harsh chemicals.\n'
          '• Monitor regularly for new streaks, discoloration, or texture changes.\n'
          '• Support internal health with a balanced diet and hydration.',
      'whyMatters':
          'A stable, healthy nail appearance suggests that major internal systems such as circulation, nutrition, and immune function are operating within normal ranges. While it does not rule out all medical conditions, the absence of visible abnormalities indicates that the body is maintaining balanced internal health. This makes it easier to notice and respond quickly to future changes that may reflect early signs of internal imbalance.',
    },
    'Onychogryphosis': {
      'displayName': 'Onychogryphosis',
      'confidence': '90%',
      'risk': 'Moderate',
      'scannedColor':
          'The nail shows a yellowish to brown discoloration, often becoming opaque as keratin builds up and thickens. The uneven coloration may intensify toward the tip where the nail is most curved or distorted.',
      'scannedTexture':
          'The nail becomes markedly thickened, hardened, and irregular, developing a claw-like or horn-shaped curvature. Growth may be twisted or deviated, and the surface often appears rough with pronounced ridges.',
      'underlyingIntro':
          'These nail changes may signal hypertrophic nail changes associated with circulatory and metabolic factors. Possible internal contributors include:',
      'underlyingMetabolic':
          'Metabolic / circulatory: poor blood flow, vascular insufficiency, or glucose dysregulation affecting nail nutrition.',
      'underlyingImmune':
          'Immune function: inflammatory responses contributing to abnormal keratin buildup.',
      'underlyingNutrient':
          'Nutrient / endocrine: vitamin deficiencies or endocrine disorders altering nail growth patterns.',
      'underlyingOrgan':
          'Organ health: chronic stress on the body or age-related decline impacting nail regeneration.',
      'nextSteps':
          '• Clinical nail management: seek assistance from a dermatologist or podiatrist to manage nail thickening and prevent secondary complications.\n'
          '• Internal health assessment: screen for circulation problems, glucose imbalance, or metabolic conditions that may influence nail growth.',
      'whyMatters':
          'Severely thickened and distorted nails can be more than a cosmetic problem. When this condition repeatedly develops or worsens, it may signal internal circulatory issues, metabolic imbalance, or underlying conditions that affect tissue repair. Persistent thickening is sometimes associated with reduced blood flow or systemic stress, making it important to investigate internal contributors to prevent discomfort, infection, or further complications.',
    },
    'Pitting': {
      'displayName': 'Nail Pitting',
      'confidence': '87%',
      'risk': 'Moderate',
      'scannedColor':
          'The nail may appear normal or slightly pale with small depressions across the surface. The uneven reflection can create subtle tonal variations.',
      'scannedTexture':
          'The nail surface shows numerous tiny pits that create a rough, irregular texture. Growth may appear slightly brittle or uneven due to disruptions in nail matrix formation.',
      'underlyingIntro':
          'These features may reflect nail matrix irregularities associated with immune and inflammatory activity. Systemic associations include:',
      'underlyingMetabolic':
          'Metabolic / circulatory: circulatory inefficiencies or oxidative stress affecting nail formation.',
      'underlyingImmune':
          'Immune function: immune overactivity or chronic inflammatory responses influencing nail matrix behavior.',
      'underlyingNutrient':
          'Nutrient / endocrine: deficiencies in vitamins or hormonal imbalances impacting tissue regeneration.',
      'underlyingOrgan':
          'Organ health: internal inflammation or immune-related organ stress contributing to nail irregularities.',
      'nextSteps':
          '• Skin and nail evaluation: a dermatologist can assess whether inflammatory or immune-related conditions are present.\n'
          '• Internal health screening: blood tests may help identify autoimmune tendencies, nutrient deficiencies, or metabolic irregularities.',
      'whyMatters':
          'Nail pitting often reflects disruptions in the nail matrix, which can be influenced by immune or inflammatory activity within the body. When pits repeatedly appear or spread, it may signal internal inflammation or autoimmune processes that need evaluation. Early attention is valuable because nail pitting can be a visible indicator of deeper systemic conditions that benefit from timely medical assessment and management.',
    },
    'Unknown / Not in trained classes': {
      'displayName': 'Unknown / Not in trained classes',
      'confidence': '—',
      'risk': 'Unknown',
      'scannedColor':
          'The nail appearance does not clearly match any of the trained categories. Color and pattern may vary and can be influenced by lighting, image quality, or unrelated surface changes.',
      'scannedTexture':
          'Texture, thickness, and growth pattern are not clearly aligned with the known reference conditions. The nail may appear normal, mildly irregular, or affected by factors outside the model’s training data.',
      'underlyingIntro':
          'The current scan does not match any of the five specific nail presentations the model was trained on. This result does not confirm that the nail is healthy or unhealthy and may be influenced by image limitations or an unrecognized pattern.',
      'underlyingMetabolic':
          'Metabolic / circulatory: internal contributors cannot be determined from this scan alone.',
      'underlyingImmune':
          'Immune function: this result does not rule out or confirm inflammatory or immune-related conditions.',
      'underlyingNutrient':
          'Nutrient / endocrine: no specific pattern is identified to link directly to nutritional or hormonal factors.',
      'underlyingOrgan':
          'Organ health: no specific organ-related pattern is recognized from this image.',
      'nextSteps':
          '• Retake the photo in good, even lighting, centered on the nail with clear focus.\n'
          '• If the nail is painful, rapidly changing, bleeding, or appears infected, consult a healthcare professional for in-person evaluation.',
      'whyMatters':
          'An “unknown” result means the pattern falls outside the model’s trained categories, not that the nail is normal or abnormal. When visual changes are concerning or persistent, an in-person medical assessment is the safest way to understand whether deeper internal factors may be involved.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final Object? routeArgs = ModalRoute.of(context)?.settings.arguments;

    String? imagePath;
    String? imageUrl; // ✅ NEW
    String rawLabel = "Unknown / Not in trained classes";
    double? confidence;

    if (routeArgs is Map) {
      final map = routeArgs as Map;

      // local image (from scan/upload)
      final dynamic imgArg = map['imagePath'];
      if (imgArg is String && imgArg.isNotEmpty) {
        imagePath = imgArg;
      }

      // network image (from history)
      final dynamic imgUrlArg = map['imageUrl'];
      if (imgUrlArg is String && imgUrlArg.isNotEmpty) {
        imageUrl = imgUrlArg;
      }

      // label can come as 'label', 'conditionKey', or 'predictionLabel'
      final dynamic labelArg =
          map['label'] ?? map['conditionKey'] ?? map['predictionLabel'];
      if (labelArg is String && labelArg.isNotEmpty) {
        rawLabel = labelArg;
      }

      // confidence can be num or String
      final dynamic confArg = map['confidence'];
      if (confArg is num) {
        confidence = confArg.toDouble();
      } else if (confArg is String) {
        confidence = double.tryParse(confArg);
      }
    }

    final info =
        diseaseInfo[rawLabel] ?? diseaseInfo['Unknown / Not in trained classes']!;
    final label = info['displayName']!;
    final risk = info['risk'] ?? 'Unknown';
    final scannedColor = info['scannedColor'];
    final scannedTexture = info['scannedTexture'];
    final underlyingIntro = info['underlyingIntro'];
    final underlyingMetabolic = info['underlyingMetabolic'];
    final underlyingImmune = info['underlyingImmune'];
    final underlyingNutrient = info['underlyingNutrient'];
    final underlyingOrgan = info['underlyingOrgan'];
    final nextSteps = info['nextSteps'];
    final whyMatters = info['whyMatters'];

    final confString = confidence != null
        ? "${(confidence * 100).toStringAsFixed(1)}%"
        : info['confidence'] ?? "—";

    Color riskColor = Colors.grey;
    if (risk == "High") riskColor = Colors.red.shade700;
    if (risk == "Moderate") riskColor = Colors.orange.shade700;
    if (risk == "Low") riskColor = Colors.green.shade700;

    void goToDashboard(BuildContext ctx) {
      Navigator.pushNamedAndRemoveUntil(
        ctx,
        '/dashboard',
        (route) => false,
      );
    }

    // ✅ Decide which image widget to show
    Widget imageWidget;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
      );
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      imageWidget = Image.file(
        File(imagePath!),
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = const Center(
        child: Icon(Icons.image, size: 50),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
          onPressed: () => goToDashboard(context),
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
                child: imageWidget,
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

            /// SCANNED NAIL DESCRIPTION
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("Scanned Nail Description"),
                  const SizedBox(height: 10),
                  if (scannedColor != null && scannedColor.isNotEmpty)
                    _bulletBlock("Color", scannedColor),
                  if (scannedTexture != null && scannedTexture.isNotEmpty)
                    const SizedBox(height: 8),
                  if (scannedTexture != null && scannedTexture.isNotEmpty)
                    _bulletBlock("Texture & Growth", scannedTexture),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// POSSIBLE SIGN OF UNDERLYING CONDITION
            _infoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header("Possible Sign of Underlying Condition"),
                  const SizedBox(height: 10),
                  if (underlyingIntro != null && underlyingIntro.isNotEmpty)
                    Text(
                      underlyingIntro,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black87,
                        height: 1.45,
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (underlyingMetabolic != null &&
                      underlyingMetabolic.isNotEmpty)
                    _simpleBullet(underlyingMetabolic),
                  if (underlyingImmune != null && underlyingImmune.isNotEmpty)
                    _simpleBullet(underlyingImmune),
                  if (underlyingNutrient != null &&
                      underlyingNutrient.isNotEmpty)
                    _simpleBullet(underlyingNutrient),
                  if (underlyingOrgan != null && underlyingOrgan.isNotEmpty)
                    _simpleBullet(underlyingOrgan),
                ],
              ),
            ),

            const SizedBox(height: 18),

            /// NEXT STEPS & RECOMMENDATIONS
            if (nextSteps != null && nextSteps.isNotEmpty)
              _infoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header("Next Steps & Recommendations"),
                    const SizedBox(height: 10),
                    Text(
                      nextSteps,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            /// WHY THIS MATTERS (blue card)
            if (whyMatters != null && whyMatters.isNotEmpty)
              _infoCard(
                background: const Color(0xFFDCEFFF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header("Why This Matters"),
                    const SizedBox(height: 10),
                    Text(
                      whyMatters,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black87,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 26),

            /// SINGLE ACTION BUTTON → Dashboard
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => goToDashboard(context),
                style: _buttonStyle(primary: const Color(0xFF3B87D2)),
                child: const Text("Done"),
              ),
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

  Widget _bulletBlock(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF001372),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: const TextStyle(
            fontSize: 13.5,
            color: Colors.black87,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _simpleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 13.5),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
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
}
