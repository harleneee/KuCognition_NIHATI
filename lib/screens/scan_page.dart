import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kucognition_app/data/api_service.dart';
import 'result_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _loading = false;

  /// Only for camera capture
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
      ).showSnackBar(SnackBar(content: Text("Camera error: $e")));
    }
  }

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
      ).showSnackBar(SnackBar(content: Text("Prediction failed: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showResultPopup({required String label, required double confidence}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Column(
            children: [
              const Text(
                "SCAN COMPLETED",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                "ACTION REQUIRED!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Prediction:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF001372),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(12),
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
                ),
                child: const Text("View full results here"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Scan Your Nails",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),
            const Text(
              "Take a clear and well-lit photo of your nails",
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 22),

            Container(
              width: 300,
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF5A4EDB), width: 3),
                color: Colors.white,
              ),
              child: _capturedImage == null
                  ? const Center(
                      child: Text(
                        "No image captured",
                        style: TextStyle(color: Colors.black38),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(_capturedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const Spacer(),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),

            const SizedBox(height: 10),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔵 Upload image → Go to UploadedPage
                SizedBox(
                  width: 130,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Upload"),
                    onPressed: () {
                      Navigator.pushNamed(context, '/uploaded');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B87D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // 📸 Camera → Take picture & Auto-Analyze
                SizedBox(
                  width: 130,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                    onPressed: _captureImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B87D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}
