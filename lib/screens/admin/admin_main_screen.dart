import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/super_search_bar.dart';
import '../../models/laundry.dart';
import '../../models/order.dart';
import '../../models/contract.dart';
import '../../models/user.dart';
import '../common/driver_folder_dialog.dart';
import '../common/laundry_profile_dialog.dart';
import '../common/order_detail_dialog.dart';
import '../laundry/laundry_thermal_invoice_dialog.dart';
import '../super_admin/super_admin_event_offers_dialog.dart';
import '../common/ad_management_dialog.dart';
import '../common/admin_popup_manager_dialog.dart';
import '../common/occasion_theming_dialog.dart';
import 'admin_escalation_dialog.dart';
import 'admin_contract_dialog.dart';
import 'admin_staff_dialog.dart';
import 'admin_assign_driver_dialog.dart';
import '../../widgets/uniwash_logo.dart';
import '../super_admin/super_admin_live_orders_tab.dart';
import '../super_admin/super_admin_order_problems_tab.dart';
import '../super_admin/super_admin_reports_dialog.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _orderFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const UniWashLogo.badge(size: 38),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'بوابة العمليات الإقليمية (الكمبيوتر والمتصفح)'
                      : 'Regional Operations Web Portal 💻',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${state.selectedCountry.flag} ${state.selectedCountry.name} • Desktop Browser Web App (Laptop / PC)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Google Omnibar Super Search in AppBar
          Container(
            width: 380,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SuperSearchBar(
              hintText: isAr
                  ? 'بحث فائق: رقم الطلب، الهاتف، العميل...'
                  : 'Super Search: Order #, Mobile, Customer...',
              onOrderSelected: (order) =>
                  OrderDetailDialog.show(context, order),
            ),
          ),
          const SizedBox(width: 12),

          // Regional Operations Report & Print
          IconButton(
            icon: const Icon(
              Icons.summarize_rounded,
              color: Color(0xFF0F172A),
            ),
            tooltip: 'Regional Operations Report',
            onPressed: () => SuperAdminReportsDialog.show(context, state),
          ),
          const SizedBox(width: 6),

          // Onboard Staff Member Button
          IconButton(
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primary,
            ),
            tooltip: 'Onboard Staff Member',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AdminStaffDialog(stateService: state),
              );
            },
          ),
          const SizedBox(width: 6),

          // Switch to Customer Support Portal
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.support_agent_rounded,
              size: 14,
            ),
            label: Text(
              isAr ? 'خدمة العملاء' : 'Support / CS',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            onPressed: () => state.switchRole(UserRole.customerService),
          ),
          const SizedBox(width: 6),

          // Switch to Engineer Bugs Portal
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.engineering_rounded,
              size: 14,
            ),
            label: Text(
              isAr ? 'المهندس' : 'Engineer',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            onPressed: () => state.switchRole(UserRole.engineer),
          ),
          const SizedBox(width: 6),

          // Switch to Super Admin Enterprise Hub
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 14,
              color: Color(0xFF38BDF8),
            ),
            label: Text(
              isAr ? 'المشرف العام' : 'Super Admin Hub',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            onPressed: () => state.switchRole(UserRole.superAdmin),
          ),
          const SizedBox(width: 8),

          // Language Switcher
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            icon: const Icon(Icons.language, size: 15),
            label: Text(
              isAr ? 'English' : 'العربية',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
            ),
            onPressed: () => state.toggleLanguage(),
          ),
          const SizedBox(width: 14),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(
              icon: const Icon(Icons.storefront_rounded),
              text: isAr
                  ? 'المصابغ والملفات (${state.laundries.length})'
                  : 'Laundries & Folders (${state.laundries.length})',
            ),
            Tab(
              icon: const Icon(Icons.delivery_dining_rounded),
              text: isAr
                  ? 'السائقين وكلمات المرور (${state.drivers.length})'
                  : 'Driver Fleet & Passwords (${state.drivers.length})',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: state.orders.any(
                  (o) =>
                      o.assignedDriverId.isEmpty ||
                      o.status == OrderStatus.placed,
                ),
                label: Text(
                  '${state.orders.where((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed).length}',
                ),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.receipt_long_rounded),
              ),
              text: isAr
                  ? 'الطلبات والإرسال (${state.orders.length}${state.orders.any((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed) ? " • ${state.orders.where((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed).length} جديد" : ""})'
                  : 'Orders & Dispatch (${state.orders.length}${state.orders.any((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed) ? " • ${state.orders.where((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed).length} New" : ""})',
            ),
            Tab(
              icon: const Icon(Icons.badge_outlined),
              text: isAr
                  ? 'الموظفين والعقود (${state.staffRequests.length})'
                  : 'Staff & Contracts (${state.staffRequests.length})',
            ),
            Tab(
              icon: const Icon(Icons.radar_rounded),
              text: isAr ? 'الطلبات الحية' : 'Live Orders',
            ),
            Tab(
              icon: Badge(
                isLabelVisible: state.unresolvedProblemsCount > 0,
                label: Text('${state.unresolvedProblemsCount}'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.warning_amber_rounded),
              ),
              text: isAr ? 'المشكلات والاستثناءات' : 'Problems & Fixes',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Operational Metrics Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: isAr ? 'المصابغ الفعالة' : 'Active Laundries',
                    value: '${state.laundries.length}',
                    subtitle: '100% TM Contracted',
                    icon: Icons.storefront_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: isAr ? 'الأسطول الميداني' : 'Active Fleet',
                    value: '${state.drivers.length} Drivers',
                    subtitle: 'GPS Broadcast: Online',
                    icon: Icons.electric_moped,
                    iconColor: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: isAr ? 'أرباح اليوم' : 'Today Revenue',
                    value: state.formatCurrency(14850.0),
                    subtitle: 'Platform fee: ${state.formatCurrency(2227.0)}',
                    icon: Icons.analytics_rounded,
                    iconColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final pendingCount = state.orders
                          .where(
                            (o) =>
                                o.assignedDriverId.isEmpty ||
                                o.status == OrderStatus.placed,
                          )
                          .length;
                      return StatCard(
                        title: isAr
                            ? 'طلبات بالانتظار (للتعيين)'
                            : 'Awaiting Driver Dispatch',
                        value: '$pendingCount Orders',
                        subtitle: pendingCount > 0
                            ? '🚨 Needs Admin Driver Assignment'
                            : 'All Orders Dispatched',
                        icon: Icons.sports_motorsports_rounded,
                        iconColor: pendingCount > 0
                            ? AppColors.error
                            : const Color(0xFF0284C7),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Urgent Admin Dispatch Alert Banner if pending orders exist
          Builder(
            builder: (context) {
              final pendingCount = state.orders
                  .where(
                    (o) =>
                        o.assignedDriverId.isEmpty ||
                        o.status == OrderStatus.placed,
                  )
                  .length;
              if (pendingCount == 0) return const SizedBox.shrink();
              return InkWell(
                onTap: () {
                  _tabController.animateTo(2);
                  setState(() => _orderFilter = 'pending');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 9,
                  ),
                  color: const Color(0xFFFEF2F2),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notification_important_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isAr
                              ? 'تنبيه إداري فوري: وصل $pendingCount طلبات جديدة مباشرة من العملاء بانتظار تعيين السائقين من قِبل الإدارة! اضغط للتعيين.'
                              : 'ADMIN DISPATCH ACTION: $pendingCount customer order(s) arrived directly to Admin awaiting driver assignment! Click to assign.',
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAr ? 'عرض وتعيين السائقين' : 'Dispatch Now',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Regional Event Offers, Ads & Dynamic Theming Controls Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: state.currentOccasionTheme.primaryColor.withValues(
                alpha: 0.05,
              ),
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: state.currentOccasionTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        state.currentOccasionTheme.iconEmoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${state.selectedCountry.flag} ${state.selectedCountry.code} REGION',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isAr
                      ? 'إدارة العروض والإعلانات والسمات لإقليم ${state.selectedCountry.name}:'
                      : 'Regional Marketing & Dynamic Theme Controls (${state.selectedCountry.name}):',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                // Manage Event Offers Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => SuperAdminEventOffersDialog.show(
                    context,
                    lockedCountryCode: state.selectedCountry.code,
                  ),
                  icon: const Icon(Icons.celebration, size: 14),
                  label: Text(
                    isAr
                        ? 'عروض المناسبات'
                        : 'Manage Event Offers (${state.activeEventOffers.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Ads & Messaging Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => AdManagementDialog.show(
                    context,
                    lockedCountryCode: state.selectedCountry.code,
                  ),
                  icon: const Icon(Icons.campaign, size: 14),
                  label: Text(
                    isAr
                        ? 'الإعلانات وبث الرسائل'
                        : 'Ads & Messaging (${state.activeAdvertisements.length})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Occasion Theming Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: state.currentOccasionTheme.primaryColor,
                    side: BorderSide(
                      color: state.currentOccasionTheme.primaryColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => OccasionThemingDialog.show(
                    context,
                    lockedCountryCode: state.selectedCountry.code,
                  ),
                  icon: const Icon(Icons.palette_outlined, size: 14),
                  label: Text(
                    isAr
                        ? 'تخصيص السمة'
                        : 'Occasion Theming (${state.currentOccasionTheme.iconEmoji})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Customer App Offer Popup Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.activePopupOffer?.isActive == true
                        ? const Color(0xFF0F766E)
                        : const Color(0xFF64748B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => AdminPopupManagerDialog.show(
                    context,
                    lockedCountryCode: state.selectedCountry.code,
                  ),
                  icon: const Icon(Icons.flash_on, size: 14),
                  label: Text(
                    isAr
                        ? 'نافذة بوب اب العروض ${state.activePopupOffer?.isActive == true ? "(مفعلة)" : "(معطلة)"}'
                        : 'Customer Popup (${state.activePopupOffer?.isActive == true ? "Active" : "Off"})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Laundries List & Warning Matrix & Folders
                _buildLaundriesTab(context, state),

                // Tab 2: Drivers List & Credential Recovery
                _buildDriversTab(context, state),

                // Tab 3: Lifetime Order Records & Instant Search / Print
                _buildOrderRecordsTab(context, state),

                // Tab 4: Staff & Contracts
                _buildStaffTab(context, state),

                // Tab 5: Live Orders Tracking
                SuperAdminLiveOrdersTab(isAr: isAr),

                // Tab 6: Operational Exceptions & Correction Tools
                SuperAdminOrderProblemsTab(isAr: isAr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 1: Laundries & Folders
  Widget _buildLaundriesTab(BuildContext context, StateService state) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.laundries.length,
      itemBuilder: (context, index) {
        final laundry = state.laundries[index];
        final stats = laundry.stats;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: laundry.warningStatus != WarningLevel.none
                  ? laundry.warningStatus.color
                  : const Color(0xFFE2E8F0),
              width: laundry.warningStatus != WarningLevel.none ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          laundry.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'User ID: ${laundry.userId}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  BadgePill(
                    label: laundry.warningStatus.displayName.toUpperCase(),
                    backgroundColor: laundry.warningStatus.color,
                    textColor: laundry.warningStatus.textColor,
                    icon: Icons.warning_amber_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Reg #: ${laundry.legalRegNumber} • Manager: ${laundry.managerName} (${laundry.phone})',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Today: ${stats.todayReceived} recvd | ${stats.todayInProcessing} washing | ${stats.todayReady} ready • Lifetime Orders: ${stats.lifetimeOrders} • Revenue: ${state.formatCurrency(stats.lifetimeRevenue)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Divider(height: 20),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () =>
                        LaundryProfileDialog.show(context, laundry),
                    icon: const Icon(Icons.folder_shared_outlined, size: 16),
                    label: const Text('Facility Folder & Password'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      final contract = state.contracts.firstWhere(
                        (c) => c.laundryId == laundry.id,
                        orElse: () => state.contracts.isNotEmpty
                            ? state.contracts.first
                            : LaundryContract(
                                id: 'cnt-${laundry.id}',
                                laundryId: laundry.id,
                                laundryName: laundry.name,
                                isGovRegistered: true,
                                isLawCompliant: true,
                                isLicenseClear: true,
                                signedAt: DateTime.now(),
                                signedBy: laundry.managerName,
                              ),
                      );
                      showDialog(
                        context: context,
                        builder: (_) => AdminContractDialog(contract: contract),
                      );
                    },
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('View Legal Contract'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          laundry.warningStatus == WarningLevel.none
                          ? AppColors.primary
                          : laundry.warningStatus.color,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AdminEscalationDialog(
                          entityName: laundry.name,
                          entityType: 'Laundry',
                          currentLevel: laundry.warningStatus,
                          onApply: (newLevel) {
                            state.setLaundryWarning(laundry.id, newLevel);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '⚠️ Warning level for "${laundry.name}" set to ${newLevel.displayName}',
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text('Escalation Warning Flow'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 2: Drivers List & Credential Recovery
  Widget _buildDriversTab(BuildContext context, StateService state) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.drivers.length,
      itemBuilder: (context, index) {
        final driver = state.drivers[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
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
                      Text(
                        driver.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'User ID: ${driver.userId}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: driver.affiliation.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: driver.affiliation.color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(driver.affiliation.icon, size: 12, color: driver.affiliation.color),
                            const SizedBox(width: 4),
                            Text(
                              driver.affiliation.fullTitle,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: driver.affiliation.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BadgePill(
                    label: driver.warningStatus.displayName.toUpperCase(),
                    backgroundColor: driver.warningStatus.color,
                    textColor: driver.warningStatus.textColor,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Phone: ${driver.phone} • QID: ${driver.qidPassportNumber} • License: ${driver.licenseNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Vehicle: ${driver.documents.vehicleRegPlate} • Assigned: ${driver.assignedLaundryName} • Rating: ⭐ ${driver.rating} • Earnings: ${state.formatCurrency(driver.todayEarningsQar)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => DriverFolderDialog.show(context, driver),
                    icon: const Icon(Icons.folder_shared_outlined, size: 16),
                    label: const Text('Open Folder & Password Vault'),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AdminEscalationDialog(
                          entityName: driver.fullName,
                          entityType: 'Driver',
                          currentLevel: driver.warningStatus,
                          onApply: (newLevel) {
                            state.setDriverWarning(driver.id, newLevel);
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.warning_amber, size: 16),
                    label: const Text('Warning Level'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 3: Lifetime Order Records & Admin Driver Dispatch Center
  Widget _buildOrderRecordsTab(BuildContext context, StateService state) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final isAr = state.currentLanguage == AppLanguage.ar;

    final pendingList = state.orders
        .where(
          (o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed,
        )
        .toList();
    final activeList = state.orders
        .where(
          (o) =>
              o.status == OrderStatus.driverAssigned ||
              o.status == OrderStatus.pickedUp ||
              o.status == OrderStatus.inLaundry ||
              o.status == OrderStatus.readyForDelivery ||
              o.status == OrderStatus.outForDelivery,
        )
        .toList();
    final deliveredList = state.orders
        .where((o) => o.status == OrderStatus.delivered)
        .toList();

    List<LaundryOrder> displayOrders;
    if (_orderFilter == 'pending') {
      displayOrders = pendingList;
    } else if (_orderFilter == 'active') {
      displayOrders = activeList;
    } else if (_orderFilter == 'delivered') {
      displayOrders = deliveredList;
    } else {
      displayOrders = state.orders;
    }

    return Column(
      children: [
        // Filter Chips Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                isAr ? 'تصفية الطلبات:' : 'Filter View:',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 10),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      isAr
                          ? 'جميع الطلبات (${state.orders.length})'
                          : 'All Orders (${state.orders.length})',
                    ),
                    selected: _orderFilter == 'all',
                    onSelected: (val) => setState(() => _orderFilter = 'all'),
                    selectedColor: const Color(0xFF0F172A),
                    labelStyle: TextStyle(
                      color: _orderFilter == 'all'
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  ChoiceChip(
                    avatar: pendingList.isNotEmpty
                        ? const Icon(
                            Icons.warning_amber_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                    label: Text(
                      isAr
                          ? 'بانتظار تعيين سائق (${pendingList.length})'
                          : '⚡ Awaiting Driver (${pendingList.length})',
                    ),
                    selected: _orderFilter == 'pending',
                    onSelected: (val) =>
                        setState(() => _orderFilter = 'pending'),
                    selectedColor: AppColors.error,
                    backgroundColor: pendingList.isNotEmpty
                        ? const Color(0xFFFEE2E2)
                        : null,
                    labelStyle: TextStyle(
                      color: _orderFilter == 'pending'
                          ? Colors.white
                          : (pendingList.isNotEmpty
                                ? AppColors.error
                                : const Color(0xFF334155)),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(
                      isAr
                          ? 'قيد التنفيذ (${activeList.length})'
                          : 'In Transit / Processing (${activeList.length})',
                    ),
                    selected: _orderFilter == 'active',
                    onSelected: (val) =>
                        setState(() => _orderFilter = 'active'),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _orderFilter == 'active'
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(
                      isAr
                          ? 'تم التسليم (${deliveredList.length})'
                          : 'Delivered (${deliveredList.length})',
                    ),
                    selected: _orderFilter == 'delivered',
                    onSelected: (val) =>
                        setState(() => _orderFilter = 'delivered'),
                    selectedColor: AppColors.success,
                    labelStyle: TextStyle(
                      color: _orderFilter == 'delivered'
                          ? Colors.white
                          : const Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Orders List
        Expanded(
          child: displayOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAr
                            ? 'لا توجد طلبات في هذا التصنيف'
                            : 'No orders found in this filter view.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: displayOrders.length,
                  itemBuilder: (context, index) {
                    final order = displayOrders[index];
                    final isAwaitingDriver =
                        order.assignedDriverId.isEmpty ||
                        order.status == OrderStatus.placed;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAwaitingDriver
                              ? AppColors.error.withValues(alpha: 0.6)
                              : const Color(0xFFE2E8F0),
                          width: isAwaitingDriver ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isAwaitingDriver
                                ? AppColors.error.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isAwaitingDriver) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFECACA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.notification_important_rounded,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isAr
                                          ? '⚠️ طلب وصل مباشرة من العميل • مطلوب إجراء إداري: تعيين سائق للمهمة'
                                          : '⚠️ Order sent directly from Customer • Admin Action Required: Assign Driver',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    isAr ? 'الإدارة حصراً' : 'Admin Dispatch',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF991B1B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: order.status.color.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  order.status.icon,
                                  color: order.status.color,
                                  size: 20,
                                ),
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
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (order.isUrgent) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDC2626),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              '🚨 URGENT RUSH',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 9.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: order.status.color
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            order.status.displayName,
                                            style: TextStyle(
                                              color: order.status.color,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          dateFormat.format(order.createdAt),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Customer: ${order.customerName} (${order.customerPhone}) • Address: ${order.address.formatted} • ${order.scheduleSummary}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Laundry: ${order.laundryName} • Items: ${order.items.length}  |  ',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        Icon(
                                          Icons.sports_motorsports_rounded,
                                          size: 14,
                                          color: isAwaitingDriver
                                              ? AppColors.error
                                              : AppColors.success,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isAwaitingDriver
                                              ? (isAr
                                                    ? 'السائق: غير معين (بانتظار الإدارة)'
                                                    : 'Driver: UNASSIGNED (Pending Admin)')
                                              : 'Driver: ${order.assignedDriverName} (${order.assignedDriverPhone})',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isAwaitingDriver
                                                ? AppColors.error
                                                : const Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    state.formatCurrency(order.totalAmount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Admin Assign / Reassign Driver Button
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isAwaitingDriver
                                              ? AppColors.error
                                              : const Color(0xFF0F766E),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () =>
                                            AdminAssignDriverDialog.show(
                                              context,
                                              order,
                                            ),
                                        icon: Icon(
                                          isAwaitingDriver
                                              ? Icons.person_add_alt_1_rounded
                                              : Icons.sync_alt_rounded,
                                          size: 13,
                                        ),
                                        label: Text(
                                          isAwaitingDriver
                                              ? (isAr
                                                    ? 'تعيين سائق'
                                                    : 'Assign Driver')
                                              : (isAr
                                                    ? 'تغيير السائق'
                                                    : 'Reassign'),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0F172A,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => OrderDetailDialog.show(
                                          context,
                                          order,
                                        ),
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 13,
                                        ),
                                        label: const Text(
                                          'View Record',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) =>
                                                LaundryThermalInvoiceDialog(
                                                  order: order,
                                                ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.print_rounded,
                                          size: 13,
                                        ),
                                        label: const Text(
                                          'Print',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // TAB 4: Staff & Contracts
  Widget _buildStaffTab(BuildContext context, StateService state) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.staffRequests.length,
      itemBuilder: (context, index) {
        final req = state.staffRequests[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    req.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  BadgePill(
                    label: req.isApprovedBySuperAdmin
                        ? 'APPROVED BY SUPER ADMIN'
                        : 'AWAITING SUPER ADMIN SIGN-OFF',
                    backgroundColor: req.isApprovedBySuperAdmin
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    textColor: req.isApprovedBySuperAdmin
                        ? AppColors.success
                        : const Color(0xFF92400E),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Position: ${req.role} • QID: ${req.idCardNumber} • Passport: ${req.passportNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Address: ${req.address} • Submitted by: ${req.regionalAdminName}',
                style: const TextStyle(fontSize: 11, color: AppColors.textDark),
              ),
            ],
          ),
        );
      },
    );
  }
}
