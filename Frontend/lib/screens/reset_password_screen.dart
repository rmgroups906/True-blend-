import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../app_routes.dart';
import '../widgets/custom_input_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool otpSent = false;
  bool otpVerified = false;

  final String baseUrl = 'https://true-blend.in/api/java/auth';

  Future<void> sendOtp() async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneController.text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        otpSent = true;
      });
    } else {
      showError(jsonDecode(response.body)['error'] ?? 'Failed to send OTP');
    }
  }

  Future<void> verifyOtp() async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneController.text,
        'otp': otpController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        otpVerified = true;
      });
    } else {
      showError(jsonDecode(response.body)['error'] ?? 'Invalid OTP');
    }
  }

  Future<void> resetPassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      showError("Passwords do not match");
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phoneNumber': phoneController.text,
        'newPassword': newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      showError(jsonDecode(response.body)['error'] ?? 'Failed to reset password');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            const Text(
              'Reset your password',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (!otpSent) ...[
              CustomInputField(controller: phoneController, label: 'Mobile Number'),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: sendOtp,
                child: const Text('Send OTP'),
              ),
            ] else if (!otpVerified) ...[
              CustomInputField(controller: otpController, label: 'Enter OTP'),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: verifyOtp,
                child: const Text('Verify OTP'),
              ),
            ] else ...[
              CustomInputField(controller: newPasswordController, label: 'New Password', obscureText: true),
              const SizedBox(height: 16),
              CustomInputField(controller: confirmPasswordController, label: 'Confirm Password', obscureText: true),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: resetPassword,
                child: const Text('Submit'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

