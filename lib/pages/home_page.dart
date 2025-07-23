import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../widgets/campaign_card.dart';

class HomePage extends StatelessWidget {
  final List<Campaign> campaigns = [
    Campaign(
      title: 'Help Build a School',
      description: 'Raising funds for a rural school.',
      goal: 10000,
    ),
    Campaign(
      title: 'Medical Aid for John',
      description: 'John needs surgery support.',
      goal: 5000,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Crowdfunding Home")),
      body: ListView.builder(
        itemCount: campaigns.length,
        itemBuilder: (context, index) =>
            CampaignCard(campaign: campaigns[index]),
      ),
    );
  }
}
