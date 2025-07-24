import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crowedfundinghackathon/models/campaign.dart';
import 'package:crowedfundinghackathon/pages/app_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'invest_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String userEmail;
  final String aadharId; // <-- add this

  const HomePage({Key? key, required this.username, required this.userEmail, required this.aadharId})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Campaign> campaigns = [];
  bool isLoading = true;
  String? errorMsg;

  double walletBalance = 5000;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/get_projects/all'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['projects'] != null && data['projects'] is List) {
          campaigns = (data['projects'] as List)
              .map((item) => Campaign(
            id: item['project_id'].toString(),
            title: item['name'] ?? '',
            description: item['description'] ?? '',
            goalAmount: (item['amount_needed'] ?? 0).toDouble(),
            raisedAmount: (item['amount_raised'] ?? 0).toDouble(),
            farmerAadharId: item['farmer_aadhar_id'] ?? '',
          ))
              .toList();
        } else {
          campaigns = [];
        }
      } else {
        errorMsg = 'Failed to load projects';
      }
    } catch (e) {
      errorMsg = 'Error: $e';
    }
    setState(() {
      isLoading = false;
    });
  }

  // Hamburger menu drawer
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
  List<PieChartSectionData> _getPieChartSections() {
    final data = [
      {'title': 'Investment', 'value': 50.0, 'color': Colors.blue},
      {'title': 'Borrowing', 'value': 50.0, 'color': Colors.red},
    ];

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        color: item['color'] as Color,
        value: item['value'] as double,
        title: '${item['value']}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched ? _buildBadge(item['title'].toString()) : null,
        badgePositionPercentageOffset: .98,
      );
    }).toList();
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
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvestPage(
                        campaign: campaign,
                        aadharId: widget.aadharId, // <-- pass it here
                      ),
                    ),
                  );
                },
                child: Text('Invest'),
              ),
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
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _getPieChartSections(),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
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
