import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin {
  bool _showText = false;
  bool _showButtons = false;

  Alignment _logoAlignment = Alignment(0, 0);

  void _onLogoClicked() async {
    setState(() {
      _logoAlignment = Alignment(0, -0.22);
    });

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _showText = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _showButtons = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // ⭐ NEW ANIMATED BREATHING BACKGROUND
          const AnimatedBreathingBackground(),

          // ⭐ LOGO + TITLES
          AnimatedAlign(
            alignment: _logoAlignment,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // LOGO
                GestureDetector(
                  onTap: _onLogoClicked,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ⭐ UPDATED BIGGER TITLE
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  child: const Text(
                    'Welcome to KuCognition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF001372),
                      fontSize: 28,                 // LARGER
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w900,  // BOLDER
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ⭐ UPDATED EXPANDED SUBTITLE
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 700),
                  child: const Text(
                    'Your Smart Nail Health Companion.\n'
                    'Get insights from nail changes\n'
                    'to better understand your internal health.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3B87D2),
                      fontSize: 14,
                      height: 1.32,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ⭐ BUTTONS (CLICKABLE)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showButtons ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: Column(
                children: [

                  // LOGIN BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/login"),
                    child: Container(
                      width: 280,
                      height: 42,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF3B87D2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SIGN UP BUTTON
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/signup"),
                    child: Container(
                      width: 280,
                      height: 42,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFE0F2FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ===========================================================
// ⭐ ANIMATED BREATHING BACKGROUND (SOFT SKY BLUE + DARK BLUE)
// ===========================================================
//

class AnimatedBreathingBackground extends StatefulWidget {
  const AnimatedBreathingBackground({super.key});

  @override
  State<AnimatedBreathingBackground> createState() => _AnimatedBreathingBackgroundState();
}

class _AnimatedBreathingBackgroundState extends State<AnimatedBreathingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        double pulse = 0.6 + (_controller.value * 0.4);
        double softPulse = 0.5 + (_controller.value * 0.5);

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFFEAF7FF), const Color(0xFFD6EBFF), softPulse)!,
                Color.lerp(const Color(0xFFD6EBFF), const Color(0xFFB8D9FF), pulse)!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -120,
                left: -80,
                child: breathingGlow(280, const Color.fromARGB(255, 47, 140, 234), pulse),
              ),
              Positioned(
                top: 120,
                right: -100,
                child: breathingGlow(340, const Color.fromARGB(255, 47, 140, 234), softPulse),
              ),
              Positioned(
                bottom: -160,
                left: -40,
                child: breathingGlow(420, const Color.fromARGB(255, 47, 140, 234), pulse),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget breathingGlow(double size, Color color, double pulse) {
  return Container(
    width: size * pulse,
    height: size * pulse,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          color.withOpacity(0.45 * pulse),
          Colors.transparent,
        ],
      ),
    ),
  );
}