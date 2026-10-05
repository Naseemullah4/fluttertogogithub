import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/catalog_item.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../laundry/laundry_thermal_invoice_dialog.dart';
import '../../widgets/uniwash_logo.dart';

class OrderDetailDialog extends StatelessWidget {
  final LaundryOrder order;

  const OrderDetailDialog({super.key, required this.order});

  static void show(BuildContext context, LaundryOrder order) {
    showDialog(
      context: context,
      builder: (ctx) => OrderDetailDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<StateService>(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 780),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              children: [
                const UniWashLogo.badge(size: 38),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: order.status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(order.status.icon, color: order.status.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order #${order.orderNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.status.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: order.status.color.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              order.status.displayName,
                              style: TextStyle(color: order.status.color, fontWeight: FontWeight.w700, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Placed at: ${dateFormat.format(order.createdAt)} • Lifetime Archive ID: ${order.id}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => LaundryThermalInvoiceDialog(order: order),
                    );
                  },
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('Print Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 28),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer & Assignment Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.person_outline, size: 16, color: AppColors.primary),
                                    SizedBox(width: 6),
                                    Text('Customer Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_iphone, size: 13, color: Colors.black45),
                                    const SizedBox(width: 4),
                                    Text(order.customerPhone, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.address.formatted,
                                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Facility & Driver Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.local_shipping_outlined, size: 16, color: Color(0xFF2563EB)),
                                    SizedBox(width: 6),
                                    Text('Laundry & Dispatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.storefront, size: 14, color: Colors.black45),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        order.laundryName,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.sports_motorsports_outlined, size: 14, color: Colors.black45),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Driver: ${order.assignedDriverName}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                if (order.assignedDriverPhone.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20, top: 2),
                                    child: Text(order.assignedDriverPhone, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Order Items Table
                    const Text('Itemized Garment Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                            ),
                            child: const Row(
                              children: [
                                Expanded(flex: 3, child: Text('Garment / Service', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                Expanded(flex: 2, child: Text('Pricing Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                Expanded(flex: 2, child: Text('Qty / Weight', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                Expanded(flex: 2, child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                Expanded(flex: 2, child: Text('Subtotal', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                              ],
                            ),
                          ),
                          ...order.items.asMap().entries.map((entry) {
                            final item = entry.value;
                            final isEven = entry.key % 2 == 0;
                            return Container(
                              color: isEven ? Colors.white : const Color(0xFFFAFAFA),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Text(item.catalogItem.icon, style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.catalogItem.itemName,
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                              ),
                                              Text(
                                                item.serviceType.displayName,
                                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: item.catalogItem.pricingUnit == PricingUnit.kg ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.catalogItem.pricingUnit.unitName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: item.catalogItem.pricingUnit == PricingUnit.kg ? const Color(0xFF92400E) : const Color(0xFF0369A1),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.verifiedQuantity ?? item.quantity} ${item.catalogItem.pricingUnit.unitName}',
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      state.formatCurrency(item.unitPrice),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      state.formatCurrency(item.effectiveTotal),
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    if (order.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.sticky_note_2_outlined, size: 16, color: Color(0xFFB45309)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Customer Instructions: ${order.specialInstructions}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Totals & Payment Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Payment Method: ', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    Text(order.paymentMethod.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: order.paymentStatus == 'paid' ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        order.paymentStatus.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 10,
                                          color: order.paymentStatus == 'paid' ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Count Verified: ${order.isCountVerifiedByLaundry ? "YES (By Laundry)" : "PENDING VERIFICATION"}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: order.isCountVerifiedByLaundry ? AppColors.success : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Subtotal: ${state.formatCurrency(order.subtotal)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              Text('Delivery Fee: ${state.formatCurrency(order.deliveryFee)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ${state.formatCurrency(order.totalAmount)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
