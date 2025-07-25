import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class WalletPage extends StatefulWidget {
  final String aadharId;

  const WalletPage({Key? key, required this.aadharId}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  double? balance;
  bool isLoading = true;
  // late double balance;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://python-route-nova-official.apps.hackathon.francecentral.aroapp.io/dashboard/wallet_balance?aadhar_id=${widget.aadharId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['balance'] != null) {
          String balanceStr = data['balance'].replaceAll(RegExp(r'[^0-9.]'), '');
          balance = double.tryParse(balanceStr) ?? 0;
        }
      }
    } catch (e) {
      // Optionally handle error
    }
    setState(() {
      isLoading = false;
    });
  }

  void _addMoney() {
    // final amount = double.tryParse(_amountController.text);
    // if (amount == null || amount <= 0) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Enter a valid amount')));
    //   return;
    // }
    // setState(() {
    //   balance += amount;
    // });
    // _amountController.clear();
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text('Added ₹$amount')));
  }

  void _withdrawMoney() {
    // final amount = double.tryParse(_amountController.text);
    // if (amount == null || amount <= 0) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Enter a valid amount')));
    //   return;
    // }
    // if (amount > balance) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Insufficient balance')));
    //   return;
    // }
    // setState(() {
    //   balance -= amount;
    // });
    // _amountController.clear();
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text('Withdrew ₹$amount')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wallet')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Balance: ₹${(balance ?? 0).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addMoney,
                    icon: Icon(Icons.add),
                    label: Text('Add Money'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _withdrawMoney,
                    icon: Icon(Icons.remove),
                    label: Text('Withdraw'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
