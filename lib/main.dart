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
        '/home': (context) =>
            HomePage(username: 'John Doe', userEmail: 'john@example.com'),
        '/wallet': (context) => WalletPage(initialBalance: 5000),
        '/profile': (context) => ProfilePage(
          username: 'John Doe',
          email: 'john@example.com',
          phone: '9876543210',
          aadhaar: '123412341234',
        ),
        '/createCampaign': (context) => CreateCampaignPage(),
      },
      // Use onGenerateRoute to handle arguments like Campaign
      onGenerateRoute: (settings) {
        if (settings.name == '/invest') {
          final camp = settings.arguments as model.Campaign;
          return MaterialPageRoute(
            builder: (context) => InvestPage(campaign: camp),
          );
        }
        return null;
      },
    );
  }
}
