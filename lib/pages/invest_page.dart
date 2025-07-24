import 'package:flutter/material.dart';

class InvestPage extends StatefulWidget {
  final Campaign campaign;

  const InvestPage({Key? key, required this.campaign}) : super(key: key);

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final TextEditingController _amountController = TextEditingController();
  double walletBalance = 5000; // Replace with real wallet balance in real app

  void _invest() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter valid amount')));
      return;
    }
    if (amount > walletBalance) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Insufficient wallet balance')));
      return;
    }
    if ((widget.campaign.raisedAmount + amount) > widget.campaign.goalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Investment exceeds campaign goal')),
      );
      return;
    }

    // Deduct from wallet and add to campaign raised amount
    setState(() {
      walletBalance -= amount;
      widget.campaign.raisedAmount += amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invested ₹$amount in "${widget.campaign.title}"'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaign;
    double progress = (campaign.raisedAmount / campaign.goalAmount).clamp(
      0.0,
      1.0,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Invest in Campaign')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              campaign.title,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(campaign.description),
            SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 10),
            SizedBox(height: 8),
            Text(
              'Raised ₹${campaign.raisedAmount.toStringAsFixed(0)} of ₹${campaign.goalAmount.toStringAsFixed(0)}',
            ),
            SizedBox(height: 20),
            Text('Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}'),
            SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Investment Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _invest, child: Text('Invest')),
          ],
        ),
      ),
    );
  }
}

// Dummy Campaign model for completeness
class Campaign {
  final String id;
  final String title;
  final String description;
  final double goalAmount;
  double raisedAmount;

  Campaign({
    required this.id,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
  });
}
