import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // add intl to pubspec.yaml if not present

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF5FD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF001372)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          "HISTORY",
          style: TextStyle(
            color: Color(0xFF151921),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Please log in to view your history.',
                style: TextStyle(color: Colors.black87),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 10),
                const _HistoryTabsHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('history')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading history'),
                        );
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
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
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

                          final String? risk = data['risk'] as String?;
                          final String? imageUrl = data['imageUrl'] as String?;

                          final ts = data['timestamp'] as Timestamp?;
                          final String dateText = ts == null
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
                              // TODO: hook this to full results page later
                              // Navigator.pushNamed(context, '/result_page', arguments: {...});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Full results screen is not yet implemented.'),
                                ),
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
}

/// Top ABOUT / HISTORY pill, copied style from Profile.
/// Here HISTORY looks active, ABOUT just pops back to previous screen.
class _HistoryTabsHeader extends StatelessWidget {
  const _HistoryTabsHeader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                // Go back to whatever screen (likely ProfilePage / ABOUT)
                Navigator.of(context).maybePop();
              },
              child: _tabChip("ABOUT", isActive: false),
            ),
            const SizedBox(width: 4),
            _tabChip("HISTORY", isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(String text, {required bool isActive}) {
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

/// One history card summary, similar to your Figma design.
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
        borderRadius: BorderRadius.circular(31.14),
        border: Border.all(color: const Color(0xFFEFEDE9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x57A5BECC),
            blurRadius: 8.3,
            offset: Offset(-1.04, 3.11),
            spreadRadius: 1.04,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: image + text
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.53),
                child: Container(
                  width: 80,
                  height: 90,
                  color: const Color(0xFFBFB5FF),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.white,
                        ),
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
                        fontSize: 15.57,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary,
                      style: const TextStyle(
                        color: Color(0xFF828488),
                        fontSize: 12.53,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.57,
                      ),
                    ),
                    if (confidence != null || risk != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (confidence != null)
                            Text(
                              'Confidence: ${(confidence! * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF828488),
                              ),
                            ),
                          if (confidence != null && risk != null)
                            const SizedBox(width: 8),
                          if (risk != null)
                            Text(
                              'Risk: $risk',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF828488),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bottom row: date + VIEW MORE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateText,
                style: const TextStyle(
                  color: Color(0xFF151921),
                  fontSize: 11.57,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: onViewMore,
                child: const Text(
                  'VIEW MORE',
                  style: TextStyle(
                    color: Color(0xFF00285E),
                    fontSize: 11.57,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Short summaries used in the history cards.
/// You can tweak this text anytime.
String _shortSummaryFor(String conditionKey, String? risk) {
  switch (conditionKey) {
    case 'Acral Lentiginous Melanoma':
      return 'Dark streak under the nail; may require urgent evaluation.';
    case 'Clubbing':
      return 'Rounded, enlarged fingertips; may reflect heart or lung issues.';
    case 'Healthy Nail':
      return 'No major abnormalities detected in nail color or shape.';
    case 'Onychogryphosis':
      return 'Thickened, curved nail that may cause discomfort or infection.';
    case 'Pitting':
      return 'Small dents on nail surface; may relate to inflammatory disease.';
    default:
      return risk == 'High'
          ? 'Significant nail changes detected; consider medical review.'
          : 'Nail changes detected; tap to view full analysis.';
  }
}
