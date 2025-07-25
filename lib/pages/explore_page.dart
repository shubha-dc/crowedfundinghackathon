import 'package:flutter/material.dart';
import 'package:crowedfundinghackathon/models/campaign.dart';

class ExplorePage extends StatefulWidget {
  final List<Campaign> campaigns;

  const ExplorePage({Key? key, required this.campaigns}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  List<Campaign> _campaigns = [];

  @override
  void initState() {
    super.initState();
    _campaigns = widget.campaigns;
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate refresh
    setState(() {
      // Normally you'd fetch new data here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Explore Campaigns")),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _campaigns.isEmpty
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 100),
                  Center(child: Text('No campaigns to explore')),
                ],
              )
            : ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: _campaigns.length,
                itemBuilder: (context, index) =>
                    _buildCampaignCard(context, _campaigns[index]),
              ),
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, Campaign campaign) {
    double progress = (campaign.raisedAmount / campaign.goalAmount).clamp(
      0.0,
      1.0,
    );
    Color riskColor;

    if (campaign.sourcePercentage <= 40) {
      riskColor = Colors.green;
    } else if (campaign.sourcePercentage <= 70) {
      riskColor = Colors.amber;
    } else {
      riskColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/invest', arguments: campaign);
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: riskColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(campaign.description),
              SizedBox(height: 6),
              Text(
                'Risk Level: ${campaign.sourcePercentage}% - ${campaign.sourceDescription}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(value: progress, minHeight: 8),
              SizedBox(height: 6),
              Text(
                'Raised ₹${campaign.raisedAmount.toStringAsFixed(0)} of ₹${campaign.goalAmount.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
