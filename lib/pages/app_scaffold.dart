import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? floatingActionButton;

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
  Future<void> _showWelcomeDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool opened = prefs.getBool('chatbotOpened') ?? false;
    if (!opened) {
      await prefs.setBool('chatbotOpened', true);
      if (context.mounted) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      drawer: widget.drawer,
      body: widget.body,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'chatbot',
            onPressed: () async {
              await _showWelcomeDialog();
              Navigator.pushNamed(context, '/chatbot');
            },
            backgroundColor: Colors.white,
            tooltip: 'Krisha AI Assistant',
            child: Image.asset(
              'assets/images/robot.png',
              height: 30,
              width: 30,
            ),
          ),
          SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'createCampaign',
            onPressed: () {
              Navigator.pushNamed(context, '/createCampaign');
            },
            backgroundColor: Colors.green,
            tooltip: 'Create Campaign',
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
