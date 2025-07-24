import 'package:flutter/material.dart';
import '../models/campaign.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Text(campaign.title),
        subtitle: Text(campaign.description),
        trailing: Text('\$${campaign.goalAmount.toStringAsFixed(0)}'),
      ),
    );
  }
}
