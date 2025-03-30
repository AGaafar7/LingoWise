enum PaymentStatus { success, failure }

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;
  final String? errorMessage;

  PaymentResult({
    required this.status,
    this.transactionId,
    this.errorMessage,
  });
}
