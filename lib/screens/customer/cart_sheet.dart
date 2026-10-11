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
  bool _isUrgent = false;
  String _selectedPickupDate = 'Today';
  String _selectedPickupSlot = '⚡ Express Pickup (Within 2 Hours)';
  String _selectedDeliveryDate = 'Tomorrow';
  String _selectedDeliverySlot = '🌆 Evening Drop-off (18:00 - 21:00)';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  double _appliedDiscountPercent = 0.0;
  bool _freeShippingApplied = false;
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
        _freeShippingApplied = false;
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
        _freeShippingApplied = false;
        _appliedPromoCode = clean;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Promo "$clean" applied! 10% discount activated.'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (clean == 'FREESHIP' || clean == 'FREEDELIVERY') {
      setState(() {
        _appliedDiscountPercent = 0.0;
        _freeShippingApplied = true;
        _appliedPromoCode = clean;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Promo "$clean" applied! Door-to-Door Delivery is FREE.'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Invalid promo code. Try EID25, WELCOME10, or FREESHIP'),
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
    final isPremium = state.isCustomerPremium;
    final deliveryFee = (isPremium || _freeShippingApplied) ? 0.0 : 15.0;
    final urgentFee = isPremium ? 12.5 : 25.0;
    final effectiveUrgentCost = _isUrgent ? urgentFee : 0.0;
    final total = (subtotal - discountAmount + deliveryFee + effectiveUrgentCost).clamp(0.0, double.infinity);

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
                                      decoration: const BoxDecoration(
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

                      // 1. URGENT ORDER TOGGLE CARD ("urgent order torra mahnga ho")
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: _isUrgent
                              ? const LinearGradient(
                                  colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _isUrgent ? null : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isUrgent ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
                            width: _isUrgent ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _isUrgent ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Urgent Order (Express Rush)',
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '+${urgentFee.toStringAsFixed(0)} QAR',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFDC2626),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isUrgent
                                            ? '⚡ 4-Hour Turnaround guaranteed! Top-priority laundry wash & express courier redelivery.'
                                            : 'Need it fast? Upgrade for priority processing & 4-hour rush turnaround (+${urgentFee.toStringAsFixed(0)} QAR).',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _isUrgent ? const Color(0xFF991B1B) : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _isUrgent,
                                  activeTrackColor: const Color(0xFFDC2626),
                                  onChanged: (val) {
                                    setState(() {
                                      _isUrgent = val;
                                      if (val) {
                                        _selectedPickupDate = 'Today';
                                        _selectedPickupSlot = '⚡ Immediate Pickup (Within 1 Hour)';
                                        _selectedDeliveryDate = 'Today';
                                        _selectedDeliverySlot = '⚡ Same-Day Rush (4-Hour Delivery)';
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (isPremium) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFFD97706)),
                                    SizedBox(width: 4),
                                    Text(
                                      'VIP Member 50% Rush Discount applied (Saved 12.50 QAR)',
                                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 2. ORDER TIME SCHEDULE: PICKUP & DROP TIME MENTIONS
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.schedule_rounded, color: AppColors.primary, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Schedule Pickup & Drop-off Time',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                  ],
                                ),
                                if (_isUrgent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('⚡ RUSH WINDOW', style: TextStyle(color: Color(0xFFDC2626), fontSize: 9.5, fontWeight: FontWeight.w800)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // A. PICKUP SCHEDULE
                            const Text('1. Courier Doorstep Pickup Schedule:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                            const SizedBox(height: 6),
                            // Date chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: ['Today', 'Tomorrow', 'In 2 Days'].map((date) {
                                  final isSel = _selectedPickupDate == date;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(date, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                                      selected: isSel,
                                      selectedColor: AppColors.primary.withValues(alpha: 0.18),
                                      onSelected: (val) {
                                        if (val) setState(() => _selectedPickupDate = date);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Time slot chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (_isUrgent) '⚡ Immediate (Within 1 Hour)',
                                  '⚡ Express (Within 2 Hours)',
                                  '🌅 Morning (09:00 - 12:00)',
                                  '☀️ Afternoon (13:00 - 17:00)',
                                  '🌆 Evening (18:00 - 21:00)',
                                ].map((slot) {
                                  final isSel = _selectedPickupSlot == slot;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(slot, style: TextStyle(fontSize: 10.5, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                                      selected: isSel,
                                      selectedColor: AppColors.primary.withValues(alpha: 0.18),
                                      onSelected: (val) {
                                        if (val) setState(() => _selectedPickupSlot = slot);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ),

                            // B. DROP-OFF / DELIVERY SCHEDULE
                            const Text('2. Clean Laundry Delivery Drop-off Schedule:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                            const SizedBox(height: 6),
                            // Drop date chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (_isUrgent) 'Today (Urgent)',
                                  'Tomorrow',
                                  'In 2 Days',
                                  'In 3 Days',
                                ].map((date) {
                                  final isSel = _selectedDeliveryDate == date;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(date, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                                      selected: isSel,
                                      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.18),
                                      onSelected: (val) {
                                        if (val) setState(() => _selectedDeliveryDate = date);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Drop time slots
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (_isUrgent) '⚡ Same-Day Rush (4-Hour Delivery)',
                                  '🌅 Morning Drop-off (09:00 - 12:00)',
                                  '☀️ Afternoon Drop-off (13:00 - 17:00)',
                                  '🌆 Evening Drop-off (18:00 - 21:00)',
                                ].map((slot) {
                                  final isSel = _selectedDeliverySlot == slot;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(slot, style: TextStyle(fontSize: 10.5, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                                      selected: isSel,
                                      selectedColor: const Color(0xFF10B981).withValues(alpha: 0.18),
                                      onSelected: (val) {
                                        if (val) setState(() => _selectedDeliverySlot = slot);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 12),
                            // Summary Preview Tag
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_outlined, size: 14, color: Color(0xFF0F766E)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '📦 Pickup: $_selectedPickupDate • $_selectedPickupSlot\n🚚 Delivery: $_selectedDeliveryDate • $_selectedDeliverySlot',
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A), height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Promo Voucher Bar with 1-Tap Chips
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.discount_outlined, color: Color(0xFFB45309), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Have a Voucher / Promo Code?',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF78350F)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 1-Tap Quick Action Promo Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  ActionChip(
                                    avatar: const Text('🕌', style: TextStyle(fontSize: 12)),
                                    label: const Text('EID25 (25% Off)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    backgroundColor: Colors.white,
                                    onPressed: () {
                                      _promoController.text = 'EID25';
                                      _applyPromo('EID25');
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ActionChip(
                                    avatar: const Text('✨', style: TextStyle(fontSize: 12)),
                                    label: const Text('WELCOME10 (10% Off)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    backgroundColor: Colors.white,
                                    onPressed: () {
                                      _promoController.text = 'WELCOME10';
                                      _applyPromo('WELCOME10');
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  ActionChip(
                                    avatar: const Text('🚚', style: TextStyle(fontSize: 12)),
                                    label: const Text('FREESHIP (Free Delivery)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    backgroundColor: Colors.white,
                                    onPressed: () {
                                      _promoController.text = 'FREESHIP';
                                      _applyPromo('FREESHIP');
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
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
                                    _freeShippingApplied
                                        ? 'Code "$_appliedPromoCode" active (Free Door Delivery)'
                                        : 'Code "$_appliedPromoCode" active (${_appliedDiscountPercent.toStringAsFixed(0)}% Off)',
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

                      // Wallet Option with Quick Reload Support
                      Container(
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
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                if (canPayWithWallet) {
                                  setState(() => _paymentMethod = 'wallet');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('⚠️ Insufficient wallet balance (${state.formatCurrency(state.customerWalletBalance)}). Use quick reload below!'),
                                      backgroundColor: AppColors.warning,
                                    ),
                                  );
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet,
                                    color: _paymentMethod == 'wallet' ? AppColors.primary : AppColors.textMuted,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('UniWash Digital Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                        Text(
                                          'Available Balance: ${state.formatCurrency(state.customerWalletBalance)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: canPayWithWallet ? AppColors.success : AppColors.error,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_paymentMethod == 'wallet')
                                    const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                            // Quick In-Sheet Wallet Top-Up Strip if balance is insufficient
                            if (!canPayWithWallet) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.bolt, color: Colors.amber, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'Instant 1-Tap Reload (+Cashback Bonus):',
                                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          onPressed: () {
                                            state.topUpCustomerWallet(100.0, reference: 'Cart Quick Reload');
                                            setState(() => _paymentMethod = 'wallet');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('💳 Loaded 100 QAR to Wallet! Selected as payment.'),
                                                backgroundColor: AppColors.success,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          child: const Text('+100 QAR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0F172A),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          onPressed: () {
                                            state.topUpCustomerWallet(200.0, reference: 'Cart Quick Reload', bonus: 10.0);
                                            setState(() => _paymentMethod = 'wallet');
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('🎉 Loaded 200 QAR + 10 QAR Bonus Cashback to Wallet!'),
                                                backgroundColor: AppColors.success,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          child: const Text('+200 QAR (+10 Bonus)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
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

                      // Special Laundry Instructions & Quick Tags
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Special Laundry Care & Delivery Notes', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          Text('(Optional)', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            '🧴 Sensitive Skin',
                            '👔 Light Starch Thobes',
                            '📦 Dust Protection Bags',
                            '🚪 Leave at Doorstep',
                          ].map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(tag, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                                onPressed: () {
                                  final current = _notesController.text;
                                  if (current.isEmpty) {
                                    _notesController.text = tag;
                                  } else if (!current.contains(tag)) {
                                    _notesController.text = '$current • $tag';
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'Add custom instructions for driver & laundry...',
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text('Door-to-Door Delivery Fee', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                    if (isPremium) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.workspace_premium_rounded, size: 13, color: Color(0xFFD97706)),
                                    ],
                                  ],
                                ),
                                Text(
                                  (isPremium || _freeShippingApplied) ? 'FREE (0.00 QAR)' : '15.00 QAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: (isPremium || _freeShippingApplied) ? AppColors.success : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            if (_isUrgent) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.bolt_rounded, size: 14, color: Color(0xFFDC2626)),
                                      const SizedBox(width: 4),
                                      Text(
                                        isPremium ? '⚡ Urgent Express Rush (VIP 50% Off)' : '⚡ Urgent 4-Hour Express Surcharge',
                                        style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '+${urgentFee.toStringAsFixed(2)} QAR',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFDC2626)),
                                  ),
                                ],
                              ),
                            ],
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
                          backgroundColor: _isUrgent ? const Color(0xFFDC2626) : AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final combinedInstructions = [
                            'Pickup: $_selectedPickupDate ($_selectedPickupSlot)',
                            'Drop-off: $_selectedDeliveryDate ($_selectedDeliverySlot)',
                            if (_isUrgent) '🚨 URGENT ORDER: 4-HOUR EXPRESS RUSH TURNAROUND',
                            if (_notesController.text.trim().isNotEmpty) _notesController.text.trim(),
                          ].join(' | ');

                          final order = state.placeOrder(
                            paymentMethod: _paymentMethod,
                            specialInstructions: combinedInstructions,
                            isUrgent: _isUrgent,
                            urgentFee: urgentFee,
                            scheduledPickupSlot: '$_selectedPickupDate • $_selectedPickupSlot',
                            scheduledDeliverySlot: '$_selectedDeliveryDate • $_selectedDeliverySlot',
                            freeDelivery: _freeShippingApplied,
                          );
                          Navigator.pop(context);
                          widget.onOrderPlaced();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isUrgent
                                  ? '⚡🚨 URGENT Order #${order.orderNumber} placed! Priority dispatch alerted.'
                                  : '🎉 Order #${order.orderNumber} placed! Pickup: $_selectedPickupSlot'),
                              backgroundColor: _isUrgent ? const Color(0xFFDC2626) : AppColors.success,
                            ),
                          );
                        },
                        child: Text(
                          _isUrgent
                              ? '⚡ Place URGENT 4-Hour Order (${total.toStringAsFixed(2)} QAR)'
                              : (_paymentMethod == 'wallet'
                                  ? 'Pay with Wallet & Place Order'
                                  : 'Confirm Order & Request Pickup'),
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
