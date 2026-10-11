import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
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
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar Row 1: Logo + Order # + Status + Close
            Row(
              children: [
                const UniWashLogo.badge(size: 30),
                const SizedBox(width: 8),
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: BadgePill(
                    label: order.status.displayName,
                    backgroundColor: order.status.color.withValues(alpha: 0.15),
                    textColor: order.status.color,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Top Bar Row 2: Date + Print Receipt Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Placed: ${dateFormat.format(order.createdAt)}',
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => LaundryThermalInvoiceDialog(order: order),
                    );
                  },
                  icon: const Icon(Icons.print_rounded, size: 14),
                  label: const Text('Print Receipt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const Divider(height: 18),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.isUrgent)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.bolt, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🚨 URGENT ORDER: 4-HOUR EXPRESS RUSH',
                                    style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900, fontSize: 12.5),
                                  ),
                                  Text(
                                    order.scheduleSummary,
                                    style: TextStyle(color: Colors.red.shade900, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Service Timeline Bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Service Timeline: ${order.scheduleSummary}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Responsive Customer & Laundry Section
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 440;

                        final customerCard = Container(
                          padding: const EdgeInsets.all(12),
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
                                  Icon(Icons.person_outline, size: 15, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text('Customer Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.phone_iphone, size: 12, color: Colors.black45),
                                  const SizedBox(width: 4),
                                  Text(order.customerPhone, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                order.address.formatted,
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                            ],
                          ),
                        );

                        final facilityCard = Container(
                          padding: const EdgeInsets.all(12),
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
                                  Icon(Icons.local_shipping_outlined, size: 15, color: Color(0xFF2563EB)),
                                  SizedBox(width: 6),
                                  Text('Laundry & Dispatch', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.storefront, size: 13, color: Colors.black45),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      order.laundryName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.sports_motorsports_outlined,
                                    size: 13,
                                    color: order.assignedDriverId.isEmpty ? AppColors.error : Colors.black45,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      order.assignedDriverId.isEmpty
                                          ? 'Driver: Unassigned (Awaiting Admin)'
                                          : 'Driver: ${order.assignedDriverName}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: order.assignedDriverId.isEmpty ? AppColors.error : Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (order.assignedDriverPhone.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 17, top: 2),
                                  child: Text(order.assignedDriverPhone, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                ),
                            ],
                          ),
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              customerCard,
                              const SizedBox(height: 10),
                              facilityCard,
                            ],
                          );
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: customerCard),
                              const SizedBox(width: 10),
                              Expanded(child: facilityCard),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Order Items Table
                    const Text('Itemized Garment Breakdown', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 6),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                            ),
                            child: Row(
                              children: [
                                const Expanded(flex: 4, child: Text('Garment / Service', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                const Expanded(flex: 2, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                if (state.canViewPrice()) ...[
                                  const Expanded(flex: 2, child: Text('Unit', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                  const Expanded(flex: 3, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                ] else ...[
                                  const Expanded(flex: 3, child: Text('Care Tag', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF475569)))),
                                ],
                              ],
                            ),
                          ),
                          ...order.items.asMap().entries.map((entry) {
                            final item = entry.value;
                            final isEven = entry.key % 2 == 0;
                            return Container(
                              color: isEven ? Colors.white : const Color(0xFFFAFAFA),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Text(item.catalogItem.icon, style: const TextStyle(fontSize: 16)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.catalogItem.itemName,
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                item.serviceType.displayName,
                                                style: const TextStyle(fontSize: 10, color: Colors.black54),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '${item.verifiedQuantity ?? item.quantity}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                                    ),
                                  ),
                                  if (state.canViewPrice()) ...[
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        state.formatCurrency(item.unitPrice),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        state.formatCurrency(item.effectiveTotal),
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF0F172A)),
                                      ),
                                    ),
                                  ] else ...[
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Verified Tag',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.success),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    if (order.specialInstructions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.sticky_note_2_outlined, size: 14, color: Color(0xFFB45309)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Instructions: ${order.specialInstructions}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Totals & Payment Summary Card
                    Container(
                      padding: const EdgeInsets.all(12),
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
                                    Text(
                                      order.paymentMethod.toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: order.paymentStatus == 'paid' ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        order.paymentStatus.toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9,
                                          color: order.paymentStatus == 'paid' ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.isCountVerifiedByLaundry ? "Verified by Laundry" : "Pending Count Check",
                                  style: TextStyle(
                                    fontSize: 10,
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
                              if (state.canViewPrice()) ...[
                                Text('Subtotal: ${state.formatCurrency(order.subtotal)}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                Text('Delivery: ${state.formatCurrency(order.deliveryFee)}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                const SizedBox(height: 2),
                                Text(
                                  'Total: ${state.formatCurrency(order.totalAmount)}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                              ] else ...[
                                Text('Garments: ${order.totalItemCount} Items', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                const SizedBox(height: 2),
                                const Text(
                                  'Pricing Protected',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey),
                                ),
                              ],
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
