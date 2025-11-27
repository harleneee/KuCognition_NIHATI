import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// your API and Disease database
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
  // 🔥 Call Backend API
  // =====================================================================
  Future<void> _runPrediction(File file) async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final result = await ApiService.predictNailDisease(file);

      _showResultPopup(
        label: result['label'],
        confidence: result['confidence'],
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
  // 🛑 Popup window after prediction
  // =====================================================================
  void _showResultPopup({required String label, required double confidence}) {
    final normalizedLabel = label.toLowerCase().trim();

    // Attempt exact key match OR case-insensitive match
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

                // 🔹 Short disease explanation
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFE5F1FF),
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
  // ⭐ MAIN UI
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SafeArea(
        child: Stack(
          children: [
            // ——————— EXIT TO DASHBOARD
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

                // ————————— TITLE
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

                // ————————— SCAN FRAME
                Container(
                  width: w * 0.80,
                  height: w * 1.0,
                  decoration: BoxDecoration(
                    color: Color(0xFFF4F6FA),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF3B87D2), width: 3),
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

                // ————————— Upload button
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/upload'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Color(0xFF3B87D2), width: 1.2),
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
                        Icon(Icons.upload, color: Color(0xFF001372), size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ————————— CAMERA SCAN BUTTON
                GestureDetector(
                  onTap: _loading ? null : _captureImage,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(width: 3, color: Color(0xFF3B87D2)),
                      boxShadow: [
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
                        decoration: BoxDecoration(
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

            // ————————— LEARN MORE FOOTER
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
                          style: TextStyle(fontSize: 13, color: Colors.white70),
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
