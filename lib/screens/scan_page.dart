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

  /// Tracks popup visibility
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
  // 🔹 Upload to Supabase `history` bucket and return public URL
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

      await supabase.storage
          .from('history')
          .uploadBinary(
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
  // 🔥 Call Backend API + Upload Image + Save to Firestore
  // =====================================================================
  Future<void> _runPrediction(File file) async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final result = await ApiService.predictNailDisease(file);

      final String label = result['label'] as String;
      final double confidence = (result['confidence'] as num).toDouble();

      final String? imageUrl = await _uploadToSupabase(file.path);

      await _saveScanToHistory(
        label: label,
        confidence: confidence,
        imageUrl: imageUrl,
      );

      _showResultPopup(label: label, confidence: confidence);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Prediction Failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // =====================================================================
  // ⭐ NEW RISK ALGORITHM
  // =====================================================================
  String _riskForLabel(String label, double conf) {
    // 🔴 HIGH-SEVERITY DISEASES
    if (label == 'Acral Lentiginous Melanoma' || label == 'Bluish Nail') {
      if (conf >= 0.85) return 'High';
      if (conf >= 0.60) return 'Moderate';
      return 'Low–Moderate';
    }

    // 🟠 MODERATE-SEVERITY DISEASES
    if (label == 'Clubbing' ||
        label == 'Onychogryphosis' ||
        label == 'Pitting' ||
        label == 'Beau’s Lines' ||
        label == 'Koilonychia') {
      if (conf >= 0.85) return 'Moderate–High';
      if (conf >= 0.60) return 'Moderate';
      return 'Low';
    }

    // 🟢 LOW-SEVERITY (HEALTHY)
    if (label == 'Healthy Nail') return 'Low';

    return 'Unknown';
  }

  // =====================================================================
  // ⭐ Save history (scan)
  // =====================================================================
  Future<void> _saveScanToHistory({
    required String label,
    required double confidence,
    required String? imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String risk = _riskForLabel(label, confidence);

    final historyRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('history');

    await historyRef.add({
      'predictionLabel': label,
      'conditionKey': label,
      'confidence': confidence,
      'risk': risk,
      'imageUrl': imageUrl,
      'imagePath': null,
      'source': 'scan',
      'timestamp': Timestamp.now(),
    });

    debugPrint('✅ History saved for camera scan.');
  }

  // =====================================================================
  // 🛑 Popup Window
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white, // ✅ make button text white
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =====================================================================
  // 📌 PHOTO GUIDELINES POPUP (Auto-Show)
  // =====================================================================
  void _showPhotoGuidelines() {
    if (_isPopupShown) return;

    setState(() => _isPopupShown = true);

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
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(
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
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
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
                      // HEADER ---------------------------
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
                                    color: Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
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

                      // SCROLL AREA -----------------------
                      const Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 6),
                              _GuidelineRow(
                                icon: Icons.wb_sunny_outlined,
                                spans: [
                                  TextSpan(
                                    text: 'Use natural light near a window; ',
                                    style: TextStyle(color: Color(0xFF4E5A65)),
                                  ),
                                  TextSpan(
                                    text: 'avoid colored lights.',
                                    style: TextStyle(color: Color(0xFFDC2626)),
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
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '; no harsh reflections or glare.',
                                    style: TextStyle(color: Color(0xFF4E5A65)),
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
                                    style: TextStyle(color: Color(0xFF4E5A65)),
                                  ),
                                  TextSpan(
                                    text: '70–80%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' of the frame.',
                                    style: TextStyle(color: Color(0xFF4E5A65)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              _GuidelineRow(
                                icon: Icons.brush_outlined,
                                spans: [
                                  TextSpan(
                                    text: 'Remove polish; ',
                                    style: TextStyle(color: Color(0xFF4E5A65)),
                                  ),
                                  TextSpan(
                                    text: 'wipe the nail dry/clean.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
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
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'for 1–2 seconds; lock autofocus.',
                                    style: TextStyle(color: Color(0xFF4E5A65)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              _GuidelineRow(
                                icon: Icons.layers_outlined,
                                spans: [
                                  TextSpan(
                                    text: 'Use a ',
                                    style: TextStyle(color: Color(0xFF4E5A65)),
                                  ),
                                  TextSpan(
                                    text: 'plain, non-reflective background',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' (paper/towel).',
                                    style: TextStyle(color: Color(0xFF4E5A65)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Example photo',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                child: SizedBox(
                                  height: 120,
                                  width: double.infinity,
                                  child: Image(
                                    image: AssetImage(
                                      'assets/images/sampleimage.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Got it!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // ✅ make button text white
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
  // ⭐ UI (inspo-style)  + pinned footer
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // AUTO SHOW GUIDELINES POPUP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isPopupShown) _showPhotoGuidelines();
    });

    final frameWidth = w * 0.78;
    final frameHeight = frameWidth * 1.08;

    // ⭐ Footer bar widget (same design as before)
    final Widget footerBar = GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/learnmore'),
      child: Container(
        width: double.infinity,
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
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
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
    );

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bgg.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 MAIN CONTENT
          SafeArea(
            child: Column(
              children: [
                // top bar with close
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      color: Colors.black87,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/dashboard'),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                const Text(
                  "Scan your Nail",
                  style: TextStyle(
                    color: Color(0xFF001372),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Align your nail within the frame",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 24),

                // =================== SCAN FRAME ===================
                SizedBox(
                  width: frameWidth,
                  height: frameHeight,
                  child: Stack(
                    children: [
                      // photo preview (behind frame)
                      if (_capturedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.file(
                            File(_capturedImage!.path),
                            width: frameWidth,
                            height: frameHeight,
                            fit: BoxFit.cover,
                          ),
                        ),

                      // Corners
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _cornerBlack(),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Transform.scale(
                          scaleX: -1,
                          child: _cornerBlack(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Transform.scale(
                          scaleY: -1,
                          child: _cornerBlack(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Transform.scale(
                          scaleX: -1,
                          scaleY: -1,
                          child: _cornerBlack(),
                        ),
                      ),

                      // Top center bar
                      Positioned(
                        top: 0,
                        left: (frameWidth - 70) / 2,
                        child: _strokeHorizontal(),
                      ),
                      // Bottom center bar
                      Positioned(
                        bottom: 0,
                        left: (frameWidth - 70) / 2,
                        child: _strokeHorizontal(),
                      ),
                      // Left middle bar
                      Positioned(
                        left: 0,
                        top: (frameHeight - 70) / 2,
                        child: _strokeVertical(),
                      ),
                      // Right middle bar
                      Positioned(
                        right: 0,
                        top: (frameHeight - 70) / 2,
                        child: _strokeVertical(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Upload button
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/upload'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF3B70B9),
                        width: 1.3,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
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
                        Icon(
                          Icons.upload,
                          size: 18,
                          color: Color(0xFF001372),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Camera button
                GestureDetector(
                  onTap: _loading ? null : _captureImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        width: 3,
                        color: const Color(0xFF3B70B9),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF2F56B8),
                              Color(0xFF0A1C72),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 90), // space so not covered by footer
              ],
            ),
          ),

          // ⭐ PINNED BOTTOM BAR (SAGAD)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: footerBar,
          ),

          // ⭐ LOADING OVERLAY WHILE API IS RUNNING
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Analyzing scan...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // 🔹 Frame helpers (corners + strokes)
  // -----------------------------------------------------------------------
  Widget _cornerBlack() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _CornerPainter(),
      ),
    );
  }

  Widget _strokeHorizontal() {
    return Container(
      width: 70,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _strokeVertical() {
    return Container(
      width: 5,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 🎨 Custom painter for the L-shaped corner
// ---------------------------------------------------------------------------
class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // horizontal line (top)
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width * 0.7, 0),
      paint,
    );

    // vertical line (left)
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.height * 0.7),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// 📚 Guideline Row Widget
// ---------------------------------------------------------------------------
class _GuidelineRow extends StatelessWidget {
  final IconData icon;
  final List<TextSpan> spans;

  const _GuidelineRow({required this.icon, required this.spans});

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
          child: RichText(text: TextSpan(children: spans)),
        ),
      ],
    );
  }
}

