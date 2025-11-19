import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: 390,
            height: 844,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFFEAF5FD)),
            child: Stack(
              children: [
                // BACKGROUND IMAGE
                Positioned(
                  left: -225,
                  top: 0,
                  child: Container(
                    width: 840,
                    height: 849,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://placehold.co/840x849"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // WHITE FRAME — now displays selected image!!!
                Positioned(
                  left: 40,
                  top: 162,
                  child: Container(
                    width: 310,
                    height: 398,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 6, color: Colors.white),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _image == null
                          ? const Center(
                              child: Text(
                                "No image selected",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Image.file(_image!, fit: BoxFit.cover),
                    ),
                  ),
                ),

                // TEXT HEADER
                const Positioned(
                  left: 16,
                  top: 64,
                  child: SizedBox(
                    width: 343,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan your Nail',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Align your nail within the frame',
                          style: TextStyle(
                            color: Color(0xFFDBDBDB),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // UPLOAD IMAGE BUTTON (FUNCTIONAL)
                Positioned(
                  left: 103,
                  top: 575,
                  child: GestureDetector(
                    onTap: () => pickImage(ImageSource.gallery),
                    child: Container(
                      width: 185,
                      height: 36,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1.25,
                              color: Color(0xFFCCCCCC),
                            ),
                            borderRadius: BorderRadius.circular(1000),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upload Image',
                              style: TextStyle(
                                color: Color(0xFF1F1E1F),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // CAMERA BUTTON
                Positioned(
                  left: 160,
                  top: 657,
                  child: GestureDetector(
                    onTap: () => pickImage(ImageSource.camera),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: OvalBorder(),
                      ),
                      child: const Icon(Icons.camera_alt, size: 32),
                    ),
                  ),
                ),

                // BOTTOM BLACK BAR
                Positioned(
                  left: 0,
                  top: 787,
                  child: Container(
                    width: 390,
                    height: 62,
                    color: const Color(0xFF282828),
                  ),
                ),

                // BOTTOM TEXT
                const Positioned(
                  left: 80,
                  top: 799,
                  child: SizedBox(
                    width: 326,
                    child: Text(
                      'Explore nail health indicators and their meanings.',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
                const Positioned(
                  left: 80,
                  top: 814,
                  child: Text(
                    'Learn more',
                    style: TextStyle(
                      color: Color(0xFFFF6A00),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
