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

class HomePage extends StatefulWidget {
  final String username;
  final String userEmail;

  const HomePage({Key? key, required this.username, required this.userEmail})
    : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample dummy campaign list
  final List<Campaign> campaigns = [
    Campaign(
      id: '1',
      title: 'Buy seeds for wheat',
      description: 'Help this farmer buy quality seeds to increase yield',
      goalAmount: 10000,
      raisedAmount: 2500,
    ),
    Campaign(
      id: '2',
      title: 'Irrigation system setup',
      description: 'Fund the setup of an efficient irrigation system',
      goalAmount: 20000,
      raisedAmount: 15000,
    ),
    // Add more campaigns here
  ];

  // Dummy wallet balance
  double walletBalance = 5000;

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
                  Navigator.pushNamed(context, '/invest', arguments: campaign);
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
            tooltip: 'Wallet: ₹${walletBalance.toStringAsFixed(0)}',
            onPressed: () {
              Navigator.pushNamed(context, '/wallet');
            },
          ),
        ],
      ),
      body: campaigns.isEmpty
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
