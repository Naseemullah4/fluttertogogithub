import 'package:flutter_test/flutter_test.dart';
import 'package:uniwash_laundry/services/state_service.dart';
import 'package:uniwash_laundry/models/user.dart';
import 'package:uniwash_laundry/models/order_item.dart';

void main() {
  group('Customer Digital Wallet & Price Visibility Restrictions', () {
    test('Price visibility restricted to Customer, Regional Admin & Super Admin only', () {
      final state = StateService();

      // Customer can view prices
      state.switchRole(UserRole.customer);
      expect(state.canViewPrice(), isTrue);
      expect(state.formatRestrictedPrice(120.0), equals('120 QAR'));

      // Regional Admin can view prices
      state.switchRole(UserRole.regionalAdmin);
      expect(state.canViewPrice(), isTrue);

      // Super Admin can view prices
      state.switchRole(UserRole.superAdmin);
      expect(state.canViewPrice(), isTrue);

      // Laundry Worker cannot view prices (hidden per business requirement)
      state.switchRole(UserRole.laundryWorker);
      expect(state.canViewPrice(), isFalse);
      expect(state.formatRestrictedPrice(120.0), equals('—'));

      // Driver cannot view prices
      state.switchRole(UserRole.driver);
      expect(state.canViewPrice(), isFalse);

      // Customer Service cannot view laundry worker raw prices
      state.switchRole(UserRole.customerService);
      expect(state.canViewPrice(), isFalse);

      // Engineer cannot view prices
      state.switchRole(UserRole.engineer);
      expect(state.canViewPrice(), isFalse);
    });

    test('Customer wallet top-up adds bonus cashback and logs transaction', () {
      final state = StateService();
      final initialBalance = state.customerWalletBalance;
      final initialTxCount = state.walletTransactions.length;

      // Top up 200 QAR with 10 QAR VIP Cashback Bonus
      state.topUpCustomerWallet(200.0, reference: 'VISA-9921', bonus: 10.0);

      expect(state.customerWalletBalance, equals(initialBalance + 210.0));
      expect(state.walletTransactions.length, equals(initialTxCount + 1));

      final latestTx = state.walletTransactions.first;
      expect(latestTx.amount, equals(210.0));
      expect(latestTx.isCredit, isTrue);
      expect(latestTx.reference, equals('VISA-9921'));
      expect(latestTx.type, equals('bonus'));
    });

    test('Customer places order with wallet payment method', () {
      final state = StateService();
      state.switchRole(UserRole.customer);

      // Ensure customer has sufficient balance
      state.topUpCustomerWallet(500.0);
      final balanceBefore = state.customerWalletBalance;

      // Add item to cart
      state.clearCart();
      final item = state.catalogItems.first;
      state.addToCart(item, ServiceType.washIron, quantityOrWeight: 2.0);

      final cartTotal = state.cartSubtotal + 15.0; // including delivery fee
      expect(state.customerWalletBalance, greaterThanOrEqualTo(cartTotal));

      // Place order with wallet
      final order = state.placeOrder(paymentMethod: 'wallet', specialInstructions: 'Slot: Express');
      expect(order.paymentMethod, equals('wallet'));
      expect(state.customerWalletBalance, closeTo(balanceBefore - order.totalAmount, 0.01));

      // Transaction log should have recorded the purchase
      final latestTx = state.walletTransactions.first;
      expect(latestTx.isCredit, isFalse);
      expect(latestTx.reference, equals('ORDER-${order.orderNumber}'));
      expect(latestTx.amount, equals(order.totalAmount));
    });
  });
}
