import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:care_connect_app/services/api_service.dart';
import '../../models/package_model.dart';
import 'package:care_connect_app/config/theme/app_theme.dart';
import 'package:care_connect_app/widgets/app_bar_helper.dart';
import 'package:care_connect_app/widgets/responsive_container.dart';

class StripeCheckoutPage extends StatefulWidget {
  final PackageModel package;
  final String? userId;
  final String? stripeCustomerId;
  final bool fromPortal;
  const StripeCheckoutPage({
    super.key,
    required this.package,
    this.userId,
    this.stripeCustomerId,
    this.fromPortal = false,
  });

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
      print('🔍 Using userId: ${widget.userId ?? '0'}');
      print(
        '🔍 Using stripeCustomerId: ${widget.stripeCustomerId ?? 'not provided'}',
      );

      final requestBody = {
        'plan': widget.package.name, // Send actual plan name from API
        'userId':
            widget.userId ?? '0', // Use provided userId or fallback to '0'
        'amount': widget.package.priceCents
            .toString(), // Send the actual amount
      };

      // Add portal parameter if coming from subscription management
      if (widget.fromPortal) {
        requestBody['portal'] = 'update';
      }

      // Add stripeCustomerId to request only if it's available
      if (widget.stripeCustomerId != null &&
          widget.stripeCustomerId!.isNotEmpty) {
        requestBody['stripeCustomerId'] = widget.stripeCustomerId!;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}subscriptions/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: requestBody,
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
        appBar: AppBarHelper.createAppBar(context, title: 'Checkout'),
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
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.package.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.package.description),
              const SizedBox(height: 24),
              Text(
                '\$${(widget.package.priceCents / 100).toStringAsFixed(2)} / mo',
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppTheme.primaryButtonStyle,
                  onPressed: _isProcessing ? null : _pay,
                  child: _isProcessing
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
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
      ),
    );
  }
}
