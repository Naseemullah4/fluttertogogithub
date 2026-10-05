import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import 'address_picker_sheet.dart';
import 'complaints_screen.dart';
import 'order_stepper_screen.dart';
import 'referral_screen.dart';
import '../common/order_detail_dialog.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/uniwash_logo.dart';

class CustomerProfileTab extends StatefulWidget {
  const CustomerProfileTab({super.key});

  @override
  State<CustomerProfileTab> createState() => _CustomerProfileTabState();
}

class _CustomerProfileTabState extends State<CustomerProfileTab> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  late String _selectedWash;
  late String _selectedScent;
  late String _selectedPackaging;
  late String _selectedStarch;

  bool _whatsappAlerts = true;
  bool _smsAlerts = true;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<StateService>(context, listen: false);
    final user = state.currentUser;

    _nameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);

    _selectedWash = state.customerWashPreference;
    _selectedScent = state.customerScentPreference;
    _selectedPackaging = state.customerPackagingPreference;
    _selectedStarch = state.customerStarchLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showWalletTopUpDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet, color: AppColors.primary),
            SizedBox(width: 8),
            Text('UniWash Digital Wallet', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text('Current Available Balance', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    state.formatCurrency(state.customerWalletBalance),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Instant Top-Up Options:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [50.0, 100.0, 200.0, 500.0].map((amt) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    state.topUpCustomerWallet(amt);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('💳 Successfully added ${state.formatCurrency(amt)} to your wallet!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Text('+${amt.toStringAsFixed(0)} QAR', style: const TextStyle(fontWeight: FontWeight.w800)),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLoyaltyPointsDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.stars_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('VIP Loyalty Points', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                children: [
                  const Text('Your Available Reward Points', style: TextStyle(fontSize: 12, color: Color(0xFF78350F))),
                  const SizedBox(height: 4),
                  Text(
                    '${state.customerLoyaltyPoints} Pts',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                  ),
                  const Text('VIP Gold Tier • 1 Pt per 2 QAR Spent', style: TextStyle(fontSize: 11, color: Color(0xFF92400E))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Convert Points into Laundry Credit:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.redeem, color: AppColors.primary),
              title: const Text('200 Pts ➔ 10 QAR Credit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: state.customerLoyaltyPoints >= 200
                    ? () {
                        state.redeemCustomerLoyaltyPoints(200, 10.0);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Redeemed 200 points for 10 QAR wallet balance!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    : null,
                child: const Text('Redeem', style: TextStyle(fontSize: 11)),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.redeem, color: AppColors.primary),
              title: const Text('400 Pts ➔ 25 QAR Credit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: state.customerLoyaltyPoints >= 400
                    ? () {
                        state.redeemCustomerLoyaltyPoints(400, 25.0);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎉 Redeemed 400 points for 25 QAR wallet balance!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    : null,
                child: const Text('Redeem', style: TextStyle(fontSize: 11)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final theme = state.currentOccasionTheme;
    final allOrders = state.orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Identity & VIP Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryDarkColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          _getInitials(_nameController.text),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    _nameController.text.isEmpty
                                        ? 'UniWash Customer'
                                        : _nameController.text,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade400,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'VIP GOLD',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _emailController.text,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              _phoneController.text,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const UniWashLogo.badge(size: 34),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),

                  // Wallet & Points Interactive Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Wallet Balance Button
                      InkWell(
                        onTap: () => _showWalletTopUpDialog(context, state),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Wallet Balance',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.add_circle, color: Colors.tealAccent, size: 12),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.formatCurrency(state.customerWalletBalance),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 28, color: Colors.white24),
                      // Loyalty Points Button
                      InkWell(
                        onTap: () => _showLoyaltyPointsDialog(context, state),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Loyalty Points',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.redeem, color: Colors.amberAccent, size: 12),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.customerLoyaltyPoints} Pts',
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 28, color: Colors.white24),
                      // Refer & Earn Button
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReferralScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            children: const [
                              Text(
                                'Refer & Earn',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '100 QAR >',
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Delivery Address Shortcut Card (Whole Card Clickable!)
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
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.location_on, color: theme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Primary Delivery Address',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            state.selectedAddress.formatted,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Text('Change >', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Customer My Orders Section (Every order is clickable to view details & tracking!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'سجل طلبات الغسيل' : 'My Orders & Order History',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Text(
                  '${allOrders.length} Orders',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (allOrders.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text('No previous orders found.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ),
              )
            else
              ...allOrders.take(3).map((ord) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        OrderDetailDialog.show(context, ord);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: ord.status.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(ord.status.icon, color: ord.status.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '#${ord.orderNumber}',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                      const SizedBox(width: 8),
                                      BadgePill(
                                        label: ord.status.displayName,
                                        backgroundColor: ord.status.color.withValues(alpha: 0.15),
                                        textColor: ord.status.color,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ord.totalItemCount} Items • ${ord.laundryName}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a').format(ord.createdAt),
                                    style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${ord.totalAmount.toStringAsFixed(0)} QAR',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryDark),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => OrderStepperScreen(order: ord)),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('Track', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 20),

            // Live 24/7 Support & Chat Card
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsScreen()));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade700, Colors.teal.shade900],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.support_agent, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24/7 Live Support & Care',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          Text(
                            'Chat with dispatch coordinators or raise a ticket',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white70),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Personal Information
            Text(
              isAr ? 'البيانات الشخصية للحساب' : 'Personal Account Information',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Full Name'),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Email Address'),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Mobile Phone (for Driver SMS & WhatsApp Delivery Pings)'),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Laundry & Fabric Care Preferences
            Text(
              isAr ? 'تفضيلات العناية بالأقمشة والغسيل' : 'Bespoke Fabric Care & Laundry Preferences',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel('Wash Cycle & Water Temperature'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedWash,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Delicate Cycle • 30°C', child: Text('Delicate Cycle • 30°C (Gentle)')),
                      DropdownMenuItem(value: 'Standard Wash • 40°C', child: Text('Standard Wash • 40°C')),
                      DropdownMenuItem(value: 'Sanitizing Steam Wash • 60°C', child: Text('Sanitizing Steam Wash • 60°C')),
                      DropdownMenuItem(value: 'Organic Solvent Dry Cleaning', child: Text('Organic Solvent Dry Cleaning (Wool & Silk)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedWash = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Fragrance & Scent Preference'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedScent,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Royal Jasmine & Oud', child: Text('Royal Jasmine & Oud (Arabian Luxury)')),
                      DropdownMenuItem(value: 'Fresh Crisp Linen', child: Text('Fresh Crisp Linen (Classic Clean)')),
                      DropdownMenuItem(value: 'Soothing French Lavender', child: Text('Soothing French Lavender')),
                      DropdownMenuItem(value: 'Hypoallergenic / Fragrance-Free', child: Text('Hypoallergenic / Fragrance-Free (Sensitive Skin)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedScent = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Starch Level (Thobes & Dress Shirts)'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStarch,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'No Starch (Natural Soft)', child: Text('No Starch (Natural Soft Finish)')),
                      DropdownMenuItem(value: 'Light Form Starch (Crisp & Comfortable)', child: Text('Light Form Starch (Crisp & Comfortable)')),
                      DropdownMenuItem(value: 'Medium Stiff Starch', child: Text('Medium Stiff Starch')),
                      DropdownMenuItem(value: 'Heavy Traditional Thobe Starch', child: Text('Heavy Traditional Thobe Starch (Stand-Up Collar)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStarch = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Packaging & Presentation'),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPackaging,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: const [
                      DropdownMenuItem(value: 'Premium Hangers with Dust Protection Bags', child: Text('Premium Hangers with Dust Bags')),
                      DropdownMenuItem(value: 'Neatly Folded & Ribbon Tied', child: Text('Neatly Folded & Ribbon Tied')),
                      DropdownMenuItem(value: 'Eco-Friendly Biodegradable Packaging', child: Text('Eco-Friendly Biodegradable Bags')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPackaging = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Notifications
            Text(
              isAr ? 'الإشعارات والتواصل' : 'Notifications & Alerts',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('WhatsApp Order Status Alerts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Instant updates when driver departs, collects, and delivers garments', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    value: _whatsappAlerts,
                    activeThumbColor: theme.primaryColor,
                    onChanged: (v) => setState(() => _whatsappAlerts = v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Promotional Offers & Regional Seasonal Discounts', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Get notified of Ramadan, Eid, National Day and Flash weekend discounts', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    value: _smsAlerts,
                    activeThumbColor: theme.primaryColor,
                    onChanged: (v) => setState(() => _smsAlerts = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Preferences Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  state.updateCustomerProfile(
                    fullName: _nameController.text.trim().isEmpty ? 'Customer' : _nameController.text.trim(),
                    email: _emailController.text.trim(),
                    phone: _phoneController.text.trim(),
                    washPreference: _selectedWash,
                    scentPreference: _selectedScent,
                    packagingPreference: _selectedPackaging,
                    starchLevel: _selectedStarch,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Profile & Fabric Care Preferences Saved Successfully!'),
                        ],
                      ),
                      backgroundColor: theme.primaryColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  isAr ? 'حفظ بيانات الملف وتفضيلات الغسيل' : 'Save Profile & Laundry Preferences',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const UniWashLogo.banner(height: 48),
                  const SizedBox(height: 8),
                  Text(
                    isAr ? 'منصة يوني واش لخدمات الغسيل والتنظيف الجاف' : 'UniWash Laundry & Dry Cleaning Platform',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  const Text('24/7 Professional Express Care • ISO 9001 Certified', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textDark),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
