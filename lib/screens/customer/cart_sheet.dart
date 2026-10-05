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
  String _paymentMethod = 'pos_card'; // 'wallet', 'pos_card', 'cash'
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  double _appliedDiscountPercent = 0.0;
  String? _appliedPromoCode;

  @override
  void dispose() {
    _notesController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'EID25' || clean == 'RAMADAN25') {
      setState(() {
        _appliedDiscountPercent = 25.0;
        _appliedPromoCode = clean;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Promo "$clean" applied! 25% discount activated.'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (clean == 'FIRST10' || clean == 'WELCOME10') {
      setState(() {
        _appliedDiscountPercent = 10.0;
        _appliedPromoCode = clean;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Promo "$clean" applied! 10% discount activated.'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid or expired promo code. Try EID25 or FIRST10'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final cart = state.cart;

    final subtotal = state.cartSubtotal;
    final discountAmount = subtotal * (_appliedDiscountPercent / 100.0);
    const deliveryFee = 15.0;
    final total = (subtotal - discountAmount + deliveryFee).clamp(0.0, double.infinity);

    final canPayWithWallet = state.customerWalletBalance >= total;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_basket_outlined,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Laundry Basket is Empty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add clothing items, traditional thobes, abayas, or bedding from the catalog.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Top Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const UniWashLogo.badge(size: 26),
                          const SizedBox(width: 10),
                          Text(
                            'Laundry Basket (${cart.length} items)',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => state.clearCart(),
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                        label: const Text('Clear All', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Scrollable Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      // Cart Items List
                      ...cart.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
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
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                    if (item.catalogItem.itemNameAr.isNotEmpty)
                                      Text(
                                        item.catalogItem.itemNameAr,
                                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.primary),
                                      ),
                                    Text(
                                      '${item.serviceType.displayName} • ${item.unitPrice.toStringAsFixed(0)} QAR ${item.catalogItem.pricingUnit.shortLabel}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                    if (item.notes.isNotEmpty)
                                      Text(
                                        'Note: "${item.notes}"',
                                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.primary),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      final step = item.catalogItem.pricingUnit == PricingUnit.kg ? 0.5 : 1.0;
                                      state.updateCartQuantityOrWeight(index, item.quantityOrWeight - step);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: const Icon(Icons.remove, size: 14, color: AppColors.textDark),
                                    ),
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(minWidth: 38),
                                    alignment: Alignment.center,
                                    child: Text(
                                      item.quantityFormatted,
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      final step = item.catalogItem.pricingUnit == PricingUnit.kg ? 0.5 : 1.0;
                                      state.updateCartQuantityOrWeight(index, item.quantityOrWeight + step);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.add, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${item.effectiveTotal.toStringAsFixed(0)} QAR',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),

                      // Delivery Address shortcut
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
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              const Text('Change >', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Promo Voucher Bar
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.discount_outlined, color: Color(0xFFB45309), size: 16),
                                const SizedBox(width: 6),
                                const Text(
                                  'Have a Voucher / Promo Code?',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF78350F)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.amber.shade300),
                                    ),
                                    child: TextField(
                                      controller: _promoController,
                                      textCapitalization: TextCapitalization.characters,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter code (e.g. EID25)',
                                        hintStyle: TextStyle(fontSize: 11),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFB45309),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _applyPromo(_promoController.text),
                                  child: const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            if (_appliedPromoCode != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFF047857), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Code "$_appliedPromoCode" active (${_appliedDiscountPercent.toStringAsFixed(0)}% Off)',
                                    style: const TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Payment Method Selector (Wallet, POS Card, Cash)
                      const Text(
                        'Select Payment Method',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),

                      // Wallet Option
                      InkWell(
                        onTap: () {
                          if (canPayWithWallet) {
                            setState(() => _paymentMethod = 'wallet');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚠️ Insufficient wallet balance (${state.formatCurrency(state.customerWalletBalance)}). Top up in Profile or choose Card/Cash.'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: _paymentMethod == 'wallet'
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _paymentMethod == 'wallet' ? AppColors.primary : AppColors.border,
                              width: _paymentMethod == 'wallet' ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: _paymentMethod == 'wallet' ? AppColors.primary : AppColors.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('UniWash Digital Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text(
                                      'Available Balance: ${state.formatCurrency(state.customerWalletBalance)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: canPayWithWallet ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_paymentMethod == 'wallet')
                                const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      ),

                      // POS Card and Cash Row
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _paymentMethod = 'pos_card'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
                                    Icon(Icons.credit_card, size: 16, color: _paymentMethod == 'pos_card' ? AppColors.primary : AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Card on Delivery',
                                      style: TextStyle(
                                        fontSize: 11,
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
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
                                    Icon(Icons.payments_outlined, size: 16, color: _paymentMethod == 'cash' ? AppColors.primary : AppColors.textMuted),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Cash on Delivery',
                                      style: TextStyle(
                                        fontSize: 11,
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

                      const SizedBox(height: 14),

                      // Special Laundry Instructions
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Special instructions for driver & laundry (optional)...',
                          hintStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.note_alt_outlined, size: 18),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Cost Summary
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                Text('${subtotal.toStringAsFixed(2)} QAR', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                            if (discountAmount > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Promo Discount (${_appliedPromoCode ?? ''})', style: const TextStyle(color: AppColors.success, fontSize: 12)),
                                  Text('-${discountAmount.toStringAsFixed(2)} QAR', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 12)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Door-to-Door Delivery Fee', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                Text('15.00 QAR', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Due / Payable', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                                Text(
                                  '${total.toStringAsFixed(2)} QAR',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Pinned Bottom Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
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
                        child: Text(
                          _paymentMethod == 'wallet'
                              ? 'Pay with Wallet & Place Order'
                              : 'Confirm Order & Request Pickup',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
