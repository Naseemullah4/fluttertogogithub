import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class EscPosFormatter {
  // ESC/POS Command Constants
  static const int esc = 0x1B;
  static const int gs = 0x1D;

  static List<int> initPrinter() => [esc, 0x40]; // ESC @
  static List<int> setAlignCenter() => [esc, 0x61, 0x01]; // ESC a 1
  static List<int> setAlignLeft() => [esc, 0x61, 0x00]; // ESC a 0
  static List<int> setAlignRight() => [esc, 0x61, 0x02]; // ESC a 2
  static List<int> setBoldOn() => [esc, 0x45, 0x01]; // ESC E 1
  static List<int> setBoldOff() => [esc, 0x45, 0x00]; // ESC E 0
  static List<int> doubleHeightOn() => [gs, 0x21, 0x01];
  static List<int> doubleWidthOn() => [gs, 0x21, 0x10];
  static List<int> textNormal() => [gs, 0x21, 0x00];
  static List<int> lineFeed([int n = 1]) => List.filled(n, 0x0A);
  static List<int> cutPaper() => [gs, 0x56, 0x41, 0x03]; // Full cut with feed

  /// Generates the raw byte stream conforming to standard ESC/POS protocol
  static List<int> generateInvoiceBytes(LaundryOrder order) {
    final List<int> bytes = [];

    bytes.addAll(initPrinter());

    // Header (Centered, Bold, Double Size)
    bytes.addAll(setAlignCenter());
    bytes.addAll(setBoldOn());
    bytes.addAll(doubleHeightOn());
    bytes.addAll(utf8.encode('UNIWASH LAUNDRY & DRY CLEANING\n'));
    bytes.addAll(textNormal());
    bytes.addAll(setBoldOff());
    bytes.addAll(utf8.encode('${order.laundryName}\n'));
    bytes.addAll(utf8.encode('Branch ID: ${order.laundryId} | Doha, Qatar\n'));
    bytes.addAll(utf8.encode('Tel: +974 4499 8811 | CR: 1098234-QA\n'));
    bytes.addAll(utf8.encode('================================================\n'));

    // Order Meta
    bytes.addAll(setAlignLeft());
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    bytes.addAll(utf8.encode('ORDER NO   : #${order.orderNumber}\n'));
    bytes.addAll(utf8.encode('DATE & TIME: ${dateFormat.format(order.createdAt)}\n'));
    bytes.addAll(utf8.encode('CUSTOMER   : ${order.customerName}\n'));
    bytes.addAll(utf8.encode('PHONE      : ${order.customerPhone}\n'));
    bytes.addAll(utf8.encode('ADDRESS    : ${order.address.formatted}\n'));
    bytes.addAll(utf8.encode('PAY METHOD : ${order.paymentMethod.toUpperCase()} (${order.paymentStatus.toUpperCase()})\n'));
    bytes.addAll(utf8.encode('------------------------------------------------\n'));

    // Items Table Header
    bytes.addAll(setBoldOn());
    bytes.addAll(utf8.encode(padLine('ITEM / SERVICE', 'QTY', 'PRICE', 'TOTAL')));
    bytes.addAll(utf8.encode('\n------------------------------------------------\n'));
    bytes.addAll(setBoldOff());

    // Item rows
    for (final item in order.items) {
      final qty = item.verifiedQuantity ?? item.quantity;
      final nameStr = '${item.catalogItem.itemName} (${item.serviceType.displayName})';
      final priceStr = '${item.unitPrice.toStringAsFixed(0)} QAR';
      final totStr = '${item.effectiveTotal.toStringAsFixed(0)} QAR';

      if (nameStr.length > 22) {
        bytes.addAll(utf8.encode('${nameStr.substring(0, 22)}\n'));
        bytes.addAll(utf8.encode(padLine('  ${nameStr.substring(22)}', 'x$qty', priceStr, totStr)));
      } else {
        bytes.addAll(utf8.encode(padLine(nameStr, 'x$qty', priceStr, totStr)));
      }
      bytes.addAll(utf8.encode('\n'));
    }

    bytes.addAll(utf8.encode('------------------------------------------------\n'));

    // Financial totals
    bytes.addAll(setAlignRight());
    bytes.addAll(utf8.encode('Subtotal: ${order.subtotal.toStringAsFixed(2)} QAR\n'));
    bytes.addAll(utf8.encode('Delivery Charge: ${order.deliveryFee.toStringAsFixed(2)} QAR\n'));
    bytes.addAll(setBoldOn());
    bytes.addAll(doubleHeightOn());
    bytes.addAll(utf8.encode('TOTAL AMOUNT: ${order.totalAmount.toStringAsFixed(2)} QAR\n'));
    bytes.addAll(textNormal());
    bytes.addAll(setBoldOff());
    bytes.addAll(utf8.encode('================================================\n'));

    // Barcode / QR Code Representation
    bytes.addAll(setAlignCenter());
    bytes.addAll(utf8.encode('[QR CODE: ${order.qrCodePayload}]\n'));
    bytes.addAll(utf8.encode('Scan on collection / delivery verification\n\n'));
    bytes.addAll(utf8.encode('Thank you for choosing UniWash!\n'));
    bytes.addAll(utf8.encode('Retain receipt for garment claim.\n\n'));

    // Feed and Cut
    bytes.addAll(lineFeed(4));
    bytes.addAll(cutPaper());

    return bytes;
  }

  static String padLine(String col1, String col2, String col3, String col4) {
    final c1 = col1.padRight(22);
    final c2 = col2.padRight(6);
    final c3 = col3.padRight(10);
    final c4 = col4.padLeft(10);
    return '$c1$c2$c3$c4';
  }
}
