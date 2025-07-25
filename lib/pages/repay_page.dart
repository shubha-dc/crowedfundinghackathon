import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crowedfundinghackathon/models/campaign.dart';
import 'package:crowedfundinghackathon/pages/app_scaffold.dart';

class RepayPage extends StatefulWidget {
  final String username;
  final String userEmail;

  const RepayPage({Key? key, required this.username, required this.userEmail})
      : super(key: key);

  @override
  State<RepayPage> createState() => _RepayPageState();
}

class _RepayPageState extends State<RepayPage> {
  final List<Campaign> campaigns = [
    Campaign(
      id: '1',
      title: 'Buy seeds for wheat',
      description: 'Help this farmer buy quality seeds to increase yield',
      goalAmount: 10000,
      raisedAmount: 2500,
      sourcePercentage: 10,
      sourceDescription: 'Low risk',
    ),
    Campaign(
      id: '2',
      title: 'Irrigation system setup',
      description: 'Fund the setup of an efficient irrigation system',
      goalAmount: 20000,
      raisedAmount: 15000,
      sourcePercentage: 58,
      sourceDescription: 'Medium risk',
    ),
  ];

  double walletBalance = 5000;
  int touchedIndex = -1;

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.username),
            accountEmail: Text(widget.userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.username.isNotEmpty
                    ? widget.username[0].toUpperCase()
                    : '?',
                style: TextStyle(fontSize: 40.0, color: Colors.blue),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.campaign),
            title: Text('My Campaigns'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/myCampaigns');
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Wallet'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/wallet');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildCampaignCard(Campaign campaign) {
    double progress = (campaign.raisedAmount / campaign.goalAmount).clamp(0.0, 1.0);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 6),
            Text(campaign.description),
            SizedBox(height: 12),
            LinearProgressIndicator(value: progress, minHeight: 8),
            SizedBox(height: 6),
            Text(
              'Raised ₹${campaign.raisedAmount.toStringAsFixed(0)} of ₹${campaign.goalAmount.toStringAsFixed(0)}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.monetization_on),
                  label: Text('Repay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/payment', arguments: campaign);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text('AgroFund'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.username.isNotEmpty
                    ? widget.username[0].toUpperCase()
                    : '?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            tooltip: 'Wallet: ₹${walletBalance.toStringAsFixed(0)}',
            onPressed: () {
              Navigator.pushNamed(context, '/wallet');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
          campaigns.isEmpty
                ? Center(child: Text('No active campaigns.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) =>
                        _buildCampaignCard(campaigns[index]),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createCampaign'),
        tooltip: 'Create Campaign',
        child: Icon(Icons.add),
      ),
    );
  }
}