import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/state_service.dart';
import '../../models/catalog_item.dart';
import '../../models/order_item.dart';
import '../../theme/app_colors.dart';
import 'address_picker_sheet.dart';
import '../../widgets/uniwash_logo.dart';

class CartSheet extends StatefulWidget {
  final VoidCallback onOrderPlaced;

  const CartSheet({super.key, required this.onOrderPlaced});

  @override
  State<CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<CartSheet> {
  String _paymentMethod = 'pos_card'; // 'pos_card', 'cash'
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final cart = state.cart;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_basket_outlined, size: 48, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Laundry Basket is Empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Add clothing items, traditional thobes, or bedding from the catalog.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const UniWashLogo.badge(size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Laundry Basket (${cart.length} items)',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textDark),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => state.clearCart(),
                      child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
                const Divider(),
                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(item.catalogItem.icon, style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.catalogItem.itemName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  if (item.catalogItem.itemNameAr.isNotEmpty) ...[
                                    Text(
                                      item.catalogItem.itemNameAr,
                                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.primary),
                                    ),
                                  ],
                                  Text(
                                    '${item.serviceType.displayName} • ${item.unitPrice.toStringAsFixed(0)} QAR ${item.catalogItem.pricingUnit.shortLabel}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                  if (item.notes.isNotEmpty) ...[
                                    Text(
                                      'Note: "${item.notes}"',
                                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.primary),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () {
                                    final step = item.catalogItem.pricingUnit == PricingUnit.kg ? 0.5 : 1.0;
                                    state.updateCartQuantityOrWeight(index, item.quantityOrWeight - step);
                                  },
                                ),
                                Container(
                                  constraints: const BoxConstraints(minWidth: 44),
                                  alignment: Alignment.center,
                                  child: Text(
                                    item.quantityFormatted,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    final step = item.catalogItem.pricingUnit == PricingUnit.kg ? 0.5 : 1.0;
                                    state.updateCartQuantityOrWeight(index, item.quantityOrWeight + step);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${item.effectiveTotal.toStringAsFixed(0)} QAR',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                // Address summary & change
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddressPickerSheet(
                        currentAddress: state.selectedAddress,
                        onSaved: (addr) => state.updateAddress(addr),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Delivery Address', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              Text(
                                state.selectedAddress.formatted,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Payment Method Selector
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _paymentMethod = 'pos_card'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'pos_card' ? AppColors.primaryLight.withValues(alpha: 0.12) : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _paymentMethod == 'pos_card' ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.credit_card, size: 18, color: _paymentMethod == 'pos_card' ? AppColors.primary : AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                'POS Card on Delivery',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _paymentMethod == 'pos_card' ? FontWeight.w700 : FontWeight.w500,
                                  color: _paymentMethod == 'pos_card' ? AppColors.primaryDark : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _paymentMethod = 'cash'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'cash' ? AppColors.primaryLight.withValues(alpha: 0.12) : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _paymentMethod == 'cash' ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payments_outlined, size: 18, color: _paymentMethod == 'cash' ? AppColors.primary : AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                'Cash on Delivery',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _paymentMethod == 'cash' ? FontWeight.w700 : FontWeight.w500,
                                  color: _paymentMethod == 'cash' ? AppColors.primaryDark : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Cost Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal', style: TextStyle(color: AppColors.textMuted)),
                    Text('${state.cartSubtotal.toStringAsFixed(2)} QAR', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Fee (Door-to-door)', style: TextStyle(color: AppColors.textMuted)),
                    Text('15.00 QAR', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(
                      '${state.cartTotal.toStringAsFixed(2)} QAR',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final order = state.placeOrder(
                        paymentMethod: _paymentMethod,
                        specialInstructions: _notesController.text.trim(),
                      );
                      Navigator.pop(context);
                      widget.onOrderPlaced();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 Order #${order.orderNumber} placed! Pickup driver is being assigned.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Confirm Order & Generate QR Code', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
    );
  }
}
