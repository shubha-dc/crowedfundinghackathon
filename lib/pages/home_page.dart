// import 'package:flutter/material.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF007AFF), // Blue background
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 16.0),
//             child: Icon(Icons.search, color: Colors.white),
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Profile + Balance
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(radius: 20, backgroundColor: Colors.white),
//                 SizedBox(height: 20),
//                 Text(
//                   '\$18,199.24',
//                   style: TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text('USD - Dollar', style: TextStyle(color: Colors.white70)),
//                 SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(child: _roundedButton("Add money")),
//                     SizedBox(width: 10),
//                     Expanded(child: _roundedButton("Exchange")),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 30),
//           // White Panel Section
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//               ),
//               child: ListView(
//                 children: [
//                   Text(
//                     "Accounts",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 10),
//                   _accountTile("40832-810-5-7000-012345", "\$18,199.24", "EUR"),
//                   _accountTile("", "36.67", "GBP"),
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Cards",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       TextButton(onPressed: () {}, child: Text("+ Add Card")),
//                     ],
//                   ),
//                   _cardTile("EUR *2330", "8,199.24"),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         selectedItemColor: Color(0xFF007AFF),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
//         ],
//       ),
//     );
//   }

//   Widget _roundedButton(String text) {
//     return ElevatedButton(
//       onPressed: () {},
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: Color(0xFF007AFF),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         padding: EdgeInsets.symmetric(vertical: 14),
//       ),
//       child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
//     );
//   }

//   Widget _accountTile(String accountNumber, String balance, String currency) {
//     return Card(
//       child: ListTile(
//         leading: Icon(Icons.account_balance_wallet),
//         title: Text('$balance $currency'),
//         subtitle: accountNumber.isNotEmpty ? Text(accountNumber) : null,
//       ),
//     );
//   }

//   Widget _cardTile(String cardLabel, String balance) {
//     return Card(
//       child: ListTile(
//         leading: Icon(Icons.credit_card),
//         title: Text(cardLabel),
//         trailing: Text('$balance EUR'),
//       ),
//     );
//   }
// }

import 'package:crowedfundinghackathon/models/campaign.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'invest_page.dart';
import 'wallet_page.dart';

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

  // Dummy wallet balance
  double walletBalance = 0;
  bool isWalletLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCampaigns();
    fetchWalletBalance();
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

  Future<void> fetchWalletBalance() async {
    setState(() {
      isWalletLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/dashboard/wallet_balance?aadhar_id=${widget.aadharId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['balance'] != null) {
          // Remove currency symbol if present
          String balanceStr = data['balance'].replaceAll(RegExp(r'[^0-9.]'), '');
          walletBalance = double.tryParse(balanceStr) ?? 0;
        }
      }
    } catch (e) {
      // Optionally handle error
    }
    setState(() {
      isWalletLoading = false;
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
            onTap: () => Navigator.pop(context), // Close drawer
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

  Widget _buildCampaignCard(Campaign campaign) {
    double progress = (campaign.raisedAmount / campaign.goalAmount).clamp(
      0.0,
      1.0,
    );
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    return Scaffold(
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
              // Open the drawer
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            // tooltip: 'Wallet: ₹${walletBalance.toStringAsFixed(0)}',
            tooltip: isWalletLoading ? 'Wallet: ...' : 'Wallet: ₹${walletBalance.toStringAsFixed(0)}',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletPage(aadharId: widget.aadharId),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(child: Text(errorMsg!))
          : campaigns.isEmpty
          ? Center(child: Text('No active campaigns.'))
          : ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) =>
                  _buildCampaignCard(campaigns[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/createCampaign'),
        child: Icon(Icons.add),
        tooltip: 'Create Campaign',
      ),
    );
  }
}
