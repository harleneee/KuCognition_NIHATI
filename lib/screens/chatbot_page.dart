// lib/pages/chatbot_page.dart  (path may differ in your project)
import 'package:flutter/material.dart';
import '../data/chatbot_api.dart'; // adjust if your path is different
import 'package:flutter_markdown/flutter_markdown.dart';
// ✅ NEW: speech-to-text import
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Local color palette for the chat screen.
class AppColors {
  static const Color primaryBlue = Color(0xFF3B70B9);
  static const Color bubbleUser = Color(0xFF2F6ACF);
  static const Color sendButton = Color(0xFF2563EB);
}

class ChatbotPage extends StatefulWidget {
  final String initialPrompt;

  const ChatbotPage({super.key, required this.initialPrompt});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  bool _isSending = false;
  bool _isBotTyping = false; // typing indicator toggle

  // ✅ NEW: speech-to-text state
  late stt.SpeechToText _speech;
  bool _isListening = false;

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m $ampm";
  }

  final List<String> _quickPrompts = const [
    'What can you do for me?',
    'What diseases can this app scan?',
    'What is the relation of nails to systemic disease?',
    'How accurate are the scan results?',
  ];

  @override
  void initState() {
    super.initState();

    // ✅ NEW: init speech instance
    _speech = stt.SpeechToText();

    // If Dashboard passes an initial question, send it directly to KuBot.
    if (widget.initialPrompt.trim().isNotEmpty) {
      final initial = widget.initialPrompt.trim();
      _addUserMessage(initial);
      _sendToKuBot(initial);
    } else {
      _addBotMessage(
        'Hi, I\'m KuBot. I can help you understand nail conditions, '
        'navigate the KuCognition app, and give general nail-health guidance.\n\n'
        'You can type a question below or tap one of the quick suggestions.',
      );
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        _ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Call FastAPI KuBot backend through ChatbotAPI.
  Future<void> _sendToKuBot(String text) async {
    setState(() {
      _isSending = true;
      _isBotTyping = true; // show typing bubble
    });
    _scrollToBottom(); // make sure we scroll down to see it

    // Start the request
    final futureResponse = ChatbotAPI.sendMessage(text);

    // Wait for the actual response
    final result = await futureResponse;

    // Ensure typing indicator is visible for at least 600ms
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isSending = false;
      _isBotTyping = false; // hide typing bubble
    });

    final reply =
        result['reply']?.toString() ??
        'I had trouble understanding the response from the server.';
    _addBotMessage(reply);
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    _addUserMessage(text);
    _sendToKuBot(text);
  }

  void _handleQuickPrompt(String prompt) {
    if (_isSending) return;
    _addUserMessage(prompt);
    _sendToKuBot(prompt);
  }

  // ✅ NEW: toggle mic listening and push transcript into the text field
  Future<void> _toggleListening() async {
    // If already listening → stop.
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    // Initialize speech recognition (will handle permission the first time)
    final available = await _speech.initialize(
      onStatus: (status) => debugPrint('speech status: $status'),
      onError: (error) => debugPrint('speech error: $error'),
    );

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
    });

    _speech.listen(
      onResult: (result) {
        // Update text field with recognized words
        setState(() {
          _messageController.text = result.recognizedWords;
          _messageController.selection = TextSelection.fromPosition(
            TextPosition(offset: _messageController.text.length),
          );
        });
      },
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 60),
      // You can tweak locale if you want a specific language, or leave null.
      // localeId: 'en_US',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // ✅ NEW: stop listening if still active
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KuBotBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 4),
              _buildMessagesList(),
              _buildQuickPromptsBar(),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER – centered title like the target UI.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Chat with KuBot',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Nail Health Assistant',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40), // visual balance for back button space
        ],
      ),
    );
  }

  // MESSAGES LIST – white bot bubbles, blue user bubbles + typing bubble.
  Widget _buildMessagesList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: _messages.length + (_isBotTyping ? 1 : 0),
          itemBuilder: (context, index) {
            // If it's the extra row at the end AND bot is typing → typing bubble.
            if (_isBotTyping && index == _messages.length) {
              return _buildTypingBubble();
            }

            final msg = _messages[index];
            final isUser = msg.isUser;

            final radius = BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 18),
            );

            if (isUser) {
              // USER bubble – solid blue gradient, subtle shadow.
              return Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F8BFF), AppColors.bubbleUser],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.3,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(msg.timestamp),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // BOT bubble – clean white card, soft shadow.
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MarkdownBody(
                        data: msg.text,
                        softLineBreak: true,
                        selectable: false,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: Colors.black87,
                          ),
                          strong: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                            height: 1.35,
                            color: Colors.black87,
                          ),
                          a: const TextStyle(
                            color: Color(0xFF2563EB),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(msg.timestamp),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  // Typing indicator bubble styled like a bot message.
  Widget _buildTypingBubble() {
    const radius = BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(6),
      bottomRight: Radius.circular(18),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        constraints: const BoxConstraints(maxWidth: 160),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _TypingDot(),
            SizedBox(width: 4),
            _TypingDot(),
            SizedBox(width: 4),
            _TypingDot(),
          ],
        ),
      ),
    );
  }

  // QUICK PROMPTS – white pill chips.
  Widget _buildQuickPromptsBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _quickPrompts.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final prompt = _quickPrompts[index];
            return GestureDetector(
              onTap: () => _handleQuickPrompt(prompt),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  prompt,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // INPUT BAR – white pill + blue gradient send button, now MULTILINE.
  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // ✅ UPDATED: mic icon is now tappable and shows listening state
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 20,
                      color:
                          _isListening ? AppColors.sendButton : Colors.black26,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 4, // grows vertically up to 4 lines
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F8BFF), AppColors.sendButton],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sendButton.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

/// Simple static dot used in typing indicator.
class _TypingDot extends StatelessWidget {
  const _TypingDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// ----------
/// Background with two soft radial blobs + subtle logo
/// ----------

class KuBotBackground extends StatelessWidget {
  final Widget child;

  const KuBotBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Solid very-light blue base so the blobs read clearly.
      color: const Color(0xFFF4F7FF),
      child: Stack(
        children: [
          // TOP-LEFT BLUE BLOB
          const Positioned(
            top: -120,
            left: -40,
            child: _SoftGlow(
              size: 360,
              color: Color(0xFF6EA4FF),
              opacity: 0.45,
              softness: 0.9,
            ),
          ),

          // BOTTOM-RIGHT BLUE BLOB
          const Positioned(
            bottom: -150,
            right: -40,
            child: _SoftGlow(
              size: 420,
              color: Color(0xFF9FC3FF),
              opacity: 0.42,
              softness: 0.95,
            ),
          ),

          // CENTRAL WHITE GLOW TO BLEND THE LOGO
          const Align(
            alignment: Alignment(0.0, 0.1),
            child: _SoftGlow(
              size: 260,
              color: Colors.white,
              opacity: 0.9,
              softness: 0.8,
            ),
          ),

          // KuCognition logo watermark
          Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/logo.png',
                width: 230,
                height: 230,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Actual chat content.
          child,
        ],
      ),
    );
  }
}

/// Circular, radial "blob" glow.
/// `size` = diameter, `softness` controls how quickly it fades.
class _SoftGlow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double softness; // 0–1, higher = harder edge, lower = softer

  const _SoftGlow({
    required this.size,
    required this.color,
    required this.opacity,
    this.softness = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: Alignment.center,
            radius: softness,
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(opacity * 0.15),
              color.withOpacity(0.0),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }
}
