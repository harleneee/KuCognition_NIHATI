import 'package:flutter/material.dart';
import 'scan_page.dart';
import 'profile_page.dart';
import 'chatbot_page.dart'; // 👈 NEW IMPORT

void main() {
  runApp(const KuCognitionApp());
}

// --- COLOR AND CONSTANTS DEFINITION ---
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

class KuCognitionApp extends StatelessWidget {
  const KuCognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KuCognition Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryBlue,
          background: AppColors.lightBackground,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          color: AppColors.primaryBlue,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// --- CHATBOT SCREEN (old placeholder, now unused but kept for reference) ---
class ChatbotScreen extends StatelessWidget {
  final String initialPrompt;
  const ChatbotScreen({super.key, required this.initialPrompt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KuBot Chat')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology_alt_outlined,
                  size: 80, color: AppColors.primaryBlue),
              const SizedBox(height: 20),
              const Text(
                'Welcome to KuBot!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'You clicked the prompt:',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                '"$initialPrompt"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.scanButtonDark,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.scanButton,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- DASHBOARD SCREEN ---
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,

      // CHATBOT FAB — BIG + ANIMATION
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
                    builder: (context) => ChatbotPage(
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

      // BOTTOM NAVIGATION BAR + CENTER SCAN BUTTON
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          BottomAppBar(
            height: 70,
            elevation: 15,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home (just visual, stays on dashboard)
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

                const SizedBox(width: 40), // For center scan button

                // Profile -> navigate to ProfilePage
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

          // CENTER SCAN BUTTON -> ScanPage
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

      // BODY (SCROLLABLE)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildScanActionCard(context),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SectionTitle(title: 'Recent Scans'),
                      _RecentScansCard(),
                      _SectionTitle(title: 'Health Tips'),
                      _HealthTipsCard(),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                _buildRecommendedTopics(context),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(title: 'FAQs'),
                      _FAQsSection(),
                      _SectionTitle(title: 'About Us'),
                      _AboutUsSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.monitor_heart_outlined,
                        color: Colors.white, size: 30),
                    SizedBox(width: 8),
                    Text(
                      'KuCognition',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.logout, color: Colors.white70, size: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Scan your nail to detect early signs of possible health conditions.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.fingerprint,
                  size: 90,
                  color: Colors.white30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- SCAN CARD ---
  Widget _buildScanActionCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                const Text(
                  'Last Scan: none',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [AppColors.scanButton, AppColors.scanButtonDark],
                    ),
                  ),
                  child: ElevatedButton(
                    // 🔗 "Scan Now" -> ScanPage
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Scan Now',
                      style: TextStyle(
                        fontSize: 18,
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

  // --- RECOMMENDED TOPICS ---
  Widget _buildRecommendedTopics(BuildContext context) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
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
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
    );
  }
}

// --- TOPIC CHIP (FIXED OVERFLOW) ---
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
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.scanButton, size: 28),
            const SizedBox(height: 8),
            Text(
              prompt,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SECTIONS ---
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

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

class _RecentScansCard extends StatelessWidget {
  const _RecentScansCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: const Padding(
        padding: EdgeInsets.all(15.0),
        child: Row(
          children: [
            Icon(Icons.history, color: Colors.grey),
            SizedBox(width: 10),
            Text(
              'No recent scans',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthTipsCard extends StatelessWidget {
  const _HealthTipsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(15.0),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: AppColors.scanButtonDark),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'White spots on nails can indicate a zinc deficiency, but they often grow out naturally.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FAQsSection extends StatelessWidget {
  const _FAQsSection();

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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutUsSection extends StatelessWidget {
  const _AboutUsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              flex: 2,
              child: Text(
                'KuCognition is an AI-powered health monitoring app designed to provide high-resolution nail image analysis. Using advanced image processing and deep learning, our technology detects early signs of skin/nail conditions, vitamin deficiencies, edema, and infections — simply by scanning your nails.\n\nOur mission is to make preventive health care readily accessible by turning an everyday observation into a meaningful, proactive health step.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://placehold.co/100x150/75A2DB/FFFFFF?text=Hand',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text(
                        "Hand Image",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
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
