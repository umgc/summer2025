/* import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateBillingDetailsScreen extends StatefulWidget {
  const UpdateBillingDetailsScreen({super.key});

  @override
  State<UpdateBillingDetailsScreen> createState() =>
      _UpdateBillingDetailsScreenState();
}

class _UpdateBillingDetailsScreenState
    extends State<UpdateBillingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameOnCardController = TextEditingController();
  String _paymentMethod = 'Credit Card';
  bool _isLoading = false;

  /// Backend URL — use 10.0.2.2 to access localhost from Android emulator
  final String backendUrl = 'http://10.0.2.2:8080/index.html';

  /// Sends billing details to the backend
  Future<bool> _sendBillingDetails() async {
    final url = Uri.parse(backendUrl);

    final Map<String, String> data = {
      'nameOnCard': _nameOnCardController.text.trim(),
      'cardNumber': _cardNumberController.text.trim(),
      'expiryDate': _expiryDateController.text.trim(),
      'cvv': _cvvController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(' Billing details uploaded successfully');
        print('Response body: ${response.body}');
        return true;
      } else {
        print(' Failed to upload. Status: ${response.statusCode}');
        print(' Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print(' Exception while sending billing details: $e');
      return false;
    }
  }

  /// UI builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Billing Details"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: "Payment Method"),
                items: ['Credit Card']
                    .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameOnCardController,
                decoration: const InputDecoration(labelText: 'Name on Card'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter cardholder name' : null,
              ),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Card Number'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter card number' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: const InputDecoration(labelText: 'MM/YY'),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter expiry' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      obscureText: true,
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter CVV' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "SAVE",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });

                    final success = await _sendBillingDetails();

                    setState(() {
                      _isLoading = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Billing details uploaded successfully'
                            : 'Failed to upload billing details'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameOnCardController.dispose();
    super.dispose();
  }
}



*/

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateBillingDetailsScreen extends StatefulWidget {
  const UpdateBillingDetailsScreen({super.key});

  @override
  State<UpdateBillingDetailsScreen> createState() => _UpdateBillingDetailsScreenState();
}

class _UpdateBillingDetailsScreenState extends State<UpdateBillingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameOnCardController = TextEditingController();
  String _paymentMethod = 'Credit Card';
  bool _isLoading = false;

  final String baseUrl = 'https://yzsebiid4c.execute-api.us-east-1.amazonaws.com';

  Future<bool> createSubscription() async {
    final url = Uri.parse('$baseUrl/billing/subscriptions');

    final Map<String, String> body = {
      'nameOnCard': _nameOnCardController.text.trim(),
      'cardNumber': _cardNumberController.text.trim(),
      'expiryDate': _expiryDateController.text.trim(),
      'cvv': _cvvController.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create subscription: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating subscription: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing & Subscription"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: "Payment Method"),
                items: ['Credit Card', 'PayPal']
                    .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              if (_paymentMethod == 'Credit Card') ...[
                TextFormField(
                  controller: _nameOnCardController,
                  decoration: const InputDecoration(labelText: 'Name on Card'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter cardholder name' : null,
                ),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Card Number'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter card number' : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: const InputDecoration(labelText: 'MM/YY'),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Enter expiry date' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: const InputDecoration(labelText: 'CVV'),
                        validator: (value) =>
                        value == null || value.isEmpty ? 'Enter CVV' : null,
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                label: const Text(
                  "SUMMIT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                //icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });

                    bool success = false;
                    if (_paymentMethod == 'Credit Card') {
                      success = await createSubscription();
                    } else {
                      success = false; // Handle PayPal or other methods here if needed
                    }

                    setState(() {
                      _isLoading = false;
                    });

                    if (success) {
                      print('Billing details uploaded successfully');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Information  uploaded  successfully')),
                      );
                    } else {
                      print('Failed to upload billing details');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update payment-subscription')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameOnCardController.dispose();
    super.dispose();
  }
}
