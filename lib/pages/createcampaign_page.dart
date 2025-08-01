import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateCampaignPage extends StatefulWidget {
  const CreateCampaignPage({super.key});

  @override
  State<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  final _projectNameController = TextEditingController();
  final _projectDescriptionController = TextEditingController();
  final _amountNeededController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _aadharController = TextEditingController();
  final _durationController = TextEditingController();
  final _cropTypeController = TextEditingController();
  final _landAreaController = TextEditingController();

  @override
  void dispose() {
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _amountNeededController.dispose();
    _interestRateController.dispose();
    _aadharController.dispose();
    _durationController.dispose();
    _cropTypeController.dispose();
    _landAreaController.dispose();
    super.dispose();
  }

  Future<void> _submitCampaign() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      final campaignPayload = {
        'project_name': _projectNameController.text.trim(),
        'project_description': _projectDescriptionController.text.trim(),
        'amount_needed': int.parse(_amountNeededController.text.trim()),
        'interest_rate': int.parse(_interestRateController.text.trim()),
        'farmer_aadhar_id': _aadharController.text.trim(),
        'duration_in_months': int.parse(_durationController.text.trim()),
        'crop_type': _cropTypeController.text.trim(),
        'land_area': int.parse(_landAreaController.text.trim()),
      };

      try {
        final url = Uri.parse(
          'https://python-route-nova-official.apps.hackathon.francecentral.aroapp.io/create_project/',
        );
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(campaignPayload),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);

          Map<String, dynamic> dataForReviewPage = Map<String, dynamic>.from(
            campaignPayload,
          ); // Start with user's input

          // Add information from the backend response
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('message')) {
              dataForReviewPage['backend_message'] = responseData['message'];
            }
            if (responseData.containsKey('transaction_hash')) {
              dataForReviewPage['transaction_hash'] =
                  responseData['transaction_hash'];
            }
          }
          // Add a generic success message if specific one isn't available
          dataForReviewPage.putIfAbsent(
            'backend_message',
            () => 'Campaign submitted successfully!',
          );

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CampaignReviewPage(campaignData: dataForReviewPage),
            ),
          ).then((_) {
            _formKey.currentState?.reset();
            _projectNameController.clear();
            _projectDescriptionController.clear();
            _amountNeededController.clear();
            _interestRateController.clear();
            _aadharController.clear();
            _durationController.clear();
            _cropTypeController.clear();
            _landAreaController.clear();
          });
        } else {
          // Error Handling - this part can remain largely the same
          if (!mounted) return; // Check mounted before setState
          setState(() {
            _isLoading = false;
          });
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['detail'] ??
              errorData['message'] ??
              'Failed to create campaign. Status: ${response.statusCode}';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
        }
      } catch (e) {
        if (!mounted) return; // Check mounted before setState
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: ${e.toString()}')),
        );
      }
    } else {
      // Form is not valid
      if (_isLoading) {
        // Ensure isLoading is false if validation fails while it was true
        setState(() {
          _isLoading = false;
        });
      }

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => CampaignReviewPage(campaignData: campaignData),
      //   ),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Campaign')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _projectNameController,
                decoration: InputDecoration(labelText: 'Project Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter project name'
                    : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _projectDescriptionController,
                decoration: InputDecoration(labelText: 'Project Description'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter description' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _amountNeededController,
                decoration: InputDecoration(labelText: 'Amount Needed (₹)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _interestRateController,
                decoration: InputDecoration(labelText: 'Interest Rate (%)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v < 0) return 'Enter valid interest rate';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _aadharController,
                decoration: InputDecoration(labelText: 'Farmer Aadhaar ID'),
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.length != 12)
                    return 'Enter 12-digit Aadhaar';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(labelText: 'Duration (in months)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v <= 0) return 'Enter valid duration';
                  return null;
                },
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _cropTypeController,
                decoration: InputDecoration(labelText: 'Crop Type'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter crop type' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _landAreaController,
                decoration: InputDecoration(labelText: 'Land Area (sq ft)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v <= 0) return 'Enter valid land area';
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(onPressed: _submitCampaign, child: Text('Review')),
            ],
          ),
        ),
      ),
    );
  }
}

class CampaignReviewPage extends StatelessWidget {
  final Map<String, dynamic> campaignData;

  const CampaignReviewPage({Key? key, required this.campaignData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Campaign')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...campaignData.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cancel
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Success'),
                        content: Text('Submitted for verification'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close dialog
                              Navigator.pop(context); // Back to form
                            },
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
