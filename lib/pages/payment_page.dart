import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crowedfundinghackathon/models/campaign.dart';

class PaymentPage extends StatefulWidget {
  final Campaign campaign;

  const PaymentPage({super.key, required this.campaign});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  double walletBalance = 5000;
  bool _animateCircle = false;

  @override
  void initState() {
    super.initState();
    // Trigger animation after build
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _animateCircle = true;
      });
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void _invest() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showToast('Enter valid amount');
      return;
    }
    if (amount > walletBalance) {
      _showToast('Insufficient wallet balance');
      return;
    }
    if ((widget.campaign.raisedAmount + amount) > widget.campaign.goalAmount) {
      _showToast('Repayment exceeds campaign borrowing');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Repayment"),
        content: Text(
          "Are you sure you want to repay ₹${amount.toStringAsFixed(2)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeRepayment(amount);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  void _finalizeRepayment(double amount) {
    setState(() {
      walletBalance -= amount;
      widget.campaign.raisedAmount += amount;
    });

    _showToast(
      'Repaid ₹${amount.toStringAsFixed(2)} in "${widget.campaign.title}"',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaign;
    final double progress = (campaign.raisedAmount / campaign.goalAmount).clamp(
      0.0,
      1.0,
    );
    final bool isFullyFunded = campaign.raisedAmount >= campaign.goalAmount;

    final int riskPercent = campaign.sourcePercentage;
    final String description = campaign.sourceDescription;

    String riskLevel;
    Color riskColor;

    if (riskPercent <= 40) {
      riskColor = Colors.green;
      riskLevel = 'Low';
    } else if (riskPercent <= 70) {
      riskColor = Colors.amber;
      riskLevel = 'Medium';
    } else {
      riskColor = Colors.red;
      riskLevel = 'High';
    }

    return Scaffold(
      appBar: AppBar(title: Text('Repay against Campaign')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 700),
                    width: _animateCircle ? 16 : 0,
                    height: _animateCircle ? 16 : 0,
                    decoration: BoxDecoration(
                      color: riskColor,
                      shape: BoxShape.circle,
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Expanded(
                    child: Text(
                      campaign.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
              Text(
                'Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Repayment Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isFullyFunded
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 4,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isFullyFunded ? null : _invest,
            child: Text(
              isFullyFunded ? 'Campaign Fully Funded' : 'Repay',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
