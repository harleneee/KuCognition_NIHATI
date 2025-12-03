import 'package:flutter/material.dart';
import 'diseaseresults_page.dart';
import 'scan_page.dart';

const Color _primaryBlue = Color(0xFF3B70B9);
const Color _darkBlue = Color(0xFF001372);
const Color _bgBlue = Color(0xFFEAF5FD);

class LearnMorePage extends StatelessWidget {
  LearnMorePage({super.key});

  // title + corresponding image in assets/images/
  final List<Map<String, String>> items = const [
    {
      "title": "Blue Finger/Bluish nail (Cyanosis)",
      "image": "assets/images/cyanosis.jpg",
    },
    {
      "title": "Clubbing",
      "image": "assets/images/clubbing.jpg",
    },
    {
      "title": "Onychomycosis",
      "image": "assets/images/onychomycosis.jpg",
    },
    {
      "title": "Psoriasis",
      "image": "assets/images/psoriasis.jpg",
    },
    {
      "title": "Healthy Nail",
      "image": "assets/images/healthy.jpg",
    },
    {
      "title": "Acral Lentiginous Melanoma",
      "image": "assets/images/melanoma.jpg",
    },
    {
      "title": "Onychogryphosis",
      "image": "assets/images/onychogryphosis.jpg",
    },
    {
      "title": "Pitting",
      "image": "assets/images/pitting.jpg",
    },
    {
      "title": "Yellow Nail",
      "image": "assets/images/yellownail.jpg",
    },
    {
      "title": "White Nail",
      "image": "assets/images/whitenail.jpg",
    },
    {
      "title": "Beau’s line",
      "image": "assets/images/beausline.jpg",
    },
    {
      "title": "Koilonychia",
      "image": "assets/images/koilonychia.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBlue,
      body: SafeArea(
        child: Column(
          children: [
            const _LearnMoreHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _DiseaseTile(
                    title: item["title"]!,
                    imagePath: item["image"]!,
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DiseaseDetailsPage(disease: item["title"]!),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// HEADER WITH GRADIENT + TITLE, BACK GOES TO ScanPage
class _LearnMoreHeader extends StatelessWidget {
  const _LearnMoreHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // soft circles
        SizedBox(
          height: 170,
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
              ),
              Positioned(
                left: -25,
                bottom: -15,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryBlue, Color(0xFF75A2DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),

          child: Column(
            children: [
              // Back button aligned left
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanPage()),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),

              // CENTERED TITLE & SUBTITLE
              Column(
                children: const [
                  Text(
                    "NAIL HEALTH INDEX",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      letterSpacing: 0.6,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Explore nail indicators and what they may say\nabout your overall health.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,         
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFEAF5FF),
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


/// SINGLE TILE WITH IMAGE + ANIMATION
class _DiseaseTile extends StatefulWidget {
  final String title;
  final String imagePath;
  final int index;
  final VoidCallback onTap;

  const _DiseaseTile({
    required this.title,
    required this.imagePath,
    required this.index,
    required this.onTap,
  });

  @override
  State<_DiseaseTile> createState() => _DiseaseTileState();
}

class _DiseaseTileState extends State<_DiseaseTile> {
  double opacity = 0;
  double offsetY = 20;

  @override
  void initState() {
    super.initState();
    // staggered animation
    Future.delayed(Duration(milliseconds: 70 * widget.index), () {
      if (mounted) {
        setState(() {
          opacity = 1;
          offsetY = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 450),
      opacity: opacity,
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, offsetY, 0),
        margin: const EdgeInsets.only(top: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 4,
          shadowColor: _primaryBlue.withOpacity(0.18),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  // thumbnail image
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _bgBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: _darkBlue,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}