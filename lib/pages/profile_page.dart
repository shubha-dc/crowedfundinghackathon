import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String phone;
  final String aadhaar;

  const ProfilePage({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
    required this.aadhaar,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isVerified = false;
  String verificationStatus = 'Not Verified';

  // Dummy verification function (in reality, integrate KYC/Aadhaar API)
  void verifyFarmer() {
    if (widget.aadhaar.length == 12) {
      setState(() {
        isVerified = true;
        verificationStatus = 'Verified';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Farmer Verified!')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invalid Aadhaar number')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile & Verification')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${widget.username}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Email: ${widget.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Phone: ${widget.phone}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Aadhaar: ${widget.aadhaar}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            Row(
              children: [
                Text('Verification Status: ', style: TextStyle(fontSize: 18)),
                Text(
                  verificationStatus,
                  style: TextStyle(
                    fontSize: 18,
                    color: isVerified ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isVerified ? null : verifyFarmer,
              child: Text('Verify Farmer (KYC / Aadhaar)'),
            ),
          ],
        ),
      ),
    );
  }
}
