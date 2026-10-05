import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/driver.dart';
import '../../models/laundry.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/uniwash_logo.dart';

class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  void _showEarningsDialog(BuildContext context, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.account_balance_wallet, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Today's Earnings Breakdown", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text('Total Net Earnings Today', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    '${driver.todayEarningsQar.toStringAsFixed(2)} QAR',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDialogRow('Base Trip Fares', '${(driver.todayEarningsQar * 0.70).toStringAsFixed(1)} QAR'),
            const Divider(height: 14),
            _buildDialogRow('Driver Tier Bonus (+${driver.bonusRatePerOrder.toStringAsFixed(2)}/trip)', '${(driver.todayEarningsQar * 0.20).toStringAsFixed(1)} QAR'),
            const Divider(height: 14),
            _buildDialogRow('Customer In-App Tips', '${(driver.todayEarningsQar * 0.10).toStringAsFixed(1)} QAR'),
            const Divider(height: 14),
            _buildDialogRow('Fleet Payout Method', 'Direct Bank Deposit (Weekly)'),
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

  void _showReviewsDialog(BuildContext context, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text('Rating & Reviews (${driver.rating.toStringAsFixed(1)})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildReviewDialogTile('Jassim Al-Kuwari', 5.0, 'Very fast and handled the traditional thobe with extreme care!'),
              _buildReviewDialogTile('Maryam Al-Thani', 5.0, 'On-time pickup at Porto Arabia Pearl tower. Very polite driver.'),
              _buildReviewDialogTile('Dr. Khaled', 4.5, 'Quick response on the call, smooth collection.'),
              _buildReviewDialogTile('Salem Al-Marri', 5.0, 'Punctual and always handles delicate suits carefully.'),
            ],
          ),
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

  void _showCompletedRidesDialog(BuildContext context, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.local_shipping, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Completed Missions Log', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Lifetime Completed Trips: ${driver.completedTrips}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildDialogRow('The Pearl & Porto Arabia', '58 Trips'),
            const Divider(height: 14),
            _buildDialogRow('Lusail Marina Towers', '42 Trips'),
            const Divider(height: 14),
            _buildDialogRow('West Bay Diplomatic Area', '24 Trips'),
            const Divider(height: 14),
            _buildDialogRow('Al Sadd & Downtown Doha', '16 Trips'),
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

  void _showTierBenefitsDialog(BuildContext context, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.military_tech, color: Colors.amber),
            SizedBox(width: 8),
            Text('Driver Tier & Bonus System', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'UniWash drivers unlock higher earnings and milestone bonuses as they complete missions with 4.8+ star ratings:',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            _buildTierLevelCard('Standard Fleet', '0 - 199 Trips', '+0.50 QAR / order bonus', Colors.grey.shade400, false),
            const SizedBox(height: 8),
            _buildTierLevelCard('Blue Tag Fleet', '200 - 249 Trips', '+1.00 QAR / order bonus', const Color(0xFF0284C7), driver.hasBlueTag),
            const SizedBox(height: 8),
            _buildTierLevelCard('Gold VIP Tier', '250 - 299 Trips', '+1.50 QAR / order bonus', const Color(0xFFD97706), driver.hasGoldenBadge),
            const SizedBox(height: 8),
            _buildTierLevelCard('Diamond Elite Tier', '300+ Trips', '+2.50 QAR / order bonus', const Color(0xFF8B5CF6), driver.hasPremiumDiamondBadge),
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

  static Widget _buildTierLevelCard(String name, String trips, String bonus, Color color, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCurrent ? color.withValues(alpha: 0.15) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isCurrent ? color : AppColors.border, width: isCurrent ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isCurrent ? color : AppColors.textDark)),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                        child: const Text('YOU', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ],
                ),
                Text('$trips • $bonus', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDialogRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  static Widget _buildReviewDialogTile(String name, double rating, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const Divider(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    if (state.drivers.isEmpty) {
      return const Center(child: Text('No driver profile available.'));
    }
    final driver = state.drivers.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Identity Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primaryLight,
                          child: const Text(
                            'TM',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const UniWashLogo.badge(size: 34),
                      ],
                    ),
                    BadgePill(
                      label: driver.warningStatus.displayName.toUpperCase(),
                      backgroundColor: driver.warningStatus.color,
                      textColor: driver.warningStatus.textColor,
                      icon: Icons.shield,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  driver.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Driver ID: QA-DRV-0891 • ${driver.phone}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assigned Laundry: ${driver.assignedLaundryName}',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'QID / Passport: ${driver.qidPassportNumber} | License: ${driver.licenseNumber}',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Driver Tier & Order Bonus Card (Clickable!)
          InkWell(
            onTap: () => _showTierBenefitsDialog(context, driver),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF047857).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Color(0xFFFDE047),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          driver.tierBadgeTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (driver.hasPremiumDiamondBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.diamond, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('DIAMOND 300+', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        )
                      else if (driver.hasGoldenBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('GOLD 250+', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        )
                      else if (driver.hasBlueTag)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('BLUE TAG 200+', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, color: Colors.white70, size: 14),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Current Bonus Rate', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '${driver.bonusRatePerOrder.toStringAsFixed(2)} QAR / order',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lifetime Bonus Earned', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                '${driver.totalBonusEarnings.toStringAsFixed(1)} QAR',
                                style: const TextStyle(color: Color(0xFF86EFAC), fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${driver.starRating} Stars Milestone: ',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                          ...List.generate(
                            driver.starRating,
                            (i) => const Icon(Icons.star_rounded, color: Color(0xFFFDE047), size: 16),
                          ),
                        ],
                      ),
                      Text(
                        '${driver.completedTrips} completed orders (Tap for info >)',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Operational Statistics (EVERY CARD IS CLICKABLE!)
          const Text(
            'Driver Performance Dashboard',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              StatCard(
                title: "Today's Earnings",
                value: "${driver.todayEarningsQar.toStringAsFixed(0)} QAR",
                subtitle: 'Tap to view payout breakdown >',
                icon: Icons.account_balance_wallet,
                iconColor: AppColors.primary,
                onTap: () => _showEarningsDialog(context, driver),
              ),
              StatCard(
                title: 'Customer Rating',
                value: '⭐ ${driver.rating.toStringAsFixed(1)}',
                subtitle: 'Tap to see 89 customer reviews >',
                icon: Icons.star,
                iconColor: Colors.amber,
                onTap: () => _showReviewsDialog(context, driver),
              ),
              StatCard(
                title: 'Completed Rides',
                value: '${driver.completedTrips}',
                subtitle: 'Tap to see zone delivery log >',
                icon: Icons.local_shipping,
                iconColor: AppColors.accent,
                onTap: () => _showCompletedRidesDialog(context, driver),
              ),
              StatCard(
                title: 'Fleet Status',
                value: driver.isOnline ? 'Online' : 'Offline',
                subtitle: 'GPS Transmission: Live broadcast',
                icon: Icons.radio_button_checked,
                iconColor: AppColors.success,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(driver.isOnline ? '🟢 GPS is actively broadcasting location to dispatch.' : '🔴 Driver is currently offline.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Customer Feedback
          const Text(
            'Recent Customer Reviews',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _buildReviewTile(
            'Jassim Al-Kuwari',
            5.0,
            'Very fast and handled the traditional thobe and ghutra with extreme care!',
          ),
          _buildReviewTile(
            'Maryam Al-Thani',
            5.0,
            'On-time pickup at Porto Arabia Pearl tower. Very polite driver.',
          ),
          _buildReviewTile(
            'Dr. Khaled',
            4.5,
            'Quick response on the call, smooth collection.',
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: const [
                UniWashLogo.banner(height: 48),
                SizedBox(height: 8),
                Text(
                  'UniWash Certified Fleet & Logistics Partner',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                Text(
                  'Doha Express Dispatch Operations',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReviewTile(String name, double rating, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$rating',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
