import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ added

// ✅ NEW imports for PDF export
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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

    // 🔹 NEW: Beau’s Lines
    'Beau’s Lines': {
      'displayName': 'Beau’s Lines',
      'confidence': '87%',
      'risk': 'Moderate',
      'scannedColor':
          'The nail generally keeps its usual pinkish or slightly pale tone, but one or more horizontal grooves can be seen crossing the width of the nail. When several nails are affected, the lines often sit at a similar level, suggesting they formed during the same period of disrupted nail growth.',
      'scannedTexture':
          'On touch, Beau’s lines feel like shallow ridges or dents that interrupt the smooth surface of the nail. The grooves may be fine or more pronounced and slowly move toward the tip as the nail grows, acting like a marker of a past event that temporarily slowed or paused nail production.',
      'underlyingIntro':
          'The presence of transverse grooves that appear on one or more nails, especially when they align at the same level, may indicate a temporary interruption of nail matrix growth associated with systemic stress episodes. These nail changes may correlate with:',
      'underlyingMetabolic':
          'Metabolic / circulatory: past episodes of high fever, severe infection, major surgery, shock, or significant dehydration that briefly diverted blood flow and nutrients away from nail formation.',
      'underlyingImmune':
          'Immune function: strong inflammatory or autoimmune flares that placed the body under intense stress, causing a short pause in normal cell activity and nail growth.',
      'underlyingNutrient':
          'Nutrient / endocrine: periods of poor nutrition, uncontrolled diabetes, thyroid imbalance, or other metabolic disturbances that interfered with the steady supply of energy and building blocks for healthy nail production.',
      'underlyingOrgan':
          'Organ health: serious or prolonged disease affecting vital organs such as the heart, lungs, liver, or kidneys, as well as intensive medical treatments or toxic exposures that can disrupt tissue renewal and leave visible marks in the nails.',
      'nextSteps':
          '• Professional nail and systemic evaluation: if Beau’s lines appear on several nails, are deep, or keep reappearing, consult a physician or dermatologist. The level and number of lines can help estimate when the body experienced stress.\n'
          '• Internal health screening: discuss recent or past severe illness, fever, hospitalization, weight loss, unusual fatigue, or metabolic disorders. Blood tests may be advised to check for unresolved infections, metabolic imbalance, or organ dysfunction.',
      'whyMatters':
          'Beau’s lines themselves are not harmful, but they function as visible records of internal stress or illness that affected the body in the past. When such changes are widespread or frequently recurring, they may signal that the body is experiencing repeated or ongoing systemic strain. Recognizing this pattern supports earlier investigation of possible internal health problems so that underlying issues can be identified, managed, and prevented from leading to more serious complications.',
    },

    // 🔹 NEW: Bluish Nail
    'Bluish Nail': {
      'displayName': 'Bluish Nail',
      'confidence': '87%',
      'risk': 'High',
      'scannedColor':
          'The nail bed shows a bluish, purplish, or grayish discoloration, either across the entire nail or most prominently near the base. Compared to surrounding skin, the nail looks dusky or oxygen-poor rather than bright pink, and the color may deepen in cool environments.',
      'scannedTexture':
          'The nail plate usually remains smooth and structurally intact, with normal thickness and shape. The main abnormality is the altered color of the nail bed beneath the nail rather than changes in the nail surface itself.',
      'underlyingIntro':
          'The appearance of a persistent bluish or purplish nail bed, especially when not simply due to cold exposure, may indicate a peripheral oxygenation disturbance associated with cardiopulmonary or vascular changes. These nail changes may correlate with:',
      'underlyingMetabolic':
          'Metabolic / circulatory: reduced cardiac output, peripheral artery disease, blood vessel spasm, or other circulatory problems that limit oxygen-rich blood from reaching the fingertips.',
      'underlyingImmune':
          'Immune function: autoimmune or inflammatory diseases affecting blood vessels or the microcirculation that can lead to episodes of decreased blood flow and intermittent bluish discoloration.',
      'underlyingNutrient':
          'Nutrient / endocrine: long-standing anemia, severe nutritional deficiencies, or hormonal disturbances that weaken heart or lung performance and reduce overall oxygen delivery.',
      'underlyingOrgan':
          'Organ health: underlying heart or lung conditions such as chronic lung disease, congenital heart defects, heart failure, or pulmonary hypertension that cause persistently low oxygen levels, with bluish nails serving as an external sign.',
      'nextSteps':
          '• Cardiopulmonary and vascular evaluation: persistent or unexplained bluish nails should be discussed with a healthcare provider. Assessment of heart and lung function, oxygen saturation, and circulation can help determine whether systemic oxygenation problems are present.\n'
          '• Internal health screening: report symptoms such as shortness of breath, chest pain, dizziness, fainting, or long-standing fatigue, as well as any known heart, lung, blood, or autoimmune disorders, so that targeted testing can be arranged.',
      'whyMatters':
          'Bluish nails are more than a cosmetic concern; they are a visible warning that oxygen delivery or circulation may not be adequate. While brief color changes from cold are often harmless, persistent or symptom-related bluish nails can indicate significant internal problems involving the heart, lungs, blood, or blood vessels. Detecting these signs and investigating them promptly allows for earlier diagnosis and intervention, which can protect vital organs and reduce the risk of serious complications.',
    },

    // 🔹 NEW: Koilonychia
    'Koilonychia': {
      'displayName': 'Koilonychia',
      'confidence': '87%',
      'risk': 'Moderate',
      'scannedColor':
          'The nail often appears pale, dull, or slightly whitish, especially in the central area, and may lose some of its normal healthy pink hue. The surrounding skin may look normal or somewhat dry depending on overall condition and care.',
      'scannedTexture':
          'Koilonychia is characterized by a thin, soft, and sometimes brittle nail plate that bends upward at the sides, creating a shallow spoon-like depression in the center. The nail may break, chip, or snag more easily than usual and may appear fragile over time.',
      'underlyingIntro':
          'The development of spoon-shaped, thin, and fragile nails, especially when gradual and without clear trauma, may indicate nail-plate remodeling associated with hematologic and nutritional imbalance. These nail changes may correlate with:',
      'underlyingMetabolic':
          'Metabolic / circulatory: iron deficiency anemia and other chronic low-oxygen or low-hemoglobin states that weaken tissue support and alter how the nail matrix forms the plate.',
      'underlyingImmune':
          'Immune function: autoimmune or inflammatory diseases, particularly those affecting the gut or blood vessels, that interfere with nutrient absorption or red blood cell production.',
      'underlyingNutrient':
          'Nutrient / endocrine: poor dietary intake, chronic blood loss, malabsorption syndromes, or thyroid and other endocrine disorders that disturb iron balance or protein metabolism and lead to structurally weaker nails.',
      'underlyingOrgan':
          'Organ health: chronic disorders of the gastrointestinal tract, kidneys, or liver that cause repeated nutrient loss or impaired processing, with koilonychia serving as an outward sign that internal organ function and blood status deserve closer evaluation.',
      'nextSteps':
          '• Hematologic and nutritional evaluation: new or worsening spoon nails should be discussed with a healthcare provider. Blood tests for iron levels, complete blood count, and related markers can detect anemia and related imbalances.\n'
          '• Internal health screening: mention symptoms such as fatigue, weakness, dizziness, shortness of breath, pale skin, unusual cravings, or digestive complaints so that possible internal causes can be identified and treated.',
      'whyMatters':
          'Koilonychia is not just a surface irregularity; it is frequently a visible indicator of iron deficiency or other systemic health problems that may have been progressing quietly over time. Because nails grow slowly, spoon-shaped changes often reflect ongoing internal imbalance. Identifying and treating the underlying cause early supports better blood health, improved energy, and, over time, restoration of healthier nail structure.',
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
          'The current scan does not match any of the specific nail presentations the model was trained on. This result does not confirm that the nail is healthy or unhealthy and may be influenced by image limitations or an unrecognized pattern.',
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

    String riskHint;
    switch (risk) {
      case 'High':
        riskHint = 'Consider prompt medical follow-up.';
        break;
      case 'Moderate':
        riskHint = 'Monitor and discuss with a professional.';
        break;
      case 'Low':
        riskHint = 'Monitor for any new or changing signs.';
        break;
      default:
        riskHint = 'Interpret this result with a professional if unsure.';
    }

    // 1-line summary from underlyingIntro / whyMatters
    String? summaryLine;
    if (underlyingIntro != null && underlyingIntro.isNotEmpty) {
      final firstDot = underlyingIntro.indexOf('.');
      summaryLine =
          firstDot > 0 ? underlyingIntro.substring(0, firstDot + 1) : underlyingIntro;
    } else if (whyMatters != null && whyMatters.isNotEmpty) {
      final firstDot = whyMatters.indexOf('.');
      summaryLine = firstDot > 0 ? whyMatters.substring(0, firstDot + 1) : whyMatters;
    }

    void goToDashboard(BuildContext ctx) {
      Navigator.pushNamedAndRemoveUntil(
        ctx,
        '/dashboard',
        (route) => false,
      );
    }

    // ✅ Decide which image widget to show
    Widget imageWidget;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
      );
    } else if (imagePath != null && imagePath.isNotEmpty) {
      imageWidget = Image.file(
        File(imagePath),
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = const Center(
        child: Icon(Icons.image, size: 50),
      );
    }

    // ✅ PDF download helper (unchanged logic)
    Future<void> _downloadPdf() async {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) => [
            pw.Text(
              'AI Nail Scan Result',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Detected Condition: $label'),
            pw.Text('Confidence: $confString'),
            pw.Text('Risk Level: $risk'),
            pw.SizedBox(height: 16),
            pw.Text(
              'Scanned Nail Description',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            if (scannedColor != null && scannedColor.isNotEmpty) ...[
              pw.Text('• Color',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(scannedColor),
              pw.SizedBox(height: 6),
            ],
            if (scannedTexture != null && scannedTexture.isNotEmpty) ...[
              pw.Text('• Texture & Growth',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(scannedTexture),
              pw.SizedBox(height: 6),
            ],
            pw.SizedBox(height: 14),
            pw.Text(
              'Possible Sign of Underlying Condition',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            if (underlyingIntro != null && underlyingIntro.isNotEmpty)
              pw.Text(underlyingIntro),
            pw.SizedBox(height: 6),
            if (underlyingMetabolic != null && underlyingMetabolic.isNotEmpty)
              pw.Bullet(text: underlyingMetabolic),
            if (underlyingImmune != null && underlyingImmune.isNotEmpty)
              pw.Bullet(text: underlyingImmune),
            if (underlyingNutrient != null && underlyingNutrient.isNotEmpty)
              pw.Bullet(text: underlyingNutrient),
            if (underlyingOrgan != null && underlyingOrgan.isNotEmpty)
              pw.Bullet(text: underlyingOrgan),
            if (nextSteps != null && nextSteps.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text(
                'Next Steps & Recommendations',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(nextSteps),
            ],
            if (whyMatters != null && whyMatters.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text(
                'Why This Matters',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(whyMatters),
            ],
            pw.SizedBox(height: 18),
            pw.Text(
              'This is AI pattern analysis — NOT a medical diagnosis.',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.red,
              ),
            ),
          ],
        ),
      );

      try {
        final bytes = await pdf.save();
        final dir = await getApplicationDocumentsDirectory();
        final file = File(
          '${dir.path}/kucognition_nail_result_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
        await file.writeAsBytes(bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report saved. Opening…'),
          ),
        );

        await OpenFile.open(file.path);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
          ),
        );
      }
    }

    // ✅ dynamic top padding so content starts *below* status bar + AppBar
    final double contentTopPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 8;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
          onPressed: () => goToDashboard(context),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Scan Result",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001372),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "$label • $confString • $risk",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  contentTopPadding, // ✅ use dynamic padding here
                  18,
                  12,
                ),
                child: Column(
                  children: [
                    // IMAGE CARD with overlay label
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(child: imageWidget),
                            Positioned(
                              left: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  "AI Scan Image",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "This is AI pattern analysis — NOT a medical diagnosis.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // HERO SUMMARY CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF001372),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _riskChip(risk, riskColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _confidenceBar(
                                  confidence: confidence,
                                  displayText: confString,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (summaryLine != null && summaryLine.isNotEmpty)
                            Text(
                              summaryLine,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            riskHint,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: riskColor.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // SCANNED NAIL DESCRIPTION
                    _infoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            icon: Icons.search_rounded,
                            label: "Scanned Nail Description",
                          ),
                          const SizedBox(height: 10),
                          if (scannedColor != null && scannedColor.isNotEmpty)
                            _bulletBlock("Color", scannedColor),
                          if (scannedTexture != null &&
                              scannedTexture.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _bulletBlock("Texture & Growth", scannedTexture),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // POSSIBLE SIGN OF UNDERLYING CONDITION
                    _infoCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionHeader(
                            icon: Icons.health_and_safety_rounded,
                            label: "Possible Sign of Underlying Condition",
                          ),
                          const SizedBox(height: 10),
                          if (underlyingIntro != null &&
                              underlyingIntro.isNotEmpty)
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
                          if (underlyingImmune != null &&
                              underlyingImmune.isNotEmpty)
                            _simpleBullet(underlyingImmune),
                          if (underlyingNutrient != null &&
                              underlyingNutrient.isNotEmpty)
                            _simpleBullet(underlyingNutrient),
                          if (underlyingOrgan != null &&
                              underlyingOrgan.isNotEmpty)
                            _simpleBullet(underlyingOrgan),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // NEXT STEPS
                    if (nextSteps != null && nextSteps.isNotEmpty)
                      _infoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              icon: Icons.checklist_rounded,
                              label: "Next Steps & Recommendations",
                            ),
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

                    // WHY THIS MATTERS
                    if (whyMatters != null && whyMatters.isNotEmpty)
                      _infoCard(
                        background: const Color(0xFFDCEFFF),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              icon: Icons.info_rounded,
                              label: "Why This Matters",
                              color: const Color(0xFF001372),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              whyMatters,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Colors.black87,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "If this result worries you, consider sharing this report with a healthcare professional for proper examination.",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF1A3E72),
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    const Text(
                      "Results are for informational support only and should not replace professional medical evaluation.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ✅ STICKY BOTTOM ACTION BAR
            SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 14,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _downloadPdf,
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('Download PDF'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF3B87D2),
                            side: const BorderSide(
                              color: Color(0xFF3B87D2),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 11,
                              horizontal: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => goToDashboard(context),
                            style:
                                _buttonStyle(primary: const Color(0xFF3B87D2)),
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
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

  Widget _sectionHeader({
    required IconData icon,
    required String label,
    Color color = const Color(0xFF001372),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _infoCard({required Widget child, Color background = Colors.white}) {
    return Container(
      width: double.infinity,
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

  static Widget _riskChip(String risk, Color riskColor) {
    IconData icon;
    switch (risk) {
      case 'High':
        icon = Icons.error_rounded;
        break;
      case 'Moderate':
        icon = Icons.warning_amber_rounded;
        break;
      case 'Low':
        icon = Icons.check_circle_rounded;
        break;
      default:
        icon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: riskColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: riskColor),
          const SizedBox(width: 6),
          Text(
            risk,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: riskColor,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _confidenceBar({
    required double? confidence,
    required String displayText,
  }) {
    double? value;
    if (confidence != null) {
      value = confidence.clamp(0.0, 1.0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confidence: $displayText",
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E88E5),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: const Color(0xFFE3F2FD),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF1E88E5)),
          ),
        ),
      ],
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
