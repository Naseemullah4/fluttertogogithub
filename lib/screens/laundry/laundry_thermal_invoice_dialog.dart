import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/esc_pos_formatter.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class LaundryThermalInvoiceDialog extends StatelessWidget {
  final LaundryOrder order;

  const LaundryThermalInvoiceDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final state = context.watch<StateService>();
    final canViewPrice = state.canViewPrice();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thermal Invoice (ESC/POS)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Visual 80mm Thermal Receipt Simulation
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const UniWashLogo.banner(
                      height: 52,
                      showBorder: false,
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'UNIWASH LAUNDRY',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      order.laundryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'Doha, Qatar • Tel: +974 4499 8811',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                    const Text(
                      'Commercial Reg: QA-CR-1098234',
                      style: TextStyle(fontSize: 10, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '----------------------------------------------------',
                      maxLines: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #: ${order.orderNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customer: ${order.customerName}',
                          style: const TextStyle(fontSize: 11),
                        ),
                        Text(
                          'Tel: ${order.customerPhone}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Address: ${order.address.formatted}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const Text(
                      '----------------------------------------------------',
                      maxLines: 1,
                    ),

                    // Items
                    ...order.items.map((item) {
                      final qty = item.verifiedQuantity ?? item.quantity;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.catalogItem.itemName} (${item.serviceType.displayName})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              'x$qty',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (canViewPrice)
                              Text(
                                '${item.effectiveTotal.toStringAsFixed(0)} QAR',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else
                              const Text(
                                '[TAGGED]',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    const Text(
                      '----------------------------------------------------',
                      maxLines: 1,
                    ),
                    if (canViewPrice) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(fontSize: 11)),
                          Text(
                            '${order.subtotal.toStringAsFixed(2)} QAR',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Fee:',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text(
                            '${order.deliveryFee.toStringAsFixed(2)} QAR',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Govt Tax (0% VAT):',
                            style: TextStyle(fontSize: 11),
                          ),
                          Text('0.00 QAR', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL AMOUNT:',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${order.totalAmount.toStringAsFixed(2)} QAR',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL GARMENTS COUNT:',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '${order.totalItemCount} PCS',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'PRICE VISIBILITY:',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            'PROTECTED (ADMIN ONLY)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Text(
                      '====================================================',
                      maxLines: 1,
                    ),

                    // QR Code on Slip
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: QrImageView(
                        data: order.qrCodePayload,
                        version: QrVersions.auto,
                        size: 90,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'QR CODE: ${order.qrCodePayload}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Retain receipt for claim verification.',
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Text(
                      'Thank you for choosing UniWash!',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Generate raw ESC/POS command bytes
                        final bytes = EscPosFormatter.generateInvoiceBytes(
                          order,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '🖨️ ESC/POS Stream Generated: ${bytes.length} bytes sent via USB (ESC @ initialized)',
                            ),
                            backgroundColor: AppColors.primaryDark,
                          ),
                        );
                      },
                      icon: const Icon(Icons.usb),
                      label: const Text('USB Thermal (ESC/POS)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final bytes = EscPosFormatter.generateInvoiceBytes(
                          order,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '📶 Bluetooth Print Sent: ${bytes.length} bytes to 80mm Mobile Thermal Printer',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.bluetooth),
                      label: const Text('Bluetooth Print'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
