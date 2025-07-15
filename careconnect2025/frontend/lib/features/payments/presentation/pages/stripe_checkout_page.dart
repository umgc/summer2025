import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:care_connect_app/services/api_service.dart';
import '../../models/package_model.dart';

class StripeCheckoutPage extends StatefulWidget {
  final PackageModel package;
  const StripeCheckoutPage({super.key, required this.package});

  @override
  State<StripeCheckoutPage> createState() => _StripeCheckoutPageState();
}

class _StripeCheckoutPageState extends State<StripeCheckoutPage> {
  bool _isProcessing = false;
  String? _status;

  bool get isIOS13OrLower {
    if (kIsWeb) return false; // Never block on web
    if (!Platform.isIOS) return false;
    final version = Platform.operatingSystemVersion;
    final match = RegExp(r'(\d+)\.(\d+)').firstMatch(version);
    if (match != null) {
      final major = int.tryParse(match.group(1) ?? '0') ?? 0;
      return major < 14;
    }
    return false;
  }

  Future<void> _pay() async {
    setState(() {
      _isProcessing = true;
      _status = null;
    });

    try {
      // For registration flow, we don't need user authentication
      // We can create checkout session with just the package information
      print('🔍 Sending plan: ${widget.package.name}');
      print('🔍 Sending amount: ${widget.package.priceCents}');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}subscriptions/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'plan': widget.package.name, // Send actual plan name from API
          'userId': '0', // Temporary userId for registration flow
          'amount': widget.package.priceCents
              .toString(), // Send the actual amount
        },
      );

      print('🔍 Stripe checkout response: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['checkoutUrl'] != null) {
        final checkoutUrl = data['checkoutUrl'];
        print('✅ Launching checkout URL: $checkoutUrl');

        if (await canLaunchUrl(Uri.parse(checkoutUrl))) {
          await launchUrl(
            Uri.parse(checkoutUrl),
            mode: LaunchMode.externalApplication,
          );
          setState(() {
            _status = 'Redirected to Stripe Checkout.';
          });
        } else {
          setState(() {
            _status = 'Could not launch Stripe Checkout URL.';
          });
        }
      } else {
        print('❌ Checkout failed: ${data['error'] ?? 'Unknown error'}');
        setState(() {
          _status = data['error'] ?? 'Failed to create checkout session.';
        });
      }
    } catch (e) {
      print('🚨 Exception during checkout: $e');
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isIOS13OrLower) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF14366E),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'Stripe payments require iOS 14 or higher.',
            style: TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.package.name} Checkout',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF14366E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.package.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF14366E),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.package.description),
            const SizedBox(height: 24),
            Text(
              '\$${(widget.package.priceCents / 100).toStringAsFixed(2)} / mo',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF14366E),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF14366E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isProcessing ? null : _pay,
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Pay with Stripe'),
              ),
            ),
            if (_status != null) ...[
              const SizedBox(height: 24),
              Text(
                _status!,
                style: TextStyle(
                  color: _status!.contains('successful')
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
