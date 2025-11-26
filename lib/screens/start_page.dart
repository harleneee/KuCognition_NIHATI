import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StartPage(),
  ));
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with SingleTickerProviderStateMixin {
  bool _showText = false;
  bool _showButtons = false;

  // Controls the logo movement
  Alignment _logoAlignment = Alignment(0, 0); // starts centered

  // When tapping logo
  void _onLogoClicked() async {
    setState(() {
      // Move the logo UP to match second screen position
      _logoAlignment = Alignment(0, -0.22);
    });

    // Wait for the logo movement animation to finish
    await Future.delayed(Duration(milliseconds: 700));

    // Now fade in text
    setState(() {
      _showText = true;
    });

    // Wait then show buttons
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _showButtons = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FD),

      body: Stack(
        children: [
          // -------------------------------------------------------
          // CENTERED ANIMATED GROUP (LOGO SLIDE + TEXT FADE)
          // -------------------------------------------------------
          AnimatedAlign(
            alignment: _logoAlignment,
            duration: Duration(milliseconds: 700),
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
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // TITLE
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 700),
                  child: Text(
                    'Welcome to KuCognition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF001372),
                      fontSize: 26,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                SizedBox(height: 6),

                // SUBTITLE
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 700),
                  child: Text(
                    'Your Smart Nail Health\nCompanion',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF3B87D2),
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -------------------------------------------------------
          // BOTTOM BUTTONS
          // -------------------------------------------------------
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showButtons ? 1.0 : 0.0,
              duration: Duration(milliseconds: 800),
              child: Column(
                children: [
                  // Login Button
                  Container(
                    width: 280,
                    height: 42,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF3B87D2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
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

                  SizedBox(height: 16),

                  // Sign Up Button
                  Container(
                    width: 280,
                    height: 42,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE0F2FF),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      shadows: [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}