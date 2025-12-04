import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ⭐ history needs auth + firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Supabase for image storage (match UploadedPage)
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kucognition_app/data/api_service.dart';
import 'package:kucognition_app/data/disease_data.dart';
import 'package:kucognition_app/screens/result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _loading = false;

  // 🔹 for guidelines popup (same pattern as UploadedPage)
  bool _isPopupShown = false;

  // =====================================================================
  // 📸 Capture from Camera
  // =====================================================================
  Future<void> _captureImage() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => _capturedImage = image);

      _runPrediction(File(image.path));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Camera Error: $e")));
    }
  }

  // =====================================================================
  // 🔹 Upload to Supabase `history` bucket and return **public URL**.
  //     (Same pattern as UploadedPage)
  // =====================================================================
  Future<String?> _uploadToSupabase(String filePath) async {
    try {
      final supabase = Supabase.instance.client;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final bytes = await File(filePath).readAsBytes();
      final fileName = filePath.split(Platform.pathSeparator).last;

      final String storageFileName =
          '${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await supabase.storage.from('history').uploadBinary(
            storageFileName,
            bytes,
            fileOptions: const FileOptions(
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl =
          supabase.storage.from('history').getPublicUrl(storageFileName);

      debugPrint('✅ Supabase upload success (scan). URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Supabase upload error (scan): $e');
      return null;
    }
  }

  // =====================================================================
  // 🔥 Call Backend API + UPLOAD IMAGE (Supabase) + SAVE TO HISTORY
  // =====================================================================
  Future<void> _runPrediction(File file) async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final result = await ApiService.predictNailDisease(file);

      // ⭐ make sure types are clean
      final String label = result['label'] as String;
      final double confidence =
          (result['confidence'] as num).toDouble(); // handles int/double

      // 1) Upload image to Supabase (if user logged in)
      final String? imageUrl = await _uploadToSupabase(file.path);

      // 2) Save this scan to Firestore history (same schema as UploadedPage)
      await _saveScanToHistory(
        label: label,
        confidence: confidence,
        imageUrl: imageUrl,
      );

      // 3) Show popup + go to ResultPage
      _showResultPopup(
        label: label,
        confidence: confidence,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Prediction Failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // =====================================================================
  // ⭐ helper to map label -> risk (8 classes)
  // =====================================================================
  String _riskForLabel(String label) {
    switch (label) {
      case 'Acral Lentiginous Melanoma':
      case 'Bluish Nail':
        return 'High';
      case 'Healthy Nail':
        return 'Low';
      case 'Clubbing':
      case 'Onychogryphosis':
      case 'Pitting':
      case 'Beau’s Lines':
      case 'Koilonychia':
        return 'Moderate';
      case 'Unknown / Not in trained classes':
        return 'Unknown';
      default:
        return 'Unknown';
    }
  }

  // =====================================================================
  // ⭐ Write to Firestore history (mirror UploadedPage schema)
  // =====================================================================
  Future<void> _saveScanToHistory({
    required String label,
    required double confidence,
    required String? imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // no logged in user, skip

    final String risk = _riskForLabel(label);

    final historyRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history');

    await historyRef.add({
      'predictionLabel': label, // human-readable label
      'conditionKey': label, // same label as key
      'confidence': confidence, // 0–1 double
      'risk': risk, // High/Moderate/Low/Unknown
      'imageUrl': imageUrl, // Supabase public URL or null
      'imagePath': null, // keep same as UploadedPage
      'source': 'scan', // "scan" vs "upload"
      'timestamp': Timestamp.now(), // match UploadedPage style
    });

    // ✅ INCREMENT totalScans after successful history write
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'totalScans': FieldValue.increment(1)}, SetOptions(merge: true));

    debugPrint('✅ History saved for camera scan & totalScans incremented.');
  }

  // =====================================================================
  // 🛑 Popup window after prediction  (UNCHANGED)
  // =====================================================================
  void _showResultPopup({required String label, required double confidence}) {
    final normalizedLabel = label.toLowerCase().trim();

    final diseaseInfoEntry =
        diseaseDatabase[label] ??
        diseaseDatabase.entries
            .firstWhere(
              (e) => e.key.toLowerCase() == normalizedLabel,
              orElse: () => MapEntry(
                "Unknown",
                DiseaseInfo(
                  name: label,
                  description:
                      "No detailed information is available for this nail condition.",
                  signs: [],
                  image: "",
                ),
              ),
            )
            .value;

    bool isHealthy = normalizedLabel.contains("healthy");

    final headerColor = isHealthy ? Colors.green : Colors.red;
    final headerText = isHealthy ? "HEALTHY RESULT" : "ACTION REQUIRED!";

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          titlePadding: const EdgeInsets.only(top: 15, bottom: 4),
          contentPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          actionsPadding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
          title: Column(
            children: [
              const Text(
                "SCAN COMPLETED",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                headerText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: headerColor,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 6),
                const Text(
                  "Prediction:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF001372),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                // short explanation
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F1FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    diseaseInfoEntry.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResultPage(),
                      settings: RouteSettings(
                        arguments: {
                          'imagePath': _capturedImage?.path,
                          'label': label,
                          'confidence': confidence,
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B87D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "View full results here",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================================
  // 📌 PHOTO GUIDELINES POPUP (same style as UploadedPage)
  // =====================================================================
  void _showPhotoGuidelines() {
    if (_isPopupShown) return; // Avoid showing again

    setState(() {
      _isPopupShown = true;
    });

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Photo guidelines',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        final size = MediaQuery.of(context).size;

        return Center(
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  width: size.width * 0.9,
                  constraints: const BoxConstraints(maxHeight: 600),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEAF5FD),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 20,
                              color: Color(0xFF3B87D2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Best Image Quality Guidelines',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF001372),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Follow these quick tips so KuCognition can analyze your nail as accurately as possible.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF94A3B8),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Small pill / label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF2FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Before you take a photo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3B87D2),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Guidelines list
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          _GuidelineRow(
                            icon: Icons.wb_sunny_outlined,
                            spans: [
                              TextSpan(
                                text: 'Use natural light near a window; ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: 'avoid colored lights.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFDC2626), // red warning
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          _GuidelineRow(
                            icon: Icons.flash_off_outlined,
                            spans: [
                              TextSpan(
                                text: 'Turn off flash',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: '; no harsh reflections or glare.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          _GuidelineRow(
                            icon: Icons.crop_free,
                            spans: [
                              TextSpan(
                                text:
                                    'Keep the nail flat to the camera, filling ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: '70–80%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: ' of the frame.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          _GuidelineRow(
                            icon: Icons.brush_outlined,
                            spans: [
                              TextSpan(
                                text: 'Remove polish; ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: 'wipe the nail dry/clean.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          _GuidelineRow(
                            icon: Icons.center_focus_strong_outlined,
                            spans: [
                              TextSpan(
                                text: 'Hold still ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: 'for 1–2 seconds; lock autofocus.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          _GuidelineRow(
                            icon: Icons.layers_outlined,
                            spans: [
                              TextSpan(
                                text: 'Use a ',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: 'plain, non-reflective background',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: ' (paper/towel).',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4E5A65),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Example photo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 110, // 🔽 was 150 – shorter to avoid overflow
                          child: Image.asset(
                            'assets/images/sampleimage.png', // same path
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B87D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            elevation: 2,
                            shadowColor: Colors.black26,
                          ),
                          child: const Text(
                            'Got it!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================================================
  // ⭐ MAIN UI
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // show guidelines once when page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPhotoGuidelines());

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SafeArea(
        child: Stack(
          children: [
            // EXIT TO DASHBOARD
            Positioned(
              top: 6,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, size: 26),
                onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              ),
            ),

            Column(
              children: [
                const SizedBox(height: 28),

                // TITLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Scan your Nail",
                      style: TextStyle(
                        color: Color(0xFF001372),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset("assets/images/logo.png", height: 26),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "Align your nail within the frame",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 28),

                // SCAN FRAME
                Container(
                  width: w * 0.80,
                  height: w * 1.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF3B87D2), width: 3),
                  ),
                  child: _capturedImage == null
                      ? const SizedBox()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(_capturedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // Upload button
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/upload'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF3B87D2), width: 1.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Upload Image",
                          style: TextStyle(
                            color: Color(0xFF001372),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.upload,
                            color: Color(0xFF001372), size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // CAMERA SCAN BUTTON
                GestureDetector(
                  onTap: _loading ? null : _captureImage,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border:
                          Border.all(width: 3, color: const Color(0xFF3B87D2)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFFBFD9FF), Color(0xFF8EC4FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),
              ],
            ),

            // LEARN MORE FOOTER
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/learnmore'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  color: Colors.black.withOpacity(.85),
                  child: Row(
                    children: [
                      Image.asset(
                        "assets/images/learnmore_icon.png",
                        width: 18,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Explore nail health indicators and their meanings.",
                          style:
                              TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ),
                      const Text(
                        "Learn more",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.lightBlueAccent,
                          decoration: TextDecoration.underline,
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

// Helper for icon + rich text guideline row (same as UploadedPage)
class _GuidelineRow extends StatelessWidget {
  final IconData icon;
  final List<TextSpan> spans;

  const _GuidelineRow({
    required this.icon,
    required this.spans,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF3B87D2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(children: spans),
          ),
        ),
      ],
    );
  }
}
