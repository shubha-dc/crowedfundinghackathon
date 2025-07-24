import 'package:flutter/material.dart';

class CreateCampaignPage extends StatefulWidget {
  @override
  State<CreateCampaignPage> createState() => _CreateCampaignPageState();
}

class _CreateCampaignPageState extends State<CreateCampaignPage> {
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

  void _submitCampaign() {
    if (_formKey.currentState!.validate()) {
      final campaignData = {
        'Project Name': _projectNameController.text.trim(),
        'Project Description': _projectDescriptionController.text.trim(),
        'Amount Needed': int.parse(_amountNeededController.text.trim()),
        'Interest Rate': int.parse(_interestRateController.text.trim()),
        'Farmer Aadhaar ID': _aadharController.text.trim(),
        'Duration (Months)': int.parse(_durationController.text.trim()),
        'Crop Type': _cropTypeController.text.trim(),
        'Land Area': int.parse(_landAreaController.text.trim()),
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CampaignReviewPage(campaignData: campaignData),
        ),
      );
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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter project name' : null,
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
              ElevatedButton(
                onPressed: _submitCampaign,
                child: Text('Next: Review'),
              ),
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
            ...campaignData.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(fontSize: 16),
                  ),
                )),
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
                          )
                        ],
                      ),
                    );
                  },
                  child: Text('Submit'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
