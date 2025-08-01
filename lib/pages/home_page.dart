import 'package:crowedfundinghackathon/pages/Repay_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:crowedfundinghackathon/models/campaign.dart';
import 'package:crowedfundinghackathon/pages/app_scaffold.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'wallet_page.dart';
import 'explore_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String userEmail;
  final String aadharId;

  const HomePage({
    Key? key,
    required this.username,
    required this.userEmail,
    required this.aadharId,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Campaign> campaigns = [];
  bool isLoading = true;
  String? errorMsg;

  double walletBalance = 0;
  bool isWalletLoading = true;
  int touchedIndex = -1;

  String? farmerName;
  String? farmerEmail;
  bool isFarmerLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      fetchCampaigns(),
      fetchFarmerData(),
      fetchWalletBalance(),
    ]);
  }

  Future<void> fetchCampaigns() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://python-route-nova-official.apps.hackathon.francecentral.aroapp.io/get_projects/all',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['projects'] != null && data['projects'] is List) {
          final rawProjectList = data['projects'] as List;
          final fetchedCampaigns = rawProjectList
              .map(
                (item) => Campaign(
                  id: item['project_id'].toString(),
                  title: item['name'] ?? '',
                  description: item['description'] ?? '',
                  goalAmount: (item['amount_needed'] ?? 0).toDouble(),
                  raisedAmount: (item['amount_raised'] ?? 0).toDouble(),
                  farmerAadharId: item['farmer_aadhar_id'] ?? '',
                  sourcePercentage: 44,
                  sourceDescription: 'Medium',
                ),
              )
              .toList();
          setState(() {
            campaigns = fetchedCampaigns;
          });
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

  Future<void> fetchWalletBalance() async {
    setState(() {
      isWalletLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://python-route-nova-official.apps.hackathon.francecentral.aroapp.io/dashboard/wallet_balance?aadhar_id=${widget.aadharId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['balance'] != null) {
          String balanceStr = data['balance'].replaceAll(
            RegExp(r'[^0-9.]'),
            '',
          );
          walletBalance = double.tryParse(balanceStr) ?? 0;
        }
      }
    } catch (_) {}
    setState(() {
      isWalletLoading = false;
    });
  }

  Future<void> fetchFarmerData() async {
    setState(() {
      isFarmerLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'https://python-route-nova-official.apps.hackathon.francecentral.aroapp.io/dashboard/dashboard?aadhar_id=${widget.aadharId}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['farmer_data'] != null) {
          farmerName = data['farmer_data']['name'] ?? widget.username;
          farmerEmail = data['farmer_data']['email'] ?? widget.userEmail;
        }
      }
    } catch (_) {}
    setState(() {
      isFarmerLoading = false;
    });
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              isFarmerLoading ? 'Loading...' : (farmerName ?? widget.username),
            ),
            accountEmail: Text(
              isFarmerLoading ? '' : (farmerEmail ?? widget.userEmail),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (isFarmerLoading ? '' : (farmerName ?? widget.username))
                        .isNotEmpty
                    ? (farmerName ?? widget.username)[0].toUpperCase()
                    : '?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.campaign),
            title: Text('My Campaigns'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/repay');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Wallet'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletPage(aadharId: widget.aadharId),
                ),
              );
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

      return PieChartSectionData(
        color: item['color'] as Color,
        value: item['value'] as double,
        title: '${item['value']}%',
        radius: isTouched ? 60 : 50,
        titleStyle: TextStyle(
          fontSize: isTouched ? 18 : 14,
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
    double progress = (campaign.raisedAmount / campaign.goalAmount).clamp(
      0.0,
      1.0,
    );

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
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            tooltip: isWalletLoading
                ? 'Wallet: ...'
                : 'Wallet: ₹${walletBalance.toStringAsFixed(0)}',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WalletPage(aadharId: widget.aadharId),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: 160),
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Container(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _getPieChartSections(),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse?.touchedSection ==
                                          null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse!
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                      ),
                    ),
                  ),
                  campaigns.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('No active campaigns.'),
                        )
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
          ),
          Positioned(
            bottom: 20,
            left: 32,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RepayPage(
                          username: widget.username,
                          userEmail: widget.userEmail,
                        ),
                      ),
                    ),
                    child: Text('My Borrowing'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExplorePage(campaigns: campaigns),
                      ),
                    ),
                    child: Text('Explore Campaigns'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: null,
    );
  }
}
