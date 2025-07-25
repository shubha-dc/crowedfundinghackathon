import 'package:crowedfundinghackathon/pages/chatbot_screen.dart';
import 'package:crowedfundinghackathon/pages/payment_page.dart';
import 'package:crowedfundinghackathon/pages/repay_page.dart';
import 'package:flutter/material.dart';

// Import your pages
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/wallet_page.dart';
import 'pages/profile_page.dart';
import 'pages/createcampaign_page.dart';
import 'pages/invest_page.dart';

import 'package:crowedfundinghackathon/models/campaign.dart' as model;

void main() {
  runApp(AgroFundApp());
}

class AgroFundApp extends StatelessWidget {
  const AgroFundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroFund',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(
          username: 'John Doe',
          userEmail: 'john@example.com',
          aadharId: '123456789123',
        ),
        '/wallet': (context) => WalletPage(aadharId: '5000'),
        '/profile': (context) => ProfilePage(
          username: 'John Doe',
          email: 'john@example.com',
          phone: '9876543210',
          aadhaar: '123412341234',
        ),
        '/createCampaign': (context) => CreateCampaignPage(),
        '/chatbot': (context) => ChatbotScreen(),
        '/repay': (context) =>
            RepayPage(username: 'John Doe', userEmail: 'john@example.com'),
      },
      // Use onGenerateRoute to handle arguments like Campaign
      onGenerateRoute: (settings) {
        if (settings.name == '/invest') {
          final camp = settings.arguments as model.Campaign;
          return MaterialPageRoute(
            builder: (context) =>
                InvestPage(campaign: camp, aadharId: '123456789123'),
          );
        }
        if (settings.name == '/payment') {
          final camp = settings.arguments as model.Campaign;
          return MaterialPageRoute(
            builder: (context) => PaymentPage(campaign: camp),
          );
        }
        return null;
      },
    );
  }
}
