class PaymentRepository {
  // In real app, call your backend to create a payment intent and return clientSecret
  Future<String> createPaymentIntent(int amountCents) async {
    await Future.delayed(const Duration(seconds: 1));
    // Dummy client secret
    return 'dummy_client_secret';
  }
}
