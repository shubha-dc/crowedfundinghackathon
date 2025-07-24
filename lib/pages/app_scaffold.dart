import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.floatingActionButton,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _chatbotOpenedOnce = false;

  @override
  void initState() {
    super.initState();
    _checkChatbotWelcome();
  }

  Future<void> _checkChatbotWelcome() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool opened = prefs.getBool('chatbotOpened') ?? false;
    if (!opened) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWelcomeDialog();
        prefs.setBool('chatbotOpened', true);
      });
    }
  }

  void _showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hello! 👋'),
        content: Text(
          "I'm Krisha 🤖, your AI farm assistant. Let’s grow together! 🌱",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Let\'s Chat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      drawer: widget.drawer,
      body: Stack(
        children: [
          widget.body,
          Positioned(
            bottom: 80,
            right: 16,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FloatingActionButton(
                  heroTag: "chatbot",
                  backgroundColor: Colors.white,
                  onPressed: () {
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  child: Lottie.asset(
                    'lootie/robot-assistant.json',
                    width: 40,
                    height: 40,
                    repeat: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
