import 'dart:io';
import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final File? image;
  final String result;
  final double confidence;

  const ResultPage({
    super.key,
    this.image,
    this.result = "Healthy", // temporary default
    this.confidence = 0.92, // temporary default
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diagnosis Result"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              // Image preview
              image != null
                  ? Image.file(image!, height: 220)
                  : const Icon(Icons.image, size: 180),

              const SizedBox(height: 30),

              // Diagnosis Text
              Text(
                "Result: $result",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // Confidence Score
              Text(
                "Confidence: ${(confidence * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: 40),

              // Return to Scan Page
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/scan');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text("Scan Another Nail"),
              ),

              const SizedBox(height: 15),

              // Go to History Page
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                child: const Text("View Scan History"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
