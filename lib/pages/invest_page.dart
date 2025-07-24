import 'package:crowedfundinghackathon/models/campaign.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InvestPage extends StatefulWidget {
  final Campaign campaign;
  final String aadharId;

  const InvestPage({Key? key, required this.campaign, required this.aadharId}) : super(key: key);

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final TextEditingController _amountController = TextEditingController();
  double walletBalance = 5000; // Replace with real wallet balance in real app

  void _invest() async {
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

    // TODO: Replace with actual aadhar_id and investor_account from user session/profile
    String aadharId = widget.aadharId; // Placeholder
    // int investorAccount = 1; // Placeholder

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/invest_in_project'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aadhar_id': widget.campaign.farmerAadharId,
          'project_id': int.parse(widget.campaign.id),
          'amount': amount.toInt(),
          'investor_account': aadharId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] != null) {
          setState(() {
            walletBalance -= amount;
            widget.campaign.raisedAmount += amount;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Investment failed')),
          );
        }
      } else {
        String errorMsg = 'Investment failed';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['error'] != null) {
            errorMsg = errorBody['error'];
          }
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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
