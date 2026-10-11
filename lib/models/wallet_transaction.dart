class WalletTransaction {
  final String id;
  final String title;
  final double amount;
  final bool isCredit; // true = added/refunded, false = spent
  final DateTime timestamp;
  final String reference;
  final String type; // 'top_up', 'order_payment', 'bonus', 'cashback'

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.isCredit,
    required this.timestamp,
    required this.reference,
    this.type = 'top_up',
  });
}
