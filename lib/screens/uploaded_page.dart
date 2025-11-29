import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kucognition_app/data/api_service.dart';

// 🔹 Firebase for auth + Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Supabase for image storage
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadedPage extends StatefulWidget {
  const UploadedPage({super.key});

  @override
  State<UploadedPage> createState() => _UploadedPageState();
}

class _UploadedPageState extends State<UploadedPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isAnalyzing = false;

  // 🔹 Risk mapping based on your spec
  String _mapRisk(String predictionLabel) {
    switch (predictionLabel) {
      case 'Acral Lentiginous Melanoma':
        return 'High';
      case 'Healthy Nail':
        return 'Low';
      case 'Clubbing':
      case 'Onychogryphosis':
      case 'Pitting':
        return 'Moderate';
      case 'Unknown / Not in trained classes':
        return 'Unknown';
      default:
        // Any label not in trained classes → Unknown
        return 'Unknown';
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load image. Please try again.'),
        ),
      );
    }
  }

  /// 🔹 Upload to Supabase `history` bucket and return **public URL**.
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

      debugPrint('✅ Supabase upload success. URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Supabase upload error: $e');
      return null;
    }
  }

  // 🔵 Calls backend, uploads to Supabase, saves history to Firestore, then goes to UploadedResult
  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    String predictionLabel = 'Unknown / Not in trained classes';
    double? confidence;
    String risk = 'Unknown';
    String? imageUrl;

    try {
      // 1️⃣ Call backend API with the selected image
      final result = await ApiService.predictNailDisease(
        File(_selectedImage!.path),
      );

      // 2️⃣ Normalize label & confidence from backend result
      final dynamic rawLabel = result['label'];
      final dynamic rawConfidence = result['confidence'];

      if (rawLabel is String && rawLabel.trim().isNotEmpty) {
        predictionLabel = rawLabel;
      }

      if (rawConfidence is num) {
        confidence = rawConfidence.toDouble();
      } else if (rawConfidence is String) {
        confidence = double.tryParse(rawConfidence);
      }

      risk = _mapRisk(predictionLabel);

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 3️⃣ Upload to Supabase Storage
        imageUrl = await _uploadToSupabase(_selectedImage!.path);

        // 4️⃣ Save scan to Firestore history (even if imageUrl is null, still save)
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('history')
              .add({
            'predictionLabel': predictionLabel, // human-readable label
            'conditionKey': predictionLabel, // using same label as key
            'confidence': confidence, // 0–1 double (nullable)
            'risk': risk, // High/Moderate/Low/Unknown
            'imageUrl': imageUrl, // Supabase public URL or null
            'imagePath': null, // local path not needed in history
            'source': 'upload', // "upload" vs "scan"
            'timestamp': Timestamp.now(), // ✅ match ScanPage style
          });

          debugPrint('✅ History saved for upload scan.');
        } catch (e) {
          debugPrint('❌ Error saving upload history to Firestore: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Scan result could not be saved to history, but you can still view the analysis.',
              ),
            ),
          );
        }
      } else {
        debugPrint('ℹ️ No user logged in, skipping history save.');
      }
    } catch (e) {
      debugPrint('❌ Error during analyze/upload/save: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing image: $e')),
      );
    } finally {
      if (!mounted) return;

      // ✅ Always go to UploadedResult, even if history save fails
      Navigator.pushNamed(
        context,
        '/uploaded_result',
        arguments: {
          'imagePath': _selectedImage!.path,
          'label': predictionLabel,
          'confidence': confidence,
          'risk': risk,
          'imageUrl': imageUrl,
        },
      );

      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  // 🔧 UPDATED: really discards the photo when user confirms
  Future<void> _handleCancel() async {
    if (_selectedImage != null) {
      final bool? shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard photo?'),
          content: const Text(
            'You already selected a photo. Do you want to discard it and go back?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Stay'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Discard',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      );

      if (shouldDiscard == true) {
        setState(() {
          _selectedImage = null;
        });

        Navigator.of(context).maybePop();
      }

      return;
    }

    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload area
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0x4C384EB7),
                        width: 1,
                      ),
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.cloud_upload_outlined,
                                size: 56,
                                color: Color(0xFF5A4EDB),
                              ),
                              SizedBox(height: 24),
                              Text(
                                'Click to upload',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Supported formats: JPEG, JPG, PNG, WEBP',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF676767),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF384EB7),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 260,
                                    child: Image.file(
                                      File(_selectedImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(
                                  Icons.photo_camera_back_outlined,
                                  size: 18,
                                  color: Color(0xFF3B87D2),
                                ),
                                label: const Text(
                                  'Change photo',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF3B87D2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Photo guidelines
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Photo guidelines',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001372),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• Make sure nails are well-lit\n'
                  '• Avoid blurry or shaky images\n'
                  '• Show one hand at a time for best results',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4E5A65),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Analyze button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B87D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  shadowColor: Colors.black26,
                ),
                onPressed: (_selectedImage == null || _isAnalyzing)
                    ? null
                    : _analyzeImage,
                child: _isAnalyzing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Analyzing...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Analyze photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel button (with confirmation if image is selected)
            SizedBox(
              width: double.infinity,
              height: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.black12,
                  elevation: 2,
                ),
                onPressed: _handleCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
