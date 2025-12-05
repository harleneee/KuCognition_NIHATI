// uploaded_page.dart
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

class _UploadedPageState extends State<UploadedPage>
    with SingleTickerProviderStateMixin {
  // -----------------------
  // Colors & theme tokens
  // -----------------------
  static const Color _bg = Color(0xFFEAF5FD);
  static const Color _mutedText = Color(0xFF64748B);
  static const Color _darkText = Color(0xFF0E0E0E);
  static const Color _primarySolid = Color(0xFF3B87D2);
  static const Color _primaryDark = Color(0xFF1C4FA3);
  static const Color _card = Color(0xFFF8F7FF);
  static const Color _borderBlue = Color(0xFF384EB7);
  static const Color _accentPurple = Color(0xFF5A4EDB);

  final Gradient _primaryGradient = const LinearGradient(
    colors: [_primarySolid, _primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // -----------------------
  // State + controllers
  // -----------------------
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  bool _isPopupShown = false;

  // Small animation to slightly scale in the preview card
  late final AnimationController _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  // -----------------------
  // Risk mapping (unchanged logic)
  // -----------------------
  String _mapRisk(String label, double? conf) {
    final double c = conf ?? 0.0;

    // High-risk diseases
    if (label == 'Acral Lentiginous Melanoma' || label == 'Bluish Nail') {
      if (c >= 0.85) return 'High';
      if (c >= 0.60) return 'Moderate';
      return 'Low–Moderate';
    }

    // Moderate diseases
    if (label == 'Clubbing' ||
        label == 'Onychogryphosis' ||
        label == 'Pitting' ||
        label == 'Beau’s Lines' ||
        label == 'Koilonychia') {
      if (c >= 0.85) return 'Moderate–High';
      if (c >= 0.60) return 'Moderate';
      return 'Low';
    }

    // Low-risk disease
    if (label == 'Healthy Nail') return 'Low';

    return 'Unknown';
  }

  // -----------------------
  // Image pick + upload + analyze (preserved)
  // -----------------------
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
        _animController.forward(from: 0.0);
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

      final publicUrl = supabase.storage
          .from('history')
          .getPublicUrl(storageFileName);

      debugPrint('✅ Supabase upload success. URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Supabase upload error: $e');
      return null;
    }
  }

  // 🔵 Calls backend → risk → upload → save → go to UploadedResult
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
      // 1️⃣ Call backend API
      final result = await ApiService.predictNailDisease(
        File(_selectedImage!.path),
      );

      // 2️⃣ Process backend outputs
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

      // ⭐ Apply risk logic (severity + confidence)
      risk = _mapRisk(predictionLabel, confidence);

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // 3️⃣ Upload image to Supabase
        imageUrl = await _uploadToSupabase(_selectedImage!.path);

        // 4️⃣ Save history to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('history')
            .add({
              'predictionLabel': predictionLabel,
              'conditionKey': predictionLabel,
              'confidence': confidence,
              'risk': risk,
              'imageUrl': imageUrl,
              'imagePath': null,
              'source': 'upload',
              'timestamp': Timestamp.now(),
            });

        // Increment total scans
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'totalScans': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('❌ Error analyzing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error analyzing image: $e')));
      }
    } finally {
      if (!mounted) return;

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

  // -----------------------
  // Cancel / guidelines (unchanged but styled)
  // -----------------------
  Future<void> handleCancel() async {
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

  // ⭐ Pop-up guidelines (unchanged)
  void _showPhotoGuidelines() {
    if (_isPopupShown) return;

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
            position:
                Tween<Offset>(
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
                  height: size.height * 0.78,
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

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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

                      const Expanded(
                        child: Column(
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
                                    color: Color(0xFF4E5A65),
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: 'avoid colored lights.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFDC2626),
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
                                    color: Color(0xFF4E5A65),
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: '70–80% ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                    height: 1.4,
                                  ),
                                ),
                                TextSpan(
                                  text: 'of the frame.',
                                  style: TextStyle(
                                    fontSize: 13,
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
                                    color: Color(0xFF4E5A65),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                          height: 150,
                          child: Image.asset(
                            'assets/images/sampleimage.png',
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
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

  @override
  void initState() {
    super.initState();
    // show guidelines after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPhotoGuidelines());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // -----------------------
  // UI
  // -----------------------
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top;

    return Scaffold(
      backgroundColor: _bg,
      // AppBar with lighter look
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => handleCancel(),
        ),
        centerTitle: true,
        title: const Text(
          'Upload Image',
          style: TextStyle(
            color: _darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Column(
            children: [
              // Top info card
              Material(
                color: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    // subtle gradient top-left
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: _primaryDark.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.photo_camera,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Upload a clear nail photo',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _darkText,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'We’ll analyze the image for early signs of nail conditions.',
                              style: TextStyle(
                                fontSize: 13,
                                color: _mutedText,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        splashRadius: 20,
                        onPressed: () {
                          _showPhotoGuidelines(); // Open popup guidelines
                        },
                        icon: const Icon(
                          Icons.info_outline,
                          color: Color(0xFF64748B), // muted text color
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Uploader / preview (expanded)
              Expanded(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedImage == null
                            ? _borderBlue.withOpacity(0.18)
                            : _borderBlue,
                        width: _selectedImage == null ? 1.0 : 1.6,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: _selectedImage == null
                        ? _buildEmptyState()
                        : _buildPreviewState(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Analyze button (gradient)
              SizedBox(
                height: 52,
                width: double.infinity,
                child: GestureDetector(
                  onTap: (_selectedImage == null || _isAnalyzing)
                      ? null
                      : _analyzeImage,
                  child: AbsorbPointer(
                    absorbing: (_selectedImage == null || _isAnalyzing),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: (_selectedImage == null || _isAnalyzing)
                            ? LinearGradient(
                                colors: [
                                  _primarySolid.withOpacity(0.45),
                                  _primaryDark.withOpacity(0.45),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                            : _primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: (_selectedImage == null || _isAnalyzing)
                            ? []
                            : [
                                BoxShadow(
                                  color: _primaryDark.withOpacity(0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        onPressed: (_selectedImage == null || _isAnalyzing)
                            ? null
                            : _analyzeImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isAnalyzing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
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
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------
  // Empty state widget (improved visuals)
  // -----------------------
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // circle with cloud icon
        Container(
          width: 94,
          height: 94,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _borderBlue.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _primaryGradient,
              ),
              child: const Icon(
                Icons.cloud_upload_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        const Text(
          'Tap to upload',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _darkText,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Supported formats: JPEG, JPG, PNG, WEBP',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: _mutedText),
        ),

        const SizedBox(height: 18),

        // subtle dashed hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Best results: 70–80% nail coverage, natural light',
            style: TextStyle(fontSize: 12, color: _mutedText),
          ),
        ),
      ],
    );
  }

  // -----------------------
  // Preview state widget
  // -----------------------
  Widget _buildPreviewState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
          ),
          child: Material(
            elevation: 6,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 260,
                child: Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Unable to show image'));
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(
                Icons.photo_camera_back_outlined,
                size: 18,
                color: _primarySolid,
              ),
              label: const Text(
                'Change photo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primarySolid,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              child: const Text(
                'Remove',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _mutedText,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
          child: Icon(icon, size: 18, color: const Color(0xFF3B87D2)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(text: TextSpan(children: spans)),
        ),
      ],
    );
  }
}
