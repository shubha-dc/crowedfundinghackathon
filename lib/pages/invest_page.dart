import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crowedfundinghackathon/models/campaign.dart';

class InvestPage extends StatefulWidget {
  final Campaign campaign;
  final String aadharId;

  const InvestPage({Key? key, required this.campaign, required this.aadharId})
    : super(key: key);

  @override
  State<InvestPage> createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  final TextEditingController _amountController = TextEditingController();
  double walletBalance = 5000;
  bool _animateCircle = false;

  // Data fetched from API
  String? farmerName;
  int? farmerConfidence;
  double? campaignRiskScore;
  String? campaignAiAdvice;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _animateCircle = true;
      });
    });
    fetchCampaignDetails();
  }

  Future<void> fetchCampaignDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://python-route-nova-official.apps.hackathon.francecentral.aroapp.io/dashboard/dashboard?aadhar_id=${widget.campaign.farmerAadharId}',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final farmerData = jsonData['farmer_data'];
        final List projects = jsonData['projects'];

        final project = projects.firstWhere(
          (proj) => proj['project_id'].toString() == widget.campaign.id,
        );

        setState(() {
          farmerName = farmerData['name'];
          farmerConfidence = farmerData['confidence_score'];
          campaignRiskScore = project['project_score'] != null
              ? project['project_score'].toDouble()
              : null;
          campaignAiAdvice = project['score_reasoning'];
        });
      } else {
        print('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
    }
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

  void _invest() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showToast('Enter valid amount');
      return;
    }
    if (amount > walletBalance) {
      _showToast('Insufficient wallet balance');
      return;
    }
    if ((widget.campaign.raisedAmount + amount) > widget.campaign.goalAmount) {
      _showToast('Investment exceeds campaign goal');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Confirm Investment"),
        content: Text(
          "Are you sure you want to invest ₹${amount.toStringAsFixed(2)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeInvestment(amount);
            },
            child: Text("Yes"),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeInvestment(int amount) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://python-route-nova-official.apps.hackathon.francecentral.aroapp.io/invest_in_project/',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'aadhar_id': widget.campaign.farmerAadharId,
          'project_id': int.parse(widget.campaign.id),
          'amount': amount.toInt(),
          'investor_aadhar_id': widget.aadharId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] != null) {
          setState(() {
            walletBalance -= amount;
            widget.campaign.raisedAmount += amount;
          });
          _showToast(
            'Invested ₹${amount.toStringAsFixed(2)} in "${widget.campaign.title}"',
          );
          Navigator.pop(context);
        } else {
          _showToast('Investment failed');
        }
      } else {
        String errorMsg = 'Investment failed';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['error'] != null) errorMsg = errorBody['error'];
        } catch (_) {}
        _showToast(errorMsg);
      }
    } catch (e) {
      _showToast('Error: $e');
    }
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
      appBar: AppBar(title: Text('Invest in Campaign')),
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
                'Risk Level: $riskLevel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'Description: $description',
                style: TextStyle(color: Colors.grey[800]),
              ),
              SizedBox(height: 20),
              if (campaignRiskScore != null)
                Text(
                  'Campaign Risk Score: ${campaignRiskScore!.toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              if (farmerName != null) Text('Farmer Name: $farmerName'),
              if (farmerConfidence != null)
                Text('Farmer Confidence Score: $farmerConfidence%'),
              if (campaignAiAdvice != null)
                Text('Campaign AI Advice: $campaignAiAdvice'),
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
                  labelText: 'Investment Amount',
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
              isFullyFunded ? 'Campaign Fully Funded' : 'Invest',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
