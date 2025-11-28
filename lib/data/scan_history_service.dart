import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanHistoryService {
  /// Saves a scan entry into:
  /// users/{uid}/history/{autoId}
  ///
  /// You will call this from the FULL RESULTS PAGE,
  /// because that page contains the complete data.
  static Future<void> saveScan({
    required String conditionKey,      // e.g. "Acral Lentiginous Melanoma"
    required String predictionLabel,   // what you will display in history
    double? confidence,                // 0–1 confidence
    String? risk,                      // "High", "Moderate", "Low"
    String? imageUrl,                  // later stored image
    String? source,                    // "uploaded" or "camera"
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User not logged in → do nothing
      return;
    }

    final uid = user.uid;

    // Base data for the history record
    final Map<String, dynamic> data = {
      "timestamp": FieldValue.serverTimestamp(),
      "conditionKey": conditionKey,
      "predictionLabel": predictionLabel,
    };

    // Add optional fields only if provided
    if (confidence != null) data["confidence"] = confidence;
    if (risk != null) data["risk"] = risk;
    if (imageUrl != null) data["imageUrl"] = imageUrl;
    if (source != null) data["source"] = source;

    // Save to Firestore
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("history")
        .add(data);
  }
}
