import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final aadharController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  // Add new controllers for state and city
  final stateController = TextEditingController(); // <-- ADD THIS
  final cityController = TextEditingController();

  bool isLoading = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  String? selectedGender;
  DateTime? selectedDob;

  @override
  void dispose() {
    aadharController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    // Dispose the new controllers
    stateController.dispose(); // <-- ADD THIS
    cityController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Passwords do not match')));
      return;
    }

    if (stateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('State is required')));
      return;
    }
    if (cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('City is required')));
      return;
    }


    final body = {
      'aadhar_id': aadharController.text.trim(),
      'name': '${firstNameController.text.trim()} ${lastNameController.text.trim()}',
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'password_hash': passwordController.text.trim(),
      'state': stateController.text.trim(),
      'city': cityController.text.trim(),
    };

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/register/register_farmer'), // Replace this URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registered successfully')));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'Registration failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        selectedDob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildAadhaarField(),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: firstNameController,
                            label: 'First Name',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            controller: lastNameController,
                            label: 'Last Name',
                          ),
                        ),
                      ],
                    ),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone',
                      keyboardType: TextInputType.phone,
                    ),
                    // Add State and City fields here
                    _buildTextField( // <-- ADD THIS WIDGET
                      controller: stateController,
                      label: 'State',
                    ),
                    _buildTextField( // <-- ADD THIS WIDGET
                      controller: cityController,
                      label: 'City',
                    ),
                    _buildGenderDropdown(),
                    _buildDobPicker(),
                    _buildPasswordField(
                      controller: passwordController,
                      label: 'Password',
                      isVisible: passwordVisible,
                      toggleVisibility: () {
                        setState(() => passwordVisible = !passwordVisible);
                      },
                    ),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      isVisible: confirmPasswordVisible,
                      toggleVisibility: () {
                        setState(
                          () =>
                              confirmPasswordVisible = !confirmPasswordVisible,
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                      ),
                      child: Text('Register'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAadhaarField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: aadharController,
        keyboardType: TextInputType.number,
        maxLength: 12,
        decoration: InputDecoration(
          labelText: 'Aadhaar ID',
          border: OutlineInputBorder(),
          counterText: '',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Aadhaar ID is required';
          if (!RegExp(r'^\d{12}$').hasMatch(value)) {
            return 'Enter valid 12-digit Aadhaar';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) =>
            value == null || value.isEmpty ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: (value) =>
            value == null || value.isEmpty ? '$label is required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        value: selectedGender,
        items: ['Male', 'Female', 'Other'].map((gender) {
          return DropdownMenuItem(value: gender, child: Text(gender));
        }).toList(),
        onChanged: (value) {
          setState(() => selectedGender = value);
        },
        validator: (value) => value == null ? 'Gender is required' : null,
      ),
    );
  }

  Widget _buildDobPicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _pickDate(context),
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              border: OutlineInputBorder(),
            ),
            validator: (_) =>
                selectedDob == null ? 'Date of birth is required' : null,
            controller: TextEditingController(
              text: selectedDob == null
                  ? ''
                  : '${selectedDob!.day}/${selectedDob!.month}/${selectedDob!.year}',
            ),
          ),
        ),
      ),
    );
  }
}
