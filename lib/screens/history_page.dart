import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      body: Column(
        children: [
          _header(context), // ← updated gradient header matching ProfilePage

          const SizedBox(height: 16),

          Expanded(
            child: user == null
                ? const Center(
                    child: Text(
                      'Please log in to view your history.',
                      style: TextStyle(color: Colors.black87),
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('history')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading history'));
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No scan history yet.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data =
                              doc.data() as Map<String, dynamic>? ?? {};

                          final predictionLabel =
                              (data['predictionLabel'] as String?) ??
                                  'Unknown condition';
                          final conditionKey =
                              (data['conditionKey'] as String?) ??
                                  predictionLabel;

                          final double? confidence =
                              (data['confidence'] is num)
                                  ? (data['confidence'] as num).toDouble()
                                  : null;

                          final String? risk =
                              data['risk'] as String?;
                          final String? imageUrl =
                              data['imageUrl'] as String?;

                          final tsRaw = data['timestamp'];
                          final Timestamp? ts =
                              tsRaw is Timestamp ? tsRaw : null;

                          final dateText = ts == null
                              ? ''
                              : DateFormat('MMMM d, yyyy')
                                  .format(ts.toDate())
                                  .toUpperCase();

                          final summaryText =
                              _shortSummaryFor(conditionKey, risk);

                          return _HistoryCard(
                            predictionLabel: predictionLabel,
                            summary: summaryText,
                            dateText: dateText,
                            risk: risk,
                            confidence: confidence,
                            imageUrl: imageUrl,
                            onViewMore: () {
                              Navigator.pushNamed(
                                context,
                                '/result_page',
                                arguments: {
                                  'imagePath': null,
                                  'imageUrl': imageUrl,
                                  'conditionKey': conditionKey,
                                  'predictionLabel': predictionLabel,
                                  'confidence': confidence,
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER: matches the ProfilePage design exactly
  // ---------------------------------------------------------------------------

  Widget _header(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9FCCFF), // light blue
            Color(0xFF5E95E8), // medium blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // BACK BUTTON ONLY (no title)
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/profile');
                  },
                ),
                const Spacer(),
                const SizedBox(width: 48), // balance layout
              ],
            ),

            const SizedBox(height: 6),

            // ABOUT | HISTORY PILL HERE
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ABOUT → goes to profile page
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/profile');
                    },
                    child: _tabChip("ABOUT", false),
                  ),
                  const SizedBox(width: 4),

                  // HISTORY active
                  _tabChip("HISTORY", true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B87D2) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: isActive ? Colors.white : const Color(0xFF6D777F),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HISTORY CARDS (unchanged logic, but UI modern)
// ---------------------------------------------------------------------------

class _HistoryCard extends StatelessWidget {
  final String predictionLabel;
  final String summary;
  final String dateText;
  final String? risk;
  final double? confidence;
  final String? imageUrl;
  final VoidCallback onViewMore;

  const _HistoryCard({
    required this.predictionLabel,
    required this.summary,
    required this.dateText,
    required this.onViewMore,
    this.risk,
    this.confidence,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4FCFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEFEDE9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x57A5BECC),
            blurRadius: 8,
            offset: Offset(0, 3),
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + text row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 80,
                  height: 90,
                  color: const Color(0xFFBFB5FF),
                  child: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? Image.network(imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediction: $predictionLabel',
                      style: const TextStyle(
                        color: Color(0xFF151921),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      summary,
                      style: const TextStyle(
                        color: Color(0xFF828488),
                        fontSize: 13,
                      ),
                    ),

                    if (confidence != null || risk != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (confidence != null)
                            Text(
                              'Conf: ${(confidence! * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF828488)),
                            ),

                          if (confidence != null && risk != null)
                            const SizedBox(width: 8),

                          if (risk != null)
                            Text(
                              'Risk: $risk',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF828488)),
                            ),
                        ],
                      )
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date + view more
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateText,
                style: const TextStyle(
                  color: Color(0xFF151921),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onViewMore,
                child: const Text(
                  "VIEW MORE",
                  style: TextStyle(
                    color: Color(0xFF00285E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Short summary logic (unchanged)
// ---------------------------------------------------------------------------

String _shortSummaryFor(String conditionKey, String? risk) {
  switch (conditionKey) {
    case 'Acral Lentiginous Melanoma':
      return 'Dark streak under the nail; may require urgent evaluation.';
    case 'Clubbing':
      return 'Rounded fingertips; may reflect heart or lung issues.';
    case 'Healthy Nail':
      return 'No major abnormalities detected.';
    case 'Onychogryphosis':
      return 'Thickened, curved nail that may cause discomfort.';
    case 'Pitting':
      return 'Small dents; may relate to inflammatory disease.';
    case 'Beau’s Lines':
      return 'Horizontal grooves; often due to past systemic stress.';
    case 'Bluish Nail':
      return 'Blue nail bed; may indicate reduced oxygen.';
    case 'Koilonychia':
      return 'Spoon-shaped nails; may relate to iron deficiency.';
    default:
      return risk == 'High'
          ? 'Notable nail changes detected; consider review.'
          : 'Nail changes detected; tap for full analysis.';
  }
}
