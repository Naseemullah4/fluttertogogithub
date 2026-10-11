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
      builder: (ctx) => _CustomerWalletHubDialog(state: state),
    );
  }

  void _showBecomePremiumDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => _CustomerVipMembershipDialog(state: state),
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
            Text(
              'VIP Loyalty Points',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
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
                  const Text(
                    'Your Available Reward Points',
                    style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.customerLoyaltyPoints} Pts',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  const Text(
                    'VIP Gold Tier • 1 Pt per 2 QAR Spent',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Convert Points into Laundry Credit:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 10),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.redeem, color: AppColors.primary),
              title: const Text(
                '200 Pts ➔ 10 QAR Credit',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.customerLoyaltyPoints >= 200
                    ? () {
                        state.redeemCustomerLoyaltyPoints(200, 10.0);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '🎉 Redeemed 200 points for 10 QAR wallet balance!',
                            ),
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
              title: const Text(
                '400 Pts ➔ 25 QAR Credit',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.customerLoyaltyPoints >= 400
                    ? () {
                        state.redeemCustomerLoyaltyPoints(400, 25.0);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '🎉 Redeemed 400 points for 25 QAR wallet balance!',
                            ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
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
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _phoneController.text,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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
                    children: [
                      // Wallet Balance Button
                      Expanded(
                        child: InkWell(
                          onTap: () => _showWalletTopUpDialog(context, state),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Flexible(
                                      child: Text(
                                        'Wallet',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.add_circle,
                                      color: Colors.tealAccent,
                                      size: 12,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    state.formatCurrency(
                                      state.customerWalletBalance,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 26, color: Colors.white24),
                      // Loyalty Points Button
                      Expanded(
                        child: InkWell(
                          onTap: () => _showLoyaltyPointsDialog(context, state),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Flexible(
                                      child: Text(
                                        'Points',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.redeem,
                                      color: Colors.amberAccent,
                                      size: 12,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${state.customerLoyaltyPoints} Pts',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 26, color: Colors.white24),
                      // Refer & Earn Button
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReferralScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            child: Column(
                              children: const [
                                Text(
                                  'Refer & Earn',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '100 QAR >',
                                    style: TextStyle(
                                      color: Colors.tealAccent,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                      child: Icon(
                        Icons.location_on,
                        color: theme.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Primary Delivery Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            state.selectedAddress.formatted,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Change >',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // VIP Membership Privilege Card (Become Premium / VIP Active)
            _buildVipMembershipBanner(context, state, isAr),
            const SizedBox(height: 20),

            // Customer My Orders Section (Every order is clickable to view details & tracking!)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'سجل طلبات الغسيل' : 'My Orders & Order History',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${allOrders.length} Orders',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.bold,
                  ),
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
                  child: Text(
                    'No previous orders found.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
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
                              child: Icon(
                                ord.status.icon,
                                color: ord.status.color,
                                size: 20,
                              ),
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
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: BadgePill(
                                          label: ord.status.displayName,
                                          backgroundColor: ord.status.color
                                              .withValues(alpha: 0.15),
                                          textColor: ord.status.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ord.totalItemCount} Items • ${ord.laundryName}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy, hh:mm a')
                                        .format(ord.createdAt),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${ord.totalAmount.toStringAsFixed(0)} QAR',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                OrderStepperScreen(order: ord),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          'Track',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.chevron_right,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
                );
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
                      child: const Icon(
                        Icons.support_agent,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24/7 Live Support & Care',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Chat with dispatch coordinators or raise a ticket',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Email Address'),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel(
                    'Mobile Phone (for Driver SMS & WhatsApp Delivery Pings)',
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Laundry & Fabric Care Preferences
            Text(
              isAr
                  ? 'تفضيلات العناية بالأقمشة والغسيل'
                  : 'Bespoke Fabric Care & Laundry Preferences',
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
                    isExpanded: true,
                    initialValue: _selectedWash,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Delicate Cycle • 30°C',
                        child: Text('Delicate Cycle • 30°C (Gentle)', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Standard Wash • 40°C',
                        child: Text('Standard Wash • 40°C', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Sanitizing Steam Wash • 60°C',
                        child: Text('Sanitizing Steam Wash • 60°C', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Organic Solvent Dry Cleaning',
                        child: Text(
                          'Organic Solvent Dry Cleaning (Wool & Silk)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedWash = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Fragrance & Scent Preference'),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedScent,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Royal Jasmine & Oud',
                        child: Text('Royal Jasmine & Oud (Arabian Luxury)', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Fresh Crisp Linen',
                        child: Text('Fresh Crisp Linen (Classic Clean)', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Soothing French Lavender',
                        child: Text('Soothing French Lavender', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Hypoallergenic / Fragrance-Free',
                        child: Text(
                          'Hypoallergenic / Fragrance-Free (Sensitive Skin)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedScent = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Starch Level (Thobes & Dress Shirts)'),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedStarch,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'No Starch (Natural Soft)',
                        child: Text('No Starch (Natural Soft Finish)', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Light Form Starch (Crisp & Comfortable)',
                        child: Text('Light Form Starch (Crisp & Comfortable)', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Medium Stiff Starch',
                        child: Text('Medium Stiff Starch', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Heavy Traditional Thobe Starch',
                        child: Text(
                          'Heavy Traditional Thobe Starch (Stand-Up Collar)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStarch = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildInputLabel('Packaging & Presentation'),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedPackaging,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Premium Hangers with Dust Protection Bags',
                        child: Text('Premium Hangers with Dust Bags', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Neatly Folded & Ribbon Tied',
                        child: Text('Neatly Folded & Ribbon Tied', overflow: TextOverflow.ellipsis),
                      ),
                      DropdownMenuItem(
                        value: 'Eco-Friendly Biodegradable Packaging',
                        child: Text('Eco-Friendly Biodegradable Bags', overflow: TextOverflow.ellipsis),
                      ),
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
                    title: const Text(
                      'WhatsApp Order Status Alerts',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Instant updates when driver departs, collects, and delivers garments',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    value: _whatsappAlerts,
                    activeThumbColor: theme.primaryColor,
                    onChanged: (v) => setState(() => _whatsappAlerts = v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text(
                      'Promotional Offers & Regional Seasonal Discounts',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
                      'Get notified of Ramadan, Eid, National Day and Flash weekend discounts',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  state.updateCustomerProfile(
                    fullName: _nameController.text.trim().isEmpty
                        ? 'Customer'
                        : _nameController.text.trim(),
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
                          Text(
                            'Profile & Fabric Care Preferences Saved Successfully!',
                          ),
                        ],
                      ),
                      backgroundColor: theme.primaryColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  isAr
                      ? 'حفظ بيانات الملف وتفضيلات الغسيل'
                      : 'Save Profile & Laundry Preferences',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
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
                    isAr
                        ? 'منصة يوني واش لخدمات الغسيل والتنظيف الجاف'
                        : 'UniWash Laundry & Dry Cleaning Platform',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '24/7 Professional Express Care • ISO 9001 Certified',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
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
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
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

  Widget _buildVipMembershipBanner(BuildContext context, StateService state, bool isAr) {
    final isVip = state.isCustomerPremium;
    final tier = state.customerPremiumTier;
    final expiry = state.premiumExpiryDate;

    if (isVip) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF78350F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.amber.shade400.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.amber, width: 1.2),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              tier.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.success, width: 0.8),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        if (expiry != null)
                          Text(
                            'Renews ${DateFormat('dd MMM yyyy').format(expiry)}',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showBecomePremiumDialog(context, state),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  child: const Text('Manage >', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildVipPerkChip('🚀 Free Delivery on All Orders'),
                _buildVipPerkChip('⚡ 50% Off Urgent Rush Fees'),
                _buildVipPerkChip('👑 Priority Laundry Line'),
              ],
            ),
          ],
        ),
      );
    }

    // Not VIP -> Promotional Upgrade Banner
    return InkWell(
      onTap: () => _showBecomePremiumDialog(context, state),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6)),
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.amberAccent, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        '👑 Become UniWash VIP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '✨ POPULAR',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Free delivery, 50% off urgent orders, and express rush turnaround.',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'From 49 QAR/month • Cancel anytime >',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVipPerkChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CustomerWalletHubDialog extends StatefulWidget {
  final StateService state;

  const _CustomerWalletHubDialog({required this.state});

  @override
  State<_CustomerWalletHubDialog> createState() => _CustomerWalletHubDialogState();
}

class _CustomerWalletHubDialogState extends State<_CustomerWalletHubDialog> {
  int _selectedTab = 0; // 0 = Advanced Top-Up & Settings, 1 = Activity History
  String _selectedGateway = 'QCB Debit/Credit';
  final TextEditingController _customAmountController = TextEditingController();
  double _customAmount = 0.0;
  String _filter = 'all'; // 'all', 'topup', 'spent'

  final List<Map<String, dynamic>> _gateways = [
    {'name': 'QCB Debit/Credit', 'icon': Icons.credit_card, 'badge': 'All Banks'},
    {'name': 'Apple Pay', 'icon': Icons.apple, 'badge': 'Instant FaceID'},
    {'name': 'Google Pay', 'icon': Icons.payment, 'badge': 'Fast Checkout'},
    {'name': 'QNB / CBQ Direct', 'icon': Icons.account_balance, 'badge': 'Direct Debit'},
    {'name': 'Sadad Qatar', 'icon': Icons.flash_on, 'badge': 'Instant Pay'},
  ];

  @override
  void initState() {
    super.initState();
    _customAmountController.addListener(() {
      final val = double.tryParse(_customAmountController.text.trim()) ?? 0.0;
      setState(() => _customAmount = val);
    });
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  double _calculateBonus(double amount) {
    if (amount >= 500) return (amount * 0.09).roundToDouble(); // 9% cashback on >= 500
    if (amount >= 200) return (amount * 0.075).roundToDouble(); // 7.5% cashback on >= 200
    if (amount >= 100) return 5.0; // 5 QAR bonus on 100
    return 0.0;
  }

  void _executeTopUp(double amt, double bonus) {
    if (amt <= 0) return;
    widget.state.topUpCustomerWallet(
      amt,
      bonus: bonus,
      reference: 'RELOAD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      paymentGateway: _selectedGateway,
    );
    _customAmountController.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          bonus > 0
              ? '🎉 Reloaded ${amt.toStringAsFixed(0)} QAR + ${bonus.toStringAsFixed(0)} QAR Bonus via $_selectedGateway!'
              : '💳 Reloaded ${amt.toStringAsFixed(0)} QAR to Wallet via $_selectedGateway!',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final allTxs = state.walletTransactions;
    final filteredTxs = allTxs.where((tx) {
      if (_filter == 'topup') return tx.isCredit;
      if (_filter == 'spent') return !tx.isCredit;
      return true;
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('UniWash Digital Wallet Hub', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('Advanced Reload & Auto-Top-Up Suite', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Executive Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F766E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.nfc, color: Colors.white70, size: 18),
                          SizedBox(width: 6),
                          Text('EXECUTIVE PASS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                        ],
                      ),
                      const UniWashLogo.badge(size: 22),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Available Balance', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    state.formatCurrency(state.customerWalletBalance),
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.currentUser.fullName.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                      ),
                      Text(
                        state.isCustomerPremium ? '👑 ${state.customerPremiumTier}' : '•••• 9921',
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Buttons
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 0),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _selectedTab == 0
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '⚡ Advanced Top-Up',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedTab == 0 ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedTab == 0 ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = 1),
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _selectedTab == 1
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '📜 Activity (${allTxs.length})',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedTab == 1 ? FontWeight.w800 : FontWeight.w600,
                              color: _selectedTab == 1 ? AppColors.primary : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tab Content
            Expanded(
              child: _selectedTab == 0
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Payment Gateway Selector
                          const Text('Select Payment Gateway', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final gw in _gateways)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedGateway = gw['name'] as String),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: _selectedGateway == gw['name'] ? const Color(0xFF0F172A) : Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: _selectedGateway == gw['name'] ? const Color(0xFF0F172A) : AppColors.border),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(gw['icon'] as IconData, size: 14, color: _selectedGateway == gw['name'] ? Colors.white : AppColors.textDark),
                                            const SizedBox(width: 6),
                                            Text(
                                              gw['name'] as String,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: _selectedGateway == gw['name'] ? FontWeight.w800 : FontWeight.w600,
                                                color: _selectedGateway == gw['name'] ? Colors.white : AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick Reload Packages with Cashback Bonus
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Cashback Packages', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                              Text('🎁 Extra Bonus Included', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildReloadChip(context, state, 50.0, 0.0),
                                const SizedBox(width: 8),
                                _buildReloadChip(context, state, 100.0, 5.0),
                                const SizedBox(width: 8),
                                _buildReloadChip(context, state, 200.0, 15.0, highlight: true),
                                const SizedBox(width: 8),
                                _buildReloadChip(context, state, 500.0, 45.0, highlight: true),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Custom Amount Input with Live Calculated Cashback
                          const Text('Custom Top-Up Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Text('QAR', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _customAmountController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter custom reload (e.g. 250)',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  ),
                                ),
                                if (_customAmount > 0)
                                  ElevatedButton(
                                    onPressed: () => _executeTopUp(_customAmount, _calculateBonus(_customAmount)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                    child: Text(
                                      'Add ${_calculateBonus(_customAmount) > 0 ? '+${_calculateBonus(_customAmount).toStringAsFixed(0)} Free' : ''}',
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (_customAmount >= 100)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.success, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Eligible for +${_calculateBonus(_customAmount).toStringAsFixed(0)} QAR Instant Cashback!',
                                    style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),

                          // Smart Auto-Reload Settings Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.autorenew, color: AppColors.primary, size: 18),
                                        SizedBox(width: 6),
                                        Text('Smart Auto-Reload', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                                      ],
                                    ),
                                    Switch.adaptive(
                                      value: state.isAutoReloadEnabled,
                                      activeTrackColor: AppColors.primary,
                                      onChanged: (val) {
                                        state.toggleAutoReload(val);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Automatically reloads your wallet whenever balance drops below threshold so your laundry orders never fail.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                if (state.isAutoReloadEnabled)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Text(
                                              'Threshold: ${state.autoReloadThreshold.toStringAsFixed(0)} QAR',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.border),
                                            ),
                                            child: Text(
                                              'Reload: +${state.autoReloadAmount.toStringAsFixed(0)} QAR',
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter Pills
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Transaction Activity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                            Row(
                              children: [
                                _buildFilterPill('All', 'all'),
                                const SizedBox(width: 4),
                                _buildFilterPill('Top-Ups', 'topup'),
                                const SizedBox(width: 4),
                                _buildFilterPill('Spent', 'spent'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: filteredTxs.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey),
                                      SizedBox(height: 6),
                                      Text('No transactions in this category', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: filteredTxs.length,
                                  separatorBuilder: (context, index) => const Divider(height: 10),
                                  itemBuilder: (ctx, idx) {
                                    final tx = filteredTxs[idx];
                                    return Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: tx.isCredit
                                                ? AppColors.success.withValues(alpha: 0.12)
                                                : Colors.red.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                            size: 14,
                                            color: tx.isCredit ? AppColors.success : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.title,
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${DateFormat('dd MMM, HH:mm').format(tx.timestamp)} • Ref: ${tx.reference}',
                                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${tx.isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(0)} QAR',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12.5,
                                            color: tx.isCredit ? AppColors.success : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReloadChip(BuildContext context, StateService state, double amt, double bonus, {bool highlight = false}) {
    return InkWell(
      onTap: () => _executeTopUp(amt, bonus),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: highlight ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: highlight ? const Color(0xFF0F172A) : AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              '+${amt.toStringAsFixed(0)} QAR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: highlight ? Colors.white : AppColors.textDark,
              ),
            ),
            if (bonus > 0)
              Text(
                '+${bonus.toStringAsFixed(0)} QAR Free',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.amber),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title, String key) {
    final isSelected = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _CustomerVipMembershipDialog extends StatefulWidget {
  final StateService state;

  const _CustomerVipMembershipDialog({required this.state});

  @override
  State<_CustomerVipMembershipDialog> createState() => _CustomerVipMembershipDialogState();
}

class _CustomerVipMembershipDialogState extends State<_CustomerVipMembershipDialog> {
  int _selectedTierIndex = 1; // Default to Gold (index 1)
  String _paymentMethod = 'wallet'; // 'wallet', 'card'

  final List<Map<String, dynamic>> _tiers = [
    {
      'title': 'Silver VIP',
      'price': 49.0,
      'color': const Color(0xFF64748B),
      'perks': [
        'Free delivery on orders over 50 QAR',
        '25% discount on urgent express fees',
        '1.2x loyalty reward points',
      ],
    },
    {
      'title': 'Gold VIP',
      'price': 99.0,
      'color': const Color(0xFFD97706),
      'isPopular': true,
      'perks': [
        '100% FREE door-to-door delivery on ALL orders',
        '50% discount on urgent express rush fees',
        '1.5x VIP loyalty reward points',
        'Priority laundry intake and dispatch line',
      ],
    },
    {
      'title': 'Platinum VIP',
      'price': 199.0,
      'color': const Color(0xFF7C3AED),
      'perks': [
        '100% FREE unlimited deliveries',
        '100% FREE urgent express rush orders (0 QAR fee)',
        '2x VIP loyalty reward points',
        'Dedicated VIP laundry care specialist',
        'Complimentary luxury wooden hanger packaging',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isAlreadyVip = state.isCustomerPremium;
    final selectedTier = _tiers[_selectedTierIndex];
    final tierPrice = selectedTier['price'] as double;
    final tierTitle = selectedTier['title'] as String;
    final canAffordWallet = state.customerWalletBalance >= tierPrice;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('UniWash VIP Membership', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('Unlock exclusive laundry privileges & zero fees', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Tier Selector Cards
            Row(
              children: List.generate(_tiers.length, (idx) {
                final t = _tiers[idx];
                final isSel = _selectedTierIndex == idx;
                final isPop = t['isPopular'] == true;
                final price = t['price'] as double;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: idx < _tiers.length - 1 ? 6 : 0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedTierIndex = idx),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? const Color(0xFF0F172A) : (isPop ? Colors.amber.shade300 : AppColors.border),
                            width: isSel ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (isPop)
                              Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'BEST VALUE',
                                  style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
                                ),
                              ),
                            Text(
                              t['title'] as String,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: isSel ? Colors.white : AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${price.toStringAsFixed(0)} QAR',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isSel ? Colors.amberAccent : AppColors.primary,
                              ),
                            ),
                            Text(
                              '/month',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isSel ? Colors.white60 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Selected Tier Perks Checklist
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${selectedTier['title']} Perks Included',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              Text(
                                '30 Days Access',
                                style: TextStyle(color: selectedTier['color'] as Color, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...(selectedTier['perks'] as List<String>).map((perk) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      perk,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Payment Method Toggle
                    const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _paymentMethod = 'wallet'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _paymentMethod == 'wallet' ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _paymentMethod == 'wallet' ? AppColors.primary : AppColors.border,
                                  width: _paymentMethod == 'wallet' ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance_wallet, size: 16, color: _paymentMethod == 'wallet' ? AppColors.primary : AppColors.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Wallet Balance', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                        Text(
                                          state.formatCurrency(state.customerWalletBalance),
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: canAffordWallet ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                      ],
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
                            onTap: () => setState(() => _paymentMethod = 'card'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _paymentMethod == 'card' ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _paymentMethod == 'card' ? AppColors.primary : AppColors.border,
                                  width: _paymentMethod == 'card' ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.credit_card, size: 16, color: _paymentMethod == 'card' ? AppColors.primary : AppColors.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Credit / Debit Card', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                                        Text('Instant Apple/QCB Pay', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              children: [
                if (isAlreadyVip) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        state.cancelPremiumMembership();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Membership cancelled. Switched back to Standard.'), backgroundColor: Colors.grey),
                        );
                      },
                      child: const Text('Cancel VIP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      if (_paymentMethod == 'wallet' && !canAffordWallet) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('⚠️ Insufficient wallet balance (${state.formatCurrency(state.customerWalletBalance)}). Top up first or pay with Card!'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      state.upgradeToPremiumMembership(
                        tier: tierTitle,
                        price: tierPrice,
                        paymentMethod: _paymentMethod,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('👑 Congratulations! You are now a $tierTitle member with Free Delivery!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: Text(
                      isAlreadyVip ? 'Switch to $tierTitle (${tierPrice.toStringAsFixed(0)} QAR)' : '👑 Activate $tierTitle (${tierPrice.toStringAsFixed(0)} QAR/mo)',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

