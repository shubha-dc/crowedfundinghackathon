import 'package:flutter/material.dart';

class CardDetailsPage extends StatelessWidget {
  const CardDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Card Info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\$18,199.24",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "5436 5436 **** 6643",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "VALID DATE",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text("08/24", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Image.asset(
                      'assets/images/mastercard_logo.png',
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs: Operations & History
          DefaultTabController(
            length: 2,
            child: Expanded(
              child: Column(
                children: [
                  TabBar(
                    labelColor: Color(0xFF007AFF),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Operations"),
                      Tab(text: "History"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [_buildOperationsTab(), _buildHistoryTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsTab() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _operationTile("Top up card", Icons.arrow_downward),
        _operationTile("Payments", Icons.payment),
        _operationTile("Card output", Icons.call_made),
        _operationTile("Take all the money from the card", Icons.money_off),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Center(child: Text("No transactions yet"));
  }

  Widget _operationTile(String title, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF007AFF)),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
