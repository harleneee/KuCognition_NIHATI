import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  // TEMPORARY sample data (we will replace this with real API data later)
  final List<Map<String, String>> sampleHistory = const [
    {"result": "Healthy", "date": "2025-02-01 10:30 AM"},
    {"result": "Fungal Infection", "date": "2025-01-29 2:15 PM"},
    {"result": "Pale Nails", "date": "2025-01-25 4:40 PM"},
  ];

  Icon getIconForResult(String result) {
    switch (result) {
      case "Healthy":
        return const Icon(Icons.check_circle, color: Colors.green);
      case "Fungal Infection":
        return const Icon(Icons.warning, color: Colors.red);
      case "Pale Nails":
        return const Icon(Icons.info, color: Colors.orange);
      default:
        return const Icon(Icons.health_and_safety);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan History"), centerTitle: true),
      body: ListView.builder(
        itemCount: sampleHistory.length,
        itemBuilder: (context, index) {
          final item = sampleHistory[index];
          return ListTile(
            leading: getIconForResult(item["result"]!),
            title: Text(item["result"]!, style: const TextStyle(fontSize: 18)),
            subtitle: Text(item["date"]!),
          );
        },
      ),
    );
  }
}
