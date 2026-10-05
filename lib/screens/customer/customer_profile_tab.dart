import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import 'address_picker_sheet.dart';
import 'referral_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final theme = state.currentOccasionTheme;

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
                      // Avatar
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

                  // Wallet & Points Sub-row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Wallet Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
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
                      Container(width: 1, height: 28, color: Colors.white24),
                      Column(
                        children: [
                          const Text(
                            'Loyalty Points',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
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
                      Container(width: 1, height: 28, color: Colors.white24),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReferralScreen(),
                            ),
                          );
                        },
                        child: Column(
                          children: const [
                            Text(
                              'Refer & Earn',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
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
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Delivery Address Shortcut Card
            Container(
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
                  TextButton(
                    onPressed: () {
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
                    child: const Text(
                      'Change',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Personal Information Section
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
                        child: Text('Delicate Cycle • 30°C (Gentle)'),
                      ),
                      DropdownMenuItem(
                        value: 'Standard Wash • 40°C',
                        child: Text('Standard Wash • 40°C'),
                      ),
                      DropdownMenuItem(
                        value: 'Sanitizing Steam Wash • 60°C',
                        child: Text('Sanitizing Steam Wash • 60°C'),
                      ),
                      DropdownMenuItem(
                        value: 'Organic Solvent Dry Cleaning',
                        child: Text(
                          'Organic Solvent Dry Cleaning (Wool & Silk)',
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
                        child: Text('Royal Jasmine & Oud (Arabian Luxury)'),
                      ),
                      DropdownMenuItem(
                        value: 'Fresh Crisp Linen',
                        child: Text('Fresh Crisp Linen (Classic Clean)'),
                      ),
                      DropdownMenuItem(
                        value: 'Soothing French Lavender',
                        child: Text('Soothing French Lavender'),
                      ),
                      DropdownMenuItem(
                        value: 'Hypoallergenic / Fragrance-Free',
                        child: Text(
                          'Hypoallergenic / Fragrance-Free (Sensitive Skin)',
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
                        child: Text('No Starch (Natural Soft Finish)'),
                      ),
                      DropdownMenuItem(
                        value: 'Light Form Starch (Crisp & Comfortable)',
                        child: Text('Light Form Starch (Crisp & Comfortable)'),
                      ),
                      DropdownMenuItem(
                        value: 'Medium Stiff Starch',
                        child: Text('Medium Stiff Starch'),
                      ),
                      DropdownMenuItem(
                        value: 'Heavy Traditional Thobe Starch',
                        child: Text(
                          'Heavy Traditional Thobe Starch (Stand-Up Collar)',
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
                        child: Text('Premium Hangers with Dust Bags'),
                      ),
                      DropdownMenuItem(
                        value: 'Neatly Folded & Ribbon Tied',
                        child: Text('Neatly Folded & Ribbon Tied'),
                      ),
                      DropdownMenuItem(
                        value: 'Eco-Friendly Biodegradable Packaging',
                        child: Text('Eco-Friendly Biodegradable Bags'),
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

            // Order Notifications & Communication
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

            // Designated Bottom Call-to-Action (CTA) Button
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
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
                  const UniWashLogo.banner(height: 52),
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
}
