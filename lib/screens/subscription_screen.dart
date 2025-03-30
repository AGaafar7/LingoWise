import 'package:flutter/material.dart';
import 'package:lingowise/services/payment_result.dart';
import 'package:lingowise/services/subscription_service.dart';
import 'package:pay/pay.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subscriptionService = SubscriptionService();
  SubscriptionPackage? _selectedPackage;
  bool _isLoading = false;
  final List<PaymentItem> _paymentItems = [];

  @override
  void initState() {
    super.initState();
    _initializeSubscriptionService();
  }

  Future<void> _initializeSubscriptionService() async {
    await _subscriptionService.initialize();
    setState(() {});
  }

  void _selectPackage(SubscriptionPackage package) {
    setState(() {
      _selectedPackage = package;
      _updatePaymentItems();
    });
  }

  void _updatePaymentItems() {
    if (_selectedPackage == null) return;

    _paymentItems.clear();
    _paymentItems.add(
      PaymentItem(
        label: _selectedPackage!.name,
        amount: _selectedPackage!.price.toString(),
        status: PaymentItemStatus.final_price,
      ),
    );
  }

  Future<void> _handlePayment(Map<String, dynamic> result) async {
    if (_selectedPackage == null) return;

    setState(() => _isLoading = true);

    try {
      final status = result['status'] == 'success'
          ? PaymentStatus.success
          : PaymentStatus.failure;

      if (status == PaymentStatus.success) {
        await _subscriptionService.addUnits(_selectedPackage!.units);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        throw Exception('Payment failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing payment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPaymentButtons() {
    if (_selectedPackage == null || _selectedPackage!.isFree) {
      return ElevatedButton(
        onPressed: () => _handlePayment({'status': 'success'}),
        child: const Text('Get Free Plan'),
      );
    }

    return Column(
      children: [
        GooglePayButton(
          paymentConfiguration: PaymentConfiguration.fromJsonString(
            '''{
              "provider": "google_pay",
              "data": {
                "environment": "TEST",
                "apiVersion": 2,
                "apiVersionMinor": 0,
                "merchantInfo": {
                  "merchantId": "BCR2DN4T27NY7HB4",
                  "merchantName": "lingowise"
                },
                "allowedPaymentMethods": [
                  {
                    "type": "CARD",
                    "data": {
                      "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
                      "allowedCardNetworks": ["VISA", "MASTERCARD"]
                    }
                  }
                ]
              }
            }''',
          ),
          paymentItems: _paymentItems,
          onPaymentResult: _handlePayment,
        ),
        const SizedBox(height: 8),
        ApplePayButton(
          paymentConfiguration: PaymentConfiguration.fromJsonString(
            '''{
              "provider": "apple_pay",
              "data": {
                "merchantIdentifier": "merchant.com.lingowise.app",
                "displayName": "LingoWise",
                "merchantCapabilities": ["3DS", "debit", "credit"],
                "allowedPaymentNetworks": ["visa", "masterCard", "amex"]
              }
            }''',
          ),
          paymentItems: _paymentItems,
          onPaymentResult: _handlePayment,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            // Handle PayPal payment
          },
          child: const Text('Pay with PayPal'),
        ),
      ],
    );
  }

  Widget _buildPackageCard(SubscriptionPackage package) {
    final isSelected = _selectedPackage?.id == package.id;

    return Card(
      elevation: isSelected ? 4 : 1,
      color:
          isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () => _selectPackage(package),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    package.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (!package.isFree)
                    Text(
                      '\$${package.price}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(package.description),
              if (isSelected) ...[
                const SizedBox(height: 16),
                _buildPaymentButtons(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_subscriptionService.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a plan to get started',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ..._subscriptionService.packages.map(_buildPackageCard),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
