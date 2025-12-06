import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'scan_page.dart';
import 'profile_page.dart';
import 'chatbot_page.dart';
import 'history_page.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF3B70B9);
  static const Color lightBackground = Color(0xFFEFF5F9);
  static const Color headerBackground = Color(0xFF75A2DB);
  static const Color gradientStart = Color(0xFF8BB7E9);
  static const Color gradientEnd = Color(0xFF3B70B9);
  static const Color scanButton = Color(0xFF4C8CDA);
  static const Color scanButtonDark = Color(0xFF2B5B9B);
  static const Color iconColor = Color(0xFF3B70B9);
}

class DashboardScreen extends StatelessWidget {
  final String? username;

  const DashboardScreen({super.key, this.username});

  // ---------------------------------------
  // NEW: fetch last scan
  // ---------------------------------------
Future<String> getLastScanText() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return "none";

  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('history')
      .orderBy('timestamp', descending: true)
      .limit(1)
      .get();

  if (snap.docs.isEmpty) return "none";

  final data = snap.docs.first.data();
  if (data['timestamp'] is! Timestamp) return "none";

  final ts = (data['timestamp'] as Timestamp).toDate(); // UTC from Firestore

  // ⭐ Convert to Philippine time (UTC+8)
  final phTime = ts.add(const Duration(hours: 8));

  // FORMAT DATE
  final date = DateFormat('MMMM d, yyyy').format(phTime).toUpperCase();

  // FORMAT TIME (12-hour format)
  final time = DateFormat('h:mm a').format(phTime);

  return "$date • $time";
}


  // ---------------------------------------

  String welcomeText() {
    final clean = username?.trim();
    if (clean != null && clean.isNotEmpty) {
      return 'Welcome, $clean!';
    }
    return 'Welcome!';
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      // CHATBOT FAB
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.9, end: 1.0),
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: FloatingActionButton(
              heroTag: "chatbotFab",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatbotPage(
                      initialPrompt: "Hello KuBot!",
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.scanButtonDark,
              elevation: 10,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.question_answer_rounded,
                size: 34,
                color: Colors.white,
              ),
            ),
          );
        },
      ),

      // BOTTOM NAV + SCAN BUTTON
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            BottomAppBar(
              height: 70,
              elevation: 0,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.home, color: AppColors.primaryBlue),
                      Text(
                        "Home",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.person_outline, color: AppColors.primaryBlue),
                        Text(
                          "Profile",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -32,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanPage(),
                    ),
                  );
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

body: SafeArea(
  child: Stack(
    children: [
      // ⭐ BACKGROUND IMAGE HERE
      Positioned.fill(
        child: Image.asset(
          'assets/images/bgg.jpg',
          fit: BoxFit.cover,
        ),
      ),

      // OPTIONAL: You can keep your soft background circles
      Positioned(
        top: -40,
        right: -30,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),


            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(context),
                    buildScanActionCard(context),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SectionTitle(title: 'Recent Scans'),
                          RecentScansCard(),
                          SectionTitle(title: 'Health Tips'),
                          _HealthTipsCarousel(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    buildRecommendedTopics(context),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(title: 'FAQs'),
                          FAQsSection(),
                          SectionTitle(title: 'About Us'),
                          AboutUsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER ------------------------------------------------------

  Widget buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, (1 - val) * 20),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'KuCognition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => logout(context),
                  child: Row(
                    children: const [
                      Text(
                        'Log out',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.logout, color: Colors.white70, size: 20),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // welcome text + fingerprint icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        welcomeText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Scan your nail to detect early signs of possible health conditions.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),
                const Icon(
                  Icons.fingerprint,
                  size: 72,
                  color: Colors.white30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SCAN CARD ---------------------------------------------------

  Widget buildScanActionCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Card(
          elevation: 8,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Check your health now!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 4),

                // ⭐ UPDATED: Real Last Scan
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),

                    FutureBuilder<String>(
                      future: getLastScanText(),
                      builder: (context, snapshot) {
                        final text = snapshot.data ?? "none";
                        return Text(
                          "Last Scan: $text",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.scanButton, AppColors.scanButtonDark],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(9, 0, 0, 0),
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Scan Now',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // QUICK ANSWERS WITH KUBOT -------------------------------------

  Widget buildRecommendedTopics(BuildContext context) {
    final List<Map<String, dynamic>> topics = [
      {
        'prompt': 'What diseases can this app scan?',
        'icon': Icons.medical_services_outlined,
      },
      {
        'prompt': 'How accurate are the scan results?',
        'icon': Icons.help_outline,
      },
      {
        'prompt': 'What should I do if a deficiency is detected?',
        'icon': Icons.health_and_safety_outlined,
      },
      {
        'prompt': 'What does a zinc deficiency look like on nails?',
        'icon': Icons.search,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.question_answer, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text(
                'Quick Answers with KuBot',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == topics.length - 1 ? 0 : 10,
                  ),
                  child: _TopicChip(
                    prompt: topic['prompt'],
                    icon: topic['icon'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatbotPage(
                            initialPrompt: topic['prompt'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- OTHER WIDGETS -----------------

class _TopicChip extends StatelessWidget {
  final String prompt;
  final IconData icon;
  final VoidCallback onTap;

  const _TopicChip({
    required this.prompt,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.12),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(icon, color: AppColors.scanButton, size: 24),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                prompt,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class RecentScansCard extends StatelessWidget {
  const RecentScansCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const HistoryPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.lightBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No recent scans',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthTipsCarousel extends StatefulWidget {
  const _HealthTipsCarousel();

  @override
  State<_HealthTipsCarousel> createState() => _HealthTipsCarouselState();
}

class _HealthTipsCarouselState extends State<_HealthTipsCarousel> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<String> tips = const [
    'White spots on nails can indicate a zinc deficiency, but they often grow out naturally.',
    'Vertical ridges on the nails are common and often related to aging or mild dehydration.',
    'Very pale nails may sometimes be associated with low iron levels or anemia.',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.scanButtonDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 35,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: tips.length,
                      onPageChanged: (index) {
                        setState(() => _current = index);
                      },
                      itemBuilder: (context, index) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tips[index],
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tips.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _current == index ? 10 : 6,
                  height: _current == index ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? AppColors.scanButtonDark
                        : Colors.grey.shade300,
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

class FAQsSection extends StatelessWidget {
  const FAQsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _FAQTile(
          question: 'How do I use KuCognition to scan my nails?',
          answer:
              'Simply tap the scan button on the dashboard, allow camera access, and position your nail according to the guide. The app will automatically capture and analyze the image for health conditions.',
        ),
        _FAQTile(
          question: 'What health conditions can KuCognition detect?',
          answer:
              'KuCognition can detect early signs of conditions related to mineral deficiencies (like Zinc or Iron), fungal infections, and other systemic issues that manifest visibly on the nails.',
        ),
        _FAQTile(
          question: 'How accurate are the results?',
          answer:
              'Our AI model is highly accurate, utilizing advanced image processing. However, results are for informational purposes only and should not replace professional medical advice.',
        ),
        _FAQTile(
          question: 'Can I view my previous scan results?',
          answer:
              'Yes, all your previous scans are saved under the "Recent Scans" section on the dashboard.',
        ),
      ],
    );
  }
}

class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FAQTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        children: <Widget>[
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ABOUT US ---
class AboutUsSection extends StatelessWidget {
  const AboutUsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        // ⬅️ balik sa all(16) para may white space sa right
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 📄 Text – left side
              const Expanded(
                flex: 3,
                child: Text(
                  'KuCognition is an AI-powered health monitoring app designed to provide high-resolution nail image analysis. Using advanced image processing and deep learning, our technology detects early signs of skin/nail conditions, vitamin deficiencies, edema, and infections — simply by scanning your nails.\n\nOur mission is to make preventive health care readily accessible by turning an everyday observation into a meaningful, proactive health step.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 🖼 Right side: gradient background + inner white padding
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF5F8FF), // very soft blue
                        Color(0xFFE3EDFF),
                      ],
                    ),
                  ),
                  // white space sa loob bago yung image
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/aboutushand.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}