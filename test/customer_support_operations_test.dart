import 'package:flutter_test/flutter_test.dart';
import 'package:uniwash_laundry/models/order.dart';
import 'package:uniwash_laundry/services/state_service.dart';

void main() {
  group('Customer Support Operations & Live Problem Solving Tests', () {
    late StateService state;

    setUp(() {
      state = StateService();
    });

    test('Support Agent credits courtesy compensation to customer digital wallet', () {
      final initialBalance = state.customerWalletBalance;
      const refundAmount = 50.0;
      final targetOrder = state.orders.first;

      state.compensateCustomerWallet(
        refundAmount,
        orderNumber: targetOrder.orderNumber,
        reason: 'Courtesy credit for delivery turnaround delay',
      );

      expect(state.customerWalletBalance, equals(initialBalance + refundAmount));
      expect(state.walletTransactions.first.amount, equals(refundAmount));
      expect(state.walletTransactions.first.type, equals('compensation'));
      expect(state.auditLogs.any((a) => a.entity == 'Customer Digital Wallet'), isTrue);
    });

    test('Support Agent upgrades order to VIP Express Rush turnaround', () {
      final targetOrder = state.orders.first;

      state.upgradeOrderToExpress(targetOrder.id);

      final updatedOrder = state.orders.firstWhere((o) => o.id == targetOrder.id);
      expect(updatedOrder.tags.contains('⚡ VIP Express'), isTrue);
      expect(updatedOrder.specialInstructions.contains('⚡ VIP EXPRESS RUSH TURNAROUND'), isTrue);
      expect(state.auditLogs.any((a) => a.entity == 'Order Priority Level'), isTrue);
    });

    test('Support Agent waives doorstep delivery fee and refunds 15 QAR', () {
      final targetOrder = state.orders.first;
      final initialBalance = state.customerWalletBalance;

      state.waiveDeliveryFee(targetOrder.id);

      final updatedOrder = state.orders.firstWhere((o) => o.id == targetOrder.id);
      expect(updatedOrder.tags.contains('Free Delivery Waived'), isTrue);
      expect(state.customerWalletBalance, equals(initialBalance + 15.0));
    });

    test('Support Agent updates customer delivery address on the fly', () {
      final targetOrder = state.orders.first;
      const newAddress = CustomerAddress(
        buildingNo: 'Building 44',
        streetNo: 'Lusail Marina Promenade',
        zoneNo: 'Zone 69',
        apartmentRoom: 'Apt 1204',
        city: 'Lusail',
        latitude: 25.4201,
        longitude: 51.5204,
      );

      state.updateOrderAddress(targetOrder.id, newAddress);

      final updatedOrder = state.orders.firstWhere((o) => o.id == targetOrder.id);
      expect(updatedOrder.address.buildingNo, equals('Building 44'));
      expect(updatedOrder.address.city, equals('Lusail'));
      expect(state.auditLogs.any((a) => a.entity == 'Order Destination Address'), isTrue);
    });

    test('Support Agent triggers 15-minute doorbell grace countdown and doorstep authorization', () {
      final targetOrder = state.orders.first;

      state.triggerDoorbellGraceTimer(targetOrder.id);
      state.authorizeDoorstepDropoff(targetOrder.id);

      final updatedOrder = state.orders.firstWhere((o) => o.id == targetOrder.id);
      expect(updatedOrder.specialInstructions.contains('Doorbell Grace Alert'), isTrue);
      expect(updatedOrder.specialInstructions.contains('SAFE CONTACTLESS DOORSTEP DROP-OFF'), isTrue);
      expect(updatedOrder.tags.contains('Safe Doorstep Authorized'), isTrue);
    });

    test('Support Agent binds emergency replacement QR tag to order', () {
      final targetOrder = state.orders.first;
      const newPayload = 'UNIWASH-EMERGENCY-QR-REPLACEMENT-9941';

      state.replaceOrderQrPayload(
        targetOrder.id,
        newPayload,
        reason: 'Physical tag ripped in transit',
      );

      final updatedOrder = state.orders.firstWhere((o) => o.id == targetOrder.id);
      expect(updatedOrder.qrCodePayload, equals(newPayload));
      expect(updatedOrder.tags.contains('Emergency QR Replaced'), isTrue);
    });

    test('Support Agent dispatches audible radio ping to driver in transit', () {
      final driver = state.drivers.first;
      final targetOrder = state.orders.first;

      state.dispatchRadioPingToDriver(
        driver.id,
        message: 'Support Agent requesting ETA update',
        orderNumber: targetOrder.orderNumber,
      );

      expect(state.auditLogs.any((a) => a.entity == 'Driver Dispatch Radios'), isTrue);
      expect(state.messages.any((m) => m.sender.contains('Dispatcher Radio')), isTrue);
    });

    test('Support Agent communicates with customer via Live Chat, WhatsApp, and Email', () {
      final targetOrder = state.orders.first;

      // 1. Live Chat
      state.sendCustomerDirectMessage(
        targetOrder.id,
        channel: 'Live In-App Chat',
        text: 'Hello, your driver is outside your building entrance.',
      );

      // 2. WhatsApp
      state.sendCustomerDirectMessage(
        targetOrder.id,
        channel: 'WhatsApp Business',
        text: 'Order #1001 update: Your laundry has entered the steam press phase.',
      );

      // 3. Official Email
      state.sendCustomerDirectMessage(
        targetOrder.id,
        channel: 'Official Email',
        text: 'Your tax invoice and delivery confirmation are attached.',
        recipientEmail: 'customer@example.com',
      );

      // 4. Phone Call Log
      state.logCustomerContact(
        targetOrder.id,
        channel: 'Phone Call (+974)',
        outcome: 'Confirmed Pieces & Delivery Slot',
        notes: 'Customer answered promptly and confirmed delivery at 5:00 PM.',
      );

      final updatedOrder = state.orders.firstWhere((o) => o.id == targetOrder.id);
      expect(updatedOrder.customerContactNotes.length, greaterThanOrEqualTo(4));
      expect(updatedOrder.customerContactNotes.any((n) => n.contains('Live In-App Chat')), isTrue);
      expect(updatedOrder.customerContactNotes.any((n) => n.contains('WhatsApp Business')), isTrue);
      expect(updatedOrder.customerContactNotes.any((n) => n.contains('Official Email')), isTrue);
      expect(updatedOrder.customerContactNotes.any((n) => n.contains('Phone Call (+974)')), isTrue);

      expect(state.messages.any((m) => m.text.contains('Live In-App Chat')), isTrue);
      expect(state.messages.any((m) => m.text.contains('WhatsApp Business')), isTrue);
      expect(state.messages.any((m) => m.text.contains('Official Email')), isTrue);
    });
  });
}
