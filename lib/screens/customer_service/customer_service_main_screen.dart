import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/driver.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/order_problem.dart';
import '../../models/user.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/driver_navigation_helper.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/bulk_qr_generator_dialog.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/uniwash_logo.dart';
import '../common/order_detail_dialog.dart';
import 'customer_contact_dialog.dart';
import 'emergency_problem_solver_dialog.dart';
import 'live_order_tracking_dialog.dart';

class CustomerServiceMainScreen extends StatefulWidget {
  const CustomerServiceMainScreen({super.key});

  @override
  State<CustomerServiceMainScreen> createState() => _CustomerServiceMainScreenState();
}

class _CustomerServiceMainScreenState extends State<CustomerServiceMainScreen>
    with SingleTickerProviderStateMixin {
  // Navigation: 0=Overview, 1=Orders, 2=Radar, 3=Exceptions & Delays, 4=QR Studio, 5=Proofs Vault, 6=Communications
  int _selectedMenuIndex = 0;
  bool _isSidebarCollapsed = false;
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final allOrders = state.orders;
    final unresolvedProblems = state.orderProblems.where((p) => !p.isResolved).toList();
    final inTransitOrders = allOrders.where((o) =>
        o.status == OrderStatus.driverAssigned ||
        o.status == OrderStatus.pickedUp ||
        o.status == OrderStatus.readyForDelivery ||
        o.status == OrderStatus.outForDelivery).toList();

    // Filtered orders for Orders Tab
    final filteredOrders = allOrders.where((o) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesNum = o.orderNumber.toString().contains(q);
        final matchesCust = o.customerName.toLowerCase().contains(q);
        final matchesPhone = o.customerPhone.toLowerCase().contains(q);
        final matchesDriver = o.assignedDriverName.toLowerCase().contains(q);
        final matchesQr = o.qrCodePayload.toLowerCase().contains(q);
        if (!matchesNum && !matchesCust && !matchesPhone && !matchesDriver && !matchesQr) {
          return false;
        }
      }

      if (_selectedStatusFilter == 'all') return true;
      if (_selectedStatusFilter == 'exceptions') {
        return state.orderProblems.any((p) => p.orderId == o.id && !p.isResolved);
      }
      if (_selectedStatusFilter == 'pending_assign') {
        return o.status == OrderStatus.placed || o.assignedDriverId.isEmpty;
      }
      if (_selectedStatusFilter == 'in_transit') {
        return o.status == OrderStatus.driverAssigned ||
            o.status == OrderStatus.pickedUp ||
            o.status == OrderStatus.outForDelivery;
      }
      if (_selectedStatusFilter == 'in_laundry') {
        return o.status == OrderStatus.inLaundry || o.status == OrderStatus.readyForDelivery;
      }
      if (_selectedStatusFilter == 'delivered') {
        return o.status == OrderStatus.delivered;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100
      body: Row(
        children: [
          // ==========================================
          // 1. PROFESSIONAL LEFT-SIDE MAIN MENU
          // ==========================================
          _buildLeftSidebar(context, state, unresolvedProblems.length, inTransitOrders.length),

          // ==========================================
          // 2. MAIN OPERATIONS DASHBOARD WORKSPACE
          // ==========================================
          Expanded(
            child: Column(
              children: [
                // TOP OPS STATUS & SEARCH BAR
                _buildTopOpsBar(context, state, inTransitOrders.length),

                // ACTIVE VIEW WORKSPACE
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildActiveWorkspace(
                      context,
                      state,
                      filteredOrders,
                      allOrders,
                      unresolvedProblems,
                      inTransitOrders,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LEFT SIDEBAR MENU
  // ==========================================
  Widget _buildLeftSidebar(
    BuildContext context,
    StateService state,
    int unresolvedCount,
    int inTransitCount,
  ) {
    final sidebarWidth = _isSidebarCollapsed ? 76.0 : 270.0;

    final menuItems = [
      {
        'title': 'Ops Command & Overview',
        'icon': Icons.space_dashboard_rounded,
        'badge': null,
      },
      {
        'title': 'Orders Operations Console',
        'icon': Icons.local_shipping_rounded,
        'badge': '${state.orders.length}',
      },
      {
        'title': 'Live 24/7 GPS Fleet Radar',
        'icon': Icons.satellite_alt_rounded,
        'badge': inTransitCount > 0 ? '$inTransitCount' : null,
      },
      {
        'title': 'Exception & Delay Resolver',
        'icon': Icons.warning_amber_rounded,
        'badge': unresolvedCount > 0 ? '$unresolvedCount' : null,
        'badgeColor': const Color(0xFFDC2626),
      },
      {
        'title': 'QR Tag Studio & Print',
        'icon': Icons.qr_code_scanner_rounded,
        'badge': null,
      },
      {
        'title': 'Proofs, Media & Vault',
        'icon': Icons.photo_library_rounded,
        'badge': null,
      },
      {
        'title': 'Customer & Courier Comms',
        'icon': Icons.headset_mic_rounded,
        'badge': null,
      },
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Deep Corporate Slate
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sidebar Header / Logo
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _isSidebarCollapsed ? 12 : 18,
              vertical: 18,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                const UniWashLogo.badge(size: 32),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UniWash Operations',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                            SizedBox(width: 5),
                            Text(
                              'DOHA 24/7 LIVE HUB',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                IconButton(
                  onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                  icon: Icon(
                    _isSidebarCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  tooltip: _isSidebarCollapsed ? 'Expand Sidebar' : 'Collapse Sidebar',
                ),
              ],
            ),
          ),

          // Menu Navigation List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = _selectedMenuIndex == index;
                final badgeText = item['badge'] as String?;
                final badgeColor = (item['badgeColor'] as Color?) ?? const Color(0xFF0284C7);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedMenuIndex = index),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _isSidebarCollapsed ? 16 : 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSelected ? const Color(0xFF38BDF8) : Colors.transparent,
                            width: 3.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 20,
                            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8),
                          ),
                          if (!_isSidebarCollapsed) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (badgeText != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  badgeText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // User Profile & Switcher Footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: _isSidebarCollapsed
                ? IconButton(
                    icon: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF38BDF8), size: 22),
                    tooltip: 'Switch to Regional Admin',
                    onPressed: () => state.switchRole(UserRole.regionalAdmin),
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF0284C7),
                            child: Icon(Icons.support_agent_rounded, size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CS Operations Lead',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Super Agent • Duty Active',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFCBD5E1),
                            side: const BorderSide(color: Color(0xFF334155)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          icon: const Icon(Icons.admin_panel_settings_rounded, size: 14),
                          label: const Text('Admin Portal', style: TextStyle(fontSize: 11)),
                          onPressed: () => state.switchRole(UserRole.regionalAdmin),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TOP OPS BAR
  // ==========================================
  Widget _buildTopOpsBar(BuildContext context, StateService state, int inTransitCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Breadcrumb Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getMenuTitle(_selectedMenuIndex),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Text(
                'Full Operations Console • Live Radar Telemetry • Instant Problem Resolution',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Search Box
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by Order #, Customer, Mobile, Courier, QR...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Quick Pulse Badge
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 3.5,
                    backgroundColor: const Color(0xFF10B981).withValues(
                      alpha: 0.6 + (_pulseAnimation.value * 0.4),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '5G RADAR • $inTransitCount IN TRANSIT',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Action 1: Add Manual Booking
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
            label: const Text('+ Manual Order', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => _showAddManualOrderDialog(context, state),
          ),
          const SizedBox(width: 8),

          // Action 2: Batch QR Generator
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.qr_code_2_rounded, size: 16),
            label: const Text('Bulk QR Generator', style: TextStyle(fontSize: 12)),
            onPressed: () => BulkQrGeneratorDialog.show(context),
          ),
        ],
      ),
    );
  }

  String _getMenuTitle(int index) {
    switch (index) {
      case 0:
        return '📊 Operations Command Center & KPI Overview';
      case 1:
        return '📦 Order Operations & Fleet Dispatch Console';
      case 2:
        return '🛰️ Live 24/7 Real-Time Fleet Radar & GPS Telemetry';
      case 3:
        return '⚠️ Driver Exceptions, Delays & Admin Escalation';
      case 4:
        return '🏷️ Garment QR Code Studio (Add, Edit, Remove, Print)';
      case 5:
        return '📸 Courier Proofs, Photo/Video Vault & Call Logs';
      case 6:
        return '💬 Customer Check & Courier Intercom Radios';
      default:
        return 'Customer Support Operations Portal';
    }
  }

  // ==========================================
  // ACTIVE WORKSPACE ROUTER
  // ==========================================
  Widget _buildActiveWorkspace(
    BuildContext context,
    StateService state,
    List<LaundryOrder> filteredOrders,
    List<LaundryOrder> allOrders,
    List<OrderProblem> unresolvedProblems,
    List<LaundryOrder> inTransitOrders,
  ) {
    switch (_selectedMenuIndex) {
      case 0:
        return _buildOverviewDashboardTab(context, state, allOrders, inTransitOrders, unresolvedProblems);
      case 1:
        return _buildOrderOperationsTab(context, state, filteredOrders);
      case 2:
        return _buildLiveTrackingRadarTab(context, state, inTransitOrders);
      case 3:
        return _buildExceptionsAndDelayResolverTab(context, state, unresolvedProblems);
      case 4:
        return _buildQrStudioTab(context, state, allOrders);
      case 5:
        return _buildProofsAndMediaVaultTab(context, state, allOrders);
      case 6:
        return _buildCommunicationsTab(context, state, allOrders);
      default:
        return const Center(child: Text('Workspace not found'));
    }
  }

  // ==========================================
  // VIEW 0: OPS COMMAND & KPI OVERVIEW
  // ==========================================
  Widget _buildOverviewDashboardTab(
    BuildContext context,
    StateService state,
    List<LaundryOrder> allOrders,
    List<LaundryOrder> inTransitOrders,
    List<OrderProblem> unresolvedProblems,
  ) {
    final activeOrdersCount = allOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;
    final verifiedCount = allOrders.where((o) => o.isCustomerVerified).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Cards Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Active Pipeline',
                  value: '$activeOrdersCount',
                  subtitle: 'Orders processing today',
                  icon: Icons.sync_rounded,
                  iconColor: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  title: 'In-Transit Missions',
                  value: '${inTransitOrders.length}',
                  subtitle: 'Live GPS tracked couriers',
                  icon: Icons.satellite_alt_rounded,
                  iconColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  title: 'Unresolved Exceptions',
                  value: '${unresolvedProblems.length}',
                  subtitle: 'Driver mistakes / delays',
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.error,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  title: 'Customer Verified',
                  value: '$verifiedCount',
                  subtitle: 'Intake checked by CS',
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  title: 'Fleet On-Time SLA',
                  value: '99.4%',
                  subtitle: 'Doha delivery standard',
                  icon: Icons.speed_rounded,
                  iconColor: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // RADAR MINI-PREVIEW & QUICK CONTROL CENTER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radar Quick Panel
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.radar_rounded, color: Color(0xFF38BDF8), size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Real-Time Fleet Radar Sweep (Doha Metro)',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF38BDF8)),
                            icon: const Icon(Icons.open_in_new_rounded, size: 14),
                            label: const Text('Open Full Radar', style: TextStyle(fontSize: 12)),
                            onPressed: () => setState(() => _selectedMenuIndex = 2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1128),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.satellite_alt_rounded,
                                    size: 32 + (_pulseAnimation.value * 6),
                                    color: const Color(0xFF38BDF8),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${inTransitOrders.length} Couriers Active on Road • WebSockets Live (18ms)',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Lat: 25.2867° N, Lng: 51.5333° E • Full 5G Signal',
                                    style: TextStyle(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.9),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Operational Actions Hub
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 20),
                          SizedBox(width: 6),
                          Text(
                            'One-Touch Operational Interventions',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildQuickActionTile(
                        icon: Icons.doorbell_rounded,
                        title: 'Unreachable Doorstep Protocol',
                        subtitle: '15m countdown + contactless photo drop-off authorization',
                        color: const Color(0xFFD97706),
                        onTap: () {
                          if (allOrders.isNotEmpty) {
                            EmergencyProblemSolverDialog.show(context, allOrders.first);
                          }
                        },
                      ),
                      _buildQuickActionTile(
                        icon: Icons.edit_location_alt_rounded,
                        title: 'Customer Moved / Relocation',
                        subtitle: 'Update destination coordinates & reroute courier',
                        color: const Color(0xFF0284C7),
                        onTap: () {
                          if (allOrders.isNotEmpty) {
                            _showAddressRelocateDialog(context, state, allOrders.first);
                          }
                        },
                      ),
                      _buildQuickActionTile(
                        icon: Icons.emergency_rounded,
                        title: 'Driver Breakdown Re-Dispatch',
                        subtitle: '1-tap emergency courier switch & bag transfer',
                        color: const Color(0xFFDC2626),
                        onTap: () {
                          if (allOrders.isNotEmpty) {
                            EmergencyProblemSolverDialog.show(context, allOrders.first);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // RECENT OPERATIONS AUDIT STREAM
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 20, color: Color(0xFF0F172A)),
                    const SizedBox(width: 8),
                    const Text(
                      'Live Operations Audit & Action Trail',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      '${state.auditLogs.length} immutable events logged',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.auditLogs.take(5).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = state.auditLogs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: log.actionType.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.shield_outlined, size: 16, color: log.actionType.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${log.actionType.title} • ${log.entity}: ${log.entityId}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Change: ${log.newValue} (Reason: ${log.reason})',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(log.timestamp),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW 1: ORDERS OPERATIONS CONSOLE
  // ==========================================
  Widget _buildOrderOperationsTab(
    BuildContext context,
    StateService state,
    List<LaundryOrder> orders,
  ) {
    return Column(
      children: [
        // Status Filter Chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Wrap(
                spacing: 8,
                children: [
                  _buildFilterChip('all', 'All Orders (${state.orders.length})'),
                  _buildFilterChip('exceptions', '⚠️ Driver Exceptions'),
                  _buildFilterChip('pending_assign', '🆕 Unassigned'),
                  _buildFilterChip('in_transit', '🚚 In Transit'),
                  _buildFilterChip('in_laundry', '🧺 In Washing'),
                  _buildFilterChip('delivered', '✅ Delivered'),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Orders List
        Expanded(
          child: orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_rounded, size: 54, color: Colors.black26),
                      SizedBox(height: 12),
                      Text('No orders match your filter criteria', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final hasException = state.orderProblems.any((p) => p.orderId == order.id && !p.isResolved);
                    final assignedDriver = state.drivers.cast<DriverModel?>().firstWhere(
                          (d) => d?.id == order.assignedDriverId,
                          orElse: () => null,
                        );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasException ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                          width: hasException ? 1.5 : 1,
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
                          // Header Strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: hasException ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Order #${order.orderNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 10),
                                BadgePill(
                                  label: order.status.displayName,
                                  color: order.status.color,
                                  backgroundColor: order.status.color.withValues(alpha: 0.12),
                                ),
                                if (order.isUrgent) ...[
                                  const SizedBox(width: 8),
                                  BadgePill(
                                    label: '🚨 URGENT 4-HR RUSH',
                                    color: Colors.white,
                                    backgroundColor: const Color(0xFFDC2626),
                                    icon: Icons.bolt,
                                  ),
                                ],
                                const SizedBox(width: 8),
                                if (order.isCustomerVerified)
                                  BadgePill(
                                    label: 'Verified with Customer',
                                    color: const Color(0xFF16A34A),
                                    backgroundColor: const Color(0xFFDCFCE7),
                                  ),
                                if (hasException) ...[
                                  const SizedBox(width: 8),
                                  BadgePill(
                                    label: '⚠️ Driver Mistake / Delay Flagged',
                                    color: const Color(0xFFDC2626),
                                    backgroundColor: const Color(0xFFFEE2E2),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  state.canViewPrice()
                                      ? state.formatCurrency(order.totalAmount)
                                      : '${order.totalItemCount} Garment Items',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),

                          // Card Details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Customer & Destination
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.person, size: 16, color: Color(0xFF64748B)),
                                              const SizedBox(width: 6),
                                              Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                              const SizedBox(width: 8),
                                              Text(order.customerPhone, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 16, color: Color(0xFF64748B)),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  order.address.formatted,
                                                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.qr_code_2_rounded, size: 16, color: Color(0xFF0D9488)),
                                              const SizedBox(width: 6),
                                              Text(
                                                'QR: ${order.qrCodePayload}',
                                                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Color(0xFF0F766E)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Courier & Schedule
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.sports_motorsports_rounded, size: 16, color: Color(0xFF64748B)),
                                              const SizedBox(width: 6),
                                              Text('Driver: ${order.assignedDriverName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                              if (assignedDriver != null) ...[
                                                const SizedBox(width: 6),
                                                Text('(${assignedDriver.affiliation.shortBadge})', style: TextStyle(fontSize: 11, color: assignedDriver.affiliation.color, fontWeight: FontWeight.bold)),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.local_laundry_service_rounded, size: 16, color: Color(0xFF64748B)),
                                              const SizedBox(width: 6),
                                              Text('Laundry: ${order.laundryName}', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                                            ],
                                          ),
                                          if (order.specialInstructions.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Notes: ${order.specialInstructions}',
                                              style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 10),

                                // COMPLETE OPERATIONS CONTROLS SUITE
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    // 1. Live Radar Tracker
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0284C7),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      ),
                                      icon: const Icon(Icons.satellite_alt_rounded, size: 15),
                                      label: const Text('🛰️ Live Radar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => LiveOrderTrackingDialog.show(context, order),
                                    ),

                                    // 2. Universal Problem Solver
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDC2626),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      ),
                                      icon: const Icon(Icons.build_circle_rounded, size: 15),
                                      label: const Text('🛠️ Problem Solver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => EmergencyProblemSolverDialog.show(context, order),
                                    ),

                                    // 3. View Order Details
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.visibility_rounded, size: 15),
                                      label: const Text('View Order', style: TextStyle(fontSize: 12)),
                                      onPressed: () => OrderDetailDialog.show(context, order),
                                    ),

                                    // 4. Change Location / Relocate Customer
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0D9488)),
                                      icon: const Icon(Icons.edit_location_alt_rounded, size: 15),
                                      label: const Text('Change Location', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showAddressRelocateDialog(context, state, order),
                                    ),

                                    // 5. Reassign Driver
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF7C3AED)),
                                      icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                                      label: const Text('Reassign', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showReassignDialog(context, state, order),
                                    ),

                                    // 6. QR Code Studio (Add, Edit, Remove, Print)
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4F46E5)),
                                      icon: const Icon(Icons.qr_code_2_rounded, size: 15),
                                      label: const Text('QR Studio', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showQrStudioDialog(context, state, order),
                                    ),

                                    // 7. Reschedule Dates
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
                                      icon: const Icon(Icons.event_repeat_rounded, size: 15),
                                      label: const Text('Reschedule', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showRescheduleDialog(context, state, order),
                                    ),

                                    // 8. Order Check & Verify
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFD97706)),
                                      icon: const Icon(Icons.fact_check_rounded, size: 15),
                                      label: const Text('Order Check', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showOrderCheckDialog(context, state, order),
                                    ),

                                    // 9. Omnichannel Contact Customer (Live Chat, WhatsApp, Email, Phone)
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF059669),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                      ),
                                      icon: const Icon(Icons.forum_rounded, size: 15),
                                      label: const Text('Contact Customer (Chat / WA / Email)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      onPressed: () => _showContactCustomerDialog(context, state, order),
                                    ),

                                    // Quick WhatsApp Launch
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF16A34A)),
                                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 14),
                                      label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showContactCustomerDialog(context, state, order, initialTabIndex: 1),
                                    ),

                                    // Quick Live In-App Chat Launch
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0284C7)),
                                      icon: const Icon(Icons.mark_chat_unread_outlined, size: 14),
                                      label: const Text('Live Chat', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showContactCustomerDialog(context, state, order, initialTabIndex: 0),
                                    ),

                                    // Quick Email Launch
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF7C3AED)),
                                      icon: const Icon(Icons.mail_outline_rounded, size: 14),
                                      label: const Text('Email', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showContactCustomerDialog(context, state, order, initialTabIndex: 2),
                                    ),

                                    // 10. Request Proof from Courier
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE11D48)),
                                      icon: const Icon(Icons.photo_camera_rounded, size: 15),
                                      label: const Text('Request Proof', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showRequestProofDialog(context, state, order),
                                    ),

                                    // 11. Delay Root Cause Chat & Investigation
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB45309)),
                                      icon: const Icon(Icons.schedule_rounded, size: 15),
                                      label: const Text('Investigate Delay', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showDelayInvestigationDialog(context, state, order),
                                    ),

                                    // 12. Cancel / Delete
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                                      icon: const Icon(Icons.delete_outline_rounded, size: 15),
                                      label: const Text('Cancel / Delete', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _showDeleteOrderDialog(context, state, order),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : const Color(0xFF334155),
      ),
      onSelected: (val) {
        if (val) setState(() => _selectedStatusFilter = value);
      },
    );
  }

  // ==========================================
  // VIEW 2: LIVE 24/7 GPS FLEET RADAR
  // ==========================================
  Widget _buildLiveTrackingRadarTab(
    BuildContext context,
    StateService state,
    List<LaundryOrder> inTransitOrders,
  ) {
    return Column(
      children: [
        // Live Radar Header Strip
        Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.satellite_alt_rounded, color: Color(0xFF38BDF8), size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🛰️ Live Operations Fleet Radar & GPS Command',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 10),
                        BadgePill(
                          label: 'DOHA 5G REALTIME',
                          color: Color(0xFF10B981),
                          backgroundColor: Color(0xFF064E3B),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Live couriers in transit, GPS telemetry stream, route speeds & instant dispatcher problem interventions',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Text(
                      '${inTransitOrders.length} Active Missions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // In-transit missions list
        Expanded(
          child: inTransitOrders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.radar_rounded, size: 64, color: Colors.black26),
                      SizedBox(height: 12),
                      Text('No orders currently in courier transit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      SizedBox(height: 6),
                      Text('Assigned courier orders appear here with live telemetry blips.', style: TextStyle(color: Color(0xFF64748B))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: inTransitOrders.length,
                  itemBuilder: (context, index) {
                    final order = inTransitOrders[index];
                    final driver = state.drivers.cast<DriverModel?>().firstWhere(
                          (d) => d?.id == order.assignedDriverId,
                          orElse: () => null,
                        );

                    final currentLat = driver?.currentLat ?? (order.address.latitude != 0 ? order.address.latitude + 0.0075 : 25.2867);
                    final currentLng = driver?.currentLng ?? (order.address.longitude != 0 ? order.address.longitude - 0.0055 : 51.5333);
                    final plate = driver?.documents.vehicleRegPlate ?? 'QA-88192';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(radius: 4, backgroundColor: Color(0xFF0284C7)),
                                const SizedBox(width: 8),
                                Text('Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(width: 8),
                                BadgePill(
                                  label: order.status.displayName,
                                  color: order.status.color,
                                  backgroundColor: order.status.color.withValues(alpha: 0.12),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Lat: ${currentLat.toStringAsFixed(4)}°, Lng: ${currentLng.toStringAsFixed(4)}°',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0369A1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.sports_motorsports_rounded, size: 18, color: Color(0xFF0284C7)),
                                          const SizedBox(width: 6),
                                          Text(order.assignedDriverName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                          if (driver != null) ...[
                                            const SizedBox(width: 6),
                                            Text('(${driver.affiliation.shortBadge})', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: driver.affiliation.color)),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Van Plate: $plate • Phone: ${driver?.phone ?? '+974 5519 2841'}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFEA580C)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Destination: ${order.customerName} • ${order.address.formatted}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF86EFAC)),
                                      ),
                                      child: const Text('Speed: 38 km/h • Heading NE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text('Dynamic ETA: ~11 mins', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                                  icon: const Icon(Icons.satellite_alt_rounded, size: 16),
                                  label: const Text('Open Real-Time Radar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  onPressed: () => LiveOrderTrackingDialog.show(context, order),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
                                  icon: const Icon(Icons.build_circle_rounded, size: 16),
                                  label: const Text('Solve Problem', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  onPressed: () => EmergencyProblemSolverDialog.show(context, order),
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.ring_volume_rounded, size: 14, color: Color(0xFF0284C7)),
                                  label: const Text('Ping Courier', style: TextStyle(fontSize: 11)),
                                  onPressed: () {
                                    state.dispatchRadioPingToDriver(
                                      order.assignedDriverId,
                                      message: 'Operations Dispatch Ping: Check in with dispatch.',
                                      orderNumber: order.orderNumber,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('📡 Audio ping sent to ${order.assignedDriverName} for Order #${order.orderNumber}'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF16A34A)),
                                  label: const Text('Call', style: TextStyle(fontSize: 11)),
                                  onPressed: () => DriverNavigationHelper.callPhone(context, driver?.phone ?? order.customerPhone),
                                ),
                              ],
                            ),
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

  // ==========================================
  // VIEW 3: EXCEPTIONS, DELAYS & ADMIN ESCALATION
  // ==========================================
  Widget _buildExceptionsAndDelayResolverTab(
    BuildContext context,
    StateService state,
    List<OrderProblem> problems,
  ) {
    if (problems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 54, color: Color(0xFF16A34A)),
            const SizedBox(height: 12),
            const Text(
              'Zero Active Driver Mistakes or Unresolved Exceptions!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text('All courier scans, delivery proofs, and SLA timelines are in sync.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: problems.length,
      itemBuilder: (context, index) {
        final problem = problems[index];
        final order = state.orders.firstWhere(
          (o) => o.id == problem.orderId,
          orElse: () => state.orders.first,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: problem.severity.color.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: problem.severity.bgColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: problem.severity.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${problem.type.title} (Order #${problem.orderNumber})',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: problem.severity.color),
                    ),
                    const SizedBox(width: 8),
                    BadgePill(
                      label: problem.severity.label,
                      color: problem.severity.color,
                      backgroundColor: Colors.white,
                    ),
                    if (problem.isEscalatedToAdmin) ...[
                      const SizedBox(width: 8),
                      BadgePill(
                        label: '🚨 ESCALATED TO ADMIN (${problem.assignedAdminName})',
                        color: Colors.white,
                        backgroundColor: const Color(0xFFDC2626),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      DateFormat('hh:mm a').format(problem.reportedAt),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(problem.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                    if (problem.escalationReason != null) ...[
                      const SizedBox(height: 6),
                      Text('Admin Escalation Note: ${problem.escalationReason}', style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626), fontStyle: FontStyle.italic)),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Customer: ${problem.customerName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(width: 16),
                        Text('Reported By: ${problem.reportedBy}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(width: 16),
                        Text('Facility: ${problem.branchName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // RESOLUTION & ESCALATION CONTROLS
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // 1. Instant Problem Solver
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.build_circle_rounded, size: 16),
                          label: const Text('🛠️ Instant Problem Solver', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => EmergencyProblemSolverDialog.show(context, order),
                        ),

                        // 2. Real-Time Radar
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.satellite_alt_rounded, size: 16),
                          label: const Text('🛰️ Track Real-Time Radar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => LiveOrderTrackingDialog.show(context, order),
                        ),

                        // 3. ESCALATE & ASSIGN TO ADMIN
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C3AED),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.admin_panel_settings_rounded, size: 16),
                          label: const Text('🚨 Assign / Escalate to Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _showEscalateToAdminDialog(context, state, problem),
                        ),

                        // 4. Resolve Exception Ticket
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.check_circle_rounded, size: 16),
                          label: const Text('Mark Resolved', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _showResolveProblemDialog(context, state, problem),
                        ),

                        // 5. Contact Customer (Omnichannel Suite)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.forum_rounded, size: 15),
                          label: const Text('Contact Customer (Chat/WA/Email)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          onPressed: () => _showContactCustomerDialog(context, state, order),
                        ),

                        // 6. Reassign Driver
                        OutlinedButton.icon(
                          icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                          label: const Text('Reassign Driver', style: TextStyle(fontSize: 12)),
                          onPressed: () => _showReassignDialog(context, state, order),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // VIEW 4: QR CODE COMPLETE STUDIO
  // ==========================================
  Widget _buildQrStudioTab(BuildContext context, StateService state, List<LaundryOrder> allOrders) {
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: allOrders.length,
      itemBuilder: (context, index) {
        final order = allOrders[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF4F46E5), size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Order #${order.orderNumber} • ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(width: 8),
                          BadgePill(label: order.status.displayName, color: order.status.color, backgroundColor: order.status.color.withValues(alpha: 0.1)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('QR Payload: ${order.qrCodePayload}', style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: order.tags.isEmpty
                            ? [const Text('No tags assigned', style: TextStyle(fontSize: 11, color: Colors.grey))]
                            : order.tags.map((t) => BadgePill(label: 'Tag: $t', color: const Color(0xFF4F46E5), backgroundColor: const Color(0xFFEEF2FF))).toList(),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 16),
                  label: const Text('Manage & Print QR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _showQrStudioDialog(context, state, order),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // VIEW 5: PROOFS, MEDIA & VAULT
  // ==========================================
  Widget _buildProofsAndMediaVaultTab(BuildContext context, StateService state, List<LaundryOrder> allOrders) {
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: allOrders.length,
      itemBuilder: (context, index) {
        final order = allOrders[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_shared_rounded, color: Color(0xFF0284C7), size: 20),
                  const SizedBox(width: 8),
                  Text('Order #${order.orderNumber} Proofs Vault (${order.customerName})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(Icons.add_a_photo_rounded, size: 14),
                    label: const Text('Request Proof from Courier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _showRequestProofDialog(context, state, order),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildProofPill(
                    'Collection Proof Photo',
                    order.collectionProofPhoto != null || order.collectionQrScanned,
                    order.collectionProofPhoto ?? 'QR Verified at Doorstep',
                  ),
                  _buildProofPill(
                    'Laundry Arrival Photo',
                    order.laundryProofPhoto != null || order.laundryQrScanned,
                    order.laundryProofPhoto ?? 'Hub Intake Verified',
                  ),
                  _buildProofPill(
                    'Van Delivery Loading Photo',
                    order.deliveryLoadingBagHangerPhoto != null || order.deliveryLoadedInVan,
                    order.deliveryLoadingBagHangerPhoto ?? 'Loaded on Van Rack',
                  ),
                  _buildProofPill(
                    'Doorstep Delivery Photo',
                    order.deliveryProofPhoto != null || order.status == OrderStatus.delivered,
                    order.deliveryProofPhoto ?? 'Delivered & Handed Over',
                  ),
                ],
              ),
              if (order.attachments.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Special Media & PDF Attachments:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: order.attachments.map((a) {
                    return Chip(
                      avatar: Icon(a.isPdf ? Icons.picture_as_pdf : Icons.image, size: 14),
                      label: Text('${a.fileName} (${a.description})', style: const TextStyle(fontSize: 11)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProofPill(String title, bool isUploaded, String detail) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUploaded ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isUploaded ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUploaded ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
            size: 15,
            color: isUploaded ? const Color(0xFF16A34A) : const Color(0xFFD97706),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUploaded ? const Color(0xFF14532D) : const Color(0xFF92400E))),
              Text(isUploaded ? detail : 'Awaiting Courier Upload', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW 6: COMMUNICATIONS & OMNICHANNEL CONTACT DESK
  // ==========================================
  Widget _buildCommunicationsTab(BuildContext context, StateService state, List<LaundryOrder> allOrders) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 1. Omnichannel Operations Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.hub_rounded, color: Color(0xFF34D399), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '24/7 Omnichannel Customer & Courier Communications Desk',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Reach customers in real-time across Live In-App Chat, WhatsApp Business (wa.me), Official Email, and Phone voice logs with immutable audit trail.',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildOmnichannelChannelBadge(Icons.mark_chat_unread_rounded, 'Live In-App Chat', 'Interactive Real-Time Thread', const Color(0xFF0284C7)),
                  _buildOmnichannelChannelBadge(Icons.chat_bubble_rounded, 'WhatsApp Business', '1-Tap wa.me & Templates', const Color(0xFF16A34A)),
                  _buildOmnichannelChannelBadge(Icons.email_rounded, 'Official Email', 'mailto: & SMTP Gateway', const Color(0xFF7C3AED)),
                  _buildOmnichannelChannelBadge(Icons.phone_in_talk_rounded, 'Phone Telephony', 'Direct Dial + Notes Audit', const Color(0xFFD97706)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 2. Orders Communication List
        ...allOrders.map((order) {
          final customerEmail = '${order.customerName.toLowerCase().replaceAll(' ', '.')}@example.com';
          final notesCount = order.customerContactNotes.length;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x05000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Customer Identity Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFF1F5F9),
                      child: Text(
                        order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : 'C',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A), fontSize: 16),
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
                                order.customerName,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 8),
                              BadgePill(
                                label: 'Order #${order.orderNumber}',
                                backgroundColor: const Color(0xFFF1F5F9),
                                textColor: const Color(0xFF334155),
                              ),
                              const SizedBox(width: 6),
                              BadgePill(
                                label: order.status.displayName,
                                backgroundColor: const Color(0xFFEFF6FF),
                                textColor: const Color(0xFF1D4ED8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 12,
                            runSpacing: 4,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_rounded, size: 13, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(order.customerPhone, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.email_outlined, size: 13, color: Color(0xFF64748B)),
                                  const SizedBox(width: 4),
                                  Text(customerEmail, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                              if (order.assignedDriverName.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.sports_motorsports_rounded, size: 13, color: Color(0xFF0284C7)),
                                    const SizedBox(width: 4),
                                    Text('Courier: ${order.assignedDriverName}', style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // Omnichannel Action Button Bar
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Primary Dialog Launcher
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.forum_rounded, size: 15),
                      label: const Text('Open Omnichannel Hub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      onPressed: () => _showContactCustomerDialog(context, state, order),
                    ),

                    // Quick Live In-App Chat
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0284C7),
                        side: const BorderSide(color: Color(0xFFBAE6FD)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.mark_chat_unread_rounded, size: 14),
                      label: const Text('💬 Live Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () => _showContactCustomerDialog(context, state, order, initialTabIndex: 0),
                    ),

                    // Quick WhatsApp
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16A34A),
                        side: const BorderSide(color: Color(0xFFBBF7D0)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.chat_bubble_rounded, size: 14),
                      label: const Text('🟢 WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () => _showContactCustomerDialog(context, state, order, initialTabIndex: 1),
                    ),

                    // Quick Email
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                        side: const BorderSide(color: Color(0xFFDDD6FE)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.email_rounded, size: 14),
                      label: const Text('📧 Send Email', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () => _showContactCustomerDialog(context, state, order, initialTabIndex: 2),
                    ),

                    // Quick Voice Call Log
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD97706),
                        side: const BorderSide(color: Color(0xFFFDE68A)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
                      label: const Text('📞 Phone Call Log', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      onPressed: () => _showContactCustomerDialog(context, state, order, initialTabIndex: 3),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Communications History Log
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.history_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Text(
                            'Communication Audit Trail ($notesCount entries)',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (order.customerContactNotes.isEmpty)
                        Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'No previous communications recorded for this order. Use the buttons above to message via Live Chat, WhatsApp, Email, or Phone.',
                                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: order.customerContactNotes.map((note) {
                            return _buildOmnichannelLogItem(note);
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOmnichannelChannelBadge(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
              Text(subtitle, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOmnichannelLogItem(String note) {
    Color badgeColor = const Color(0xFF64748B);
    IconData badgeIcon = Icons.message_rounded;
    String channelLabel = 'Log';

    final lower = note.toLowerCase();
    if (lower.contains('whatsapp')) {
      badgeColor = const Color(0xFF16A34A);
      badgeIcon = Icons.chat_bubble_rounded;
      channelLabel = 'WhatsApp';
    } else if (lower.contains('email')) {
      badgeColor = const Color(0xFF7C3AED);
      badgeIcon = Icons.email_rounded;
      channelLabel = 'Email';
    } else if (lower.contains('live chat') || lower.contains('chat')) {
      badgeColor = const Color(0xFF0284C7);
      badgeIcon = Icons.mark_chat_unread_rounded;
      channelLabel = 'Live Chat';
    } else if (lower.contains('phone') || lower.contains('call')) {
      badgeColor = const Color(0xFFD97706);
      badgeIcon = Icons.phone_in_talk_rounded;
      channelLabel = 'Call';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(badgeIcon, size: 11, color: badgeColor),
                const SizedBox(width: 4),
                Text(channelLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: badgeColor)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // OPERATIONAL ACTION DIALOGS
  // ==========================================

  // 1. ESCALATE & ASSIGN TO ADMIN DIALOG
  void _showEscalateToAdminDialog(BuildContext context, StateService state, OrderProblem problem) {
    String selectedAdmin = 'Regional Admin (Rashid Al-Sulaiti)';
    final reasonCtrl = TextEditingController(text: 'High-severity exception requires executive admin override and approval.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('🚨 Escalate Problem to Admin (Order #${problem.orderNumber})', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Problem: ${problem.type.title} • Severity: ${problem.severity.label}', style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(problem.description, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedAdmin,
                  decoration: const InputDecoration(labelText: 'Assign to Operations Admin *'),
                  items: const [
                    DropdownMenuItem(value: 'Regional Admin (Rashid Al-Sulaiti)', child: Text('Regional Admin (Rashid Al-Sulaiti)')),
                    DropdownMenuItem(value: 'Super Admin (Sheikh Faisal Al-Thani)', child: Text('Super Admin (Sheikh Faisal Al-Thani)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedAdmin = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Supervisor Escalation Justification *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
              onPressed: () {
                state.escalateProblemToAdmin(
                  problem.id,
                  adminName: selectedAdmin,
                  reason: reasonCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🚨 Problem #${problem.id} successfully escalated to $selectedAdmin!'),
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                );
              },
              child: const Text('Escalate Ticket to Admin'),
            ),
          ],
        ),
      ),
    );
  }

  // 2. REQUEST PROOF FROM DRIVER DIALOG
  void _showRequestProofDialog(BuildContext context, StateService state, LaundryOrder order) {
    String selectedProof = 'Doorstep Delivery Proof Photo';
    final notesCtrl = TextEditingController(text: 'Mandatory photographic verification required by CS agent.');

    final proofTypes = [
      'Doorstep Delivery Proof Photo',
      'Collection Bag Proof Photo',
      'Laundry Intake Scale Photo',
      'Van Rack Loading Photo',
      'Pre-wash Stains / Delicate Inspection Video',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Request Proof from Courier (Order #${order.orderNumber})', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned Courier: ${order.assignedDriverName}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedProof,
                  decoration: const InputDecoration(labelText: 'Select Mandatory Proof Type *'),
                  items: proofTypes.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedProof = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Instructions for Courier *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), foregroundColor: Colors.white),
              onPressed: () {
                state.requestProofFromDriver(
                  order.id,
                  proofType: selectedProof,
                  notes: notesCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('📸 Mandatory proof request dispatched to ${order.assignedDriverName}!'),
                    backgroundColor: const Color(0xFFE11D48),
                  ),
                );
              },
              child: const Text('Dispatch Proof Request'),
            ),
          ],
        ),
      ),
    );
  }

  // 3. DELAY INVESTIGATION & CHAT EXPLANATION DIALOG
  void _showDelayInvestigationDialog(BuildContext context, StateService state, LaundryOrder order) {
    String selectedReason = 'Traffic Congestion (Corniche / Lusail Expressway)';
    final explanationCtrl = TextEditingController(text: 'Courier reported road blockage and heavy detour delays.');

    final reasons = [
      'Traffic Congestion (Corniche / Lusail Expressway)',
      'Customer Not Answering Doorbell / Delayed Access',
      'Laundry Facility High Volume Pressing Queue',
      'Courier Van Breakdown / Flat Tire Detour',
      'Weather / Sandstorm Visibility Advisory',
      'Customer Requested Later Time Slot',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Investigate Delay • Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order.customerName} • Courier: ${order.assignedDriverName}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  decoration: const InputDecoration(labelText: 'Documented Root Cause *'),
                  items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedReason = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: explanationCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Courier Explanation & Chat Notes *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB45309), foregroundColor: Colors.white),
              onPressed: () {
                state.recordDelayRootCause(
                  order.id,
                  reason: selectedReason,
                  driverExplanation: explanationCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('⚠️ Delay explanation recorded for Order #${order.orderNumber}.'),
                    backgroundColor: const Color(0xFFB45309),
                  ),
                );
              },
              child: const Text('Save Delay Explanation'),
            ),
          ],
        ),
      ),
    );
  }

  // 4. QR CODE COMPLETE STUDIO DIALOG (Add, Edit, Delete/Remove, View & Print)
  void _showQrStudioDialog(BuildContext context, StateService state, LaundryOrder order) {
    final qrCtrl = TextEditingController(text: order.qrCodePayload);
    final tagsList = List<String>.from(order.tags);
    final newTagCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('QR Studio • Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_2_rounded, size: 100, color: Color(0xFF0F172A)),
                          const SizedBox(height: 8),
                          Text(
                            order.qrCodePayload,
                            style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: qrCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Edit / Override QR Payload String',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
                        icon: const Icon(Icons.save_rounded, size: 15),
                        label: const Text('Update QR Payload'),
                        onPressed: () {
                          state.replaceOrderQrPayload(
                            order.id,
                            qrCtrl.text.trim(),
                            reason: 'CS Supervisor edited QR payload in QR Studio',
                          );
                          setDialogState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                        icon: const Icon(Icons.delete_outline_rounded, size: 15),
                        label: const Text('Delete / Reset QR'),
                        onPressed: () {
                          state.removeOrderQrPayload(order.id, reason: 'Reset to system standard QR code');
                          qrCtrl.text = order.qrCodePayload;
                          setDialogState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Manage Garment Bag Tags:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tagsList.map((t) {
                      return Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        onDeleted: () {
                          setDialogState(() => tagsList.remove(t));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newTagCtrl,
                          decoration: const InputDecoration(hintText: 'Add new tag (e.g. VIP Silk)', isDense: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (newTagCtrl.text.trim().isNotEmpty) {
                            setDialogState(() {
                              tagsList.add(newTagCtrl.text.trim());
                              newTagCtrl.clear();
                            });
                          }
                        },
                        child: const Text('Add Tag'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                state.updateOrderTags(order.id, tagsList);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ QR Studio changes applied.')),
                );
              },
              child: const Text('Save & Apply All'),
            ),
          ],
        ),
      ),
    );
  }

  // 5. CHANGE LOCATION / RELOCATE CUSTOMER DIALOG
  void _showAddressRelocateDialog(BuildContext context, StateService state, LaundryOrder order) {
    final bldgCtrl = TextEditingController(text: order.address.buildingNo);
    final streetCtrl = TextEditingController(text: order.address.streetNo);
    final zoneCtrl = TextEditingController(text: order.address.zoneNo);
    final aptCtrl = TextEditingController(text: order.address.apartmentRoom);
    final cityCtrl = TextEditingController(text: order.address.city);
    final notesCtrl = TextEditingController(text: order.deliveryLocationNote ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Relocate Customer • Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer relocated or provided updated residence coordinates:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: TextField(controller: bldgCtrl, decoration: const InputDecoration(labelText: 'Building No. *', isDense: true))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: 'Street No. *', isDense: true))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: zoneCtrl, decoration: const InputDecoration(labelText: 'Zone *', isDense: true))),
                    const SizedBox(width: 10),
                    Expanded(child: TextField(controller: aptCtrl, decoration: const InputDecoration(labelText: 'Apt / Flat *', isDense: true))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City *', isDense: true)),
                const SizedBox(height: 10),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Access Code / Gate Notes', isDense: true)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white),
            onPressed: () {
              final newAddress = CustomerAddress(
                buildingNo: bldgCtrl.text.trim(),
                streetNo: streetCtrl.text.trim(),
                zoneNo: zoneCtrl.text.trim(),
                apartmentRoom: aptCtrl.text.trim(),
                city: cityCtrl.text.trim().isEmpty ? 'Doha' : cityCtrl.text.trim(),
                latitude: order.address.latitude != 0 ? order.address.latitude + 0.001 : 25.2867,
                longitude: order.address.longitude != 0 ? order.address.longitude + 0.001 : 51.5333,
              );
              order.deliveryLocationNote = notesCtrl.text.trim();
              state.updateOrderAddress(order.id, newAddress);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('📍 Destination updated to: ${newAddress.formatted} • Courier rerouted!'),
                  backgroundColor: const Color(0xFF0284C7),
                ),
              );
            },
            child: const Text('Save & Reroute Courier'),
          ),
        ],
      ),
    );
  }

  // 6. RESCHEDULE DIALOG
  void _showRescheduleDialog(BuildContext context, StateService state, LaundryOrder order) {
    DateTime selectedPickupDate = order.scheduledPickupDate ?? DateTime.now();
    DateTime selectedDeliveryDate = order.scheduledDeliveryDate ?? DateTime.now().add(const Duration(days: 1));
    String selectedPickupSlot = order.scheduledPickupSlot ?? '09:00 AM - 12:00 PM (Morning)';
    String selectedDeliverySlot = order.scheduledDeliverySlot ?? '04:00 PM - 07:00 PM (Evening)';
    final reasonCtrl = TextEditingController(text: 'Customer requested reschedule via CS phone call.');

    final slots = [
      '09:00 AM - 12:00 PM (Morning)',
      '12:00 PM - 03:00 PM (Afternoon)',
      '03:00 PM - 06:00 PM (Early Evening)',
      '06:00 PM - 09:00 PM (Night Express)',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Reschedule Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${order.customerName} (${order.customerPhone})', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  const SizedBox(height: 16),
                  const Text('Pickup Schedule:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('dd MMM yyyy').format(selectedPickupDate)),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: selectedPickupDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (d != null) setDialogState(() => selectedPickupDate = d);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPickupSlot,
                    decoration: const InputDecoration(labelText: 'Pickup Time Window'),
                    items: slots.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedPickupSlot = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Delivery Schedule:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('dd MMM yyyy').format(selectedDeliveryDate)),
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: selectedDeliveryDate,
                        firstDate: selectedPickupDate,
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (d != null) setDialogState(() => selectedDeliveryDate = d);
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDeliverySlot,
                    decoration: const InputDecoration(labelText: 'Delivery Time Window'),
                    items: slots.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedDeliverySlot = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(labelText: 'Operational Reason for Reschedule *'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                state.rescheduleOrder(
                  order.id,
                  pickupDate: selectedPickupDate,
                  pickupSlot: selectedPickupSlot,
                  deliveryDate: selectedDeliveryDate,
                  deliverySlot: selectedDeliverySlot,
                  reason: reasonCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Order #${order.orderNumber} successfully rescheduled.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Apply Reschedule'),
            ),
          ],
        ),
      ),
    );
  }

  // 7. REASSIGN DRIVER DIALOG
  void _showReassignDialog(BuildContext context, StateService state, LaundryOrder order) {
    String selectedDriverId = order.assignedDriverId.isEmpty ? state.drivers.first.id : order.assignedDriverId;
    String selectedLaundryId = order.laundryId;
    final reasonCtrl = TextEditingController(text: 'Reassigned by Customer Service for optimal route balance.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Reassign Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Driver:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDriverId,
                    decoration: const InputDecoration(labelText: 'Assigned Driver'),
                    items: state.drivers.map((d) {
                      return DropdownMenuItem(
                        value: d.id,
                        child: Text(
                          '${d.fullName} (${d.affiliation.shortBadge} • ${d.phone})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedDriverId = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Laundry Hub:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLaundryId,
                    decoration: const InputDecoration(labelText: 'Assigned Laundry Partner'),
                    items: state.laundries.map((l) {
                      return DropdownMenuItem(
                        value: l.id,
                        child: Text('${l.name} (${l.phone})', style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedLaundryId = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(labelText: 'Reassignment Reason *'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                state.reassignOrderDriver(order.id, selectedDriverId, reason: reasonCtrl.text.trim());
                if (selectedLaundryId != order.laundryId) {
                  state.reassignOrderBranch(order.id, selectedLaundryId, reason: reasonCtrl.text.trim());
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Order #${order.orderNumber} reassigned.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Save Reassignment'),
            ),
          ],
        ),
      ),
    );
  }

  // 8. ORDER CHECK DIALOG
  void _showOrderCheckDialog(BuildContext context, StateService state, LaundryOrder order) {
    bool isConfirmed = order.isCustomerVerified;
    final notesCtrl = TextEditingController(text: 'Garments intake count verified. No pre-existing tears observed.');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Order Check & Verification #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order.customerName} • Items: ${order.totalItemCount}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                CheckboxListTile(
                  title: const Text('Customer Verified Intake', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: const Text('Customer confirmed piece count & special fabric care'),
                  value: isConfirmed,
                  onChanged: (val) => setDialogState(() => isConfirmed = val ?? false),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Verification Notes *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
              onPressed: () {
                order.isCustomerVerified = isConfirmed;
                state.verifyOrderCheck(order.id, checkNotes: notesCtrl.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Order verification updated.'), backgroundColor: Color(0xFF059669)),
                );
              },
              child: const Text('Save Verification'),
            ),
          ],
        ),
      ),
    );
  }

  // 9. CONTACT CUSTOMER DIALOG (OMNICHANNEL SUITE: LIVE CHAT, WHATSAPP, EMAIL, PHONE)
  void _showContactCustomerDialog(
    BuildContext context,
    StateService state,
    LaundryOrder order, {
    int initialTabIndex = 0,
  }) {
    CustomerContactDialog.show(
      context,
      order,
      initialTabIndex: initialTabIndex,
    );
  }

  // 10. RESOLVE EXCEPTION DIALOG
  void _showResolveProblemDialog(BuildContext context, StateService state, OrderProblem problem) {
    String selectedAction = 'Corrected QR & Overrode Status with Supervisor Approval';
    final notesCtrl = TextEditingController(text: 'Driver mistake rectified. Verified against intake telemetry.');

    final actions = [
      'Corrected QR & Overrode Status with Supervisor Approval',
      'Reassigned to Company Driver Fleet for Redelivery',
      'Rescheduled Pickup/Delivery with Customer Agreement',
      'Damage Claim Settled & Garment Inspected',
      'Wrong Address Corrected & GPS Location Updated',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Fix Problem: ${problem.type.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${problem.orderNumber} • ${problem.customerName}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedAction,
                  decoration: const InputDecoration(labelText: 'Correction Action Taken'),
                  items: actions.map((a) => DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedAction = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Resolution Notes *'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
              onPressed: () {
                state.resolveOrderProblem(
                  problem.id,
                  action: selectedAction,
                  notes: notesCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Problem #${problem.id} resolved successfully.')),
                );
              },
              child: const Text('Resolve Problem'),
            ),
          ],
        ),
      ),
    );
  }

  // 11. CANCEL / DELETE ORDER DIALOG
  void _showDeleteOrderDialog(BuildContext context, StateService state, LaundryOrder order) {
    final reasonCtrl = TextEditingController(text: 'Cancelled by customer via Customer Support hotline.');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Order #${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to cancel and delete Order #${order.orderNumber}?', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 14),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Cancellation Reason *'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Back')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () {
              state.deleteOrder(order.id, reason: reasonCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Order #${order.orderNumber} has been cancelled.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  // 12. ADD MANUAL BOOKING DIALOG
  void _showAddManualOrderDialog(BuildContext context, StateService state) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+974 ');
    final bldgCtrl = TextEditingController(text: '12');
    final streetCtrl = TextEditingController(text: 'Al Sadd St');
    final zoneCtrl = TextEditingController(text: '38');
    final aptCtrl = TextEditingController(text: '402');
    String selectedLaundryId = state.laundries.first.id;
    String selectedDriverId = state.drivers.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Manual Booking (Call / WhatsApp)', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Customer Name *', isDense: true))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Qatar Mobile (+974) *', isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: bldgCtrl, decoration: const InputDecoration(labelText: 'Bldg No. *', isDense: true))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: streetCtrl, decoration: const InputDecoration(labelText: 'Street *', isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: zoneCtrl, decoration: const InputDecoration(labelText: 'Zone *', isDense: true))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: aptCtrl, decoration: const InputDecoration(labelText: 'Apt / Flat *', isDense: true))),
                    ],
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLaundryId,
                    decoration: const InputDecoration(labelText: 'Laundry Facility *', isDense: true),
                    items: state.laundries.map((l) => DropdownMenuItem(value: l.id, child: Text(l.name, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedLaundryId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDriverId,
                    decoration: const InputDecoration(labelText: 'Assign Driver *', isDense: true),
                    items: state.drivers.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.fullName} (${d.affiliation.shortBadge})', style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedDriverId = val);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;

                final chosenLaundry = state.laundries.firstWhere((l) => l.id == selectedLaundryId);
                final chosenDriver = state.drivers.firstWhere((d) => d.id == selectedDriverId);

                final newOrder = state.createManualOrder(
                  customerName: nameCtrl.text.trim(),
                  customerPhone: phoneCtrl.text.trim(),
                  address: CustomerAddress(
                    buildingNo: bldgCtrl.text.trim(),
                    streetNo: streetCtrl.text.trim(),
                    zoneNo: zoneCtrl.text.trim(),
                    apartmentRoom: aptCtrl.text.trim(),
                    city: 'Doha',
                  ),
                  items: [
                    OrderItem(
                      catalogItem: state.catalogItems.first,
                      quantity: 3,
                    ),
                  ],
                  laundryId: chosenLaundry.id,
                  laundryName: chosenLaundry.name,
                  specialInstructions: 'Manual phone booking created by Support Operations',
                );

                state.reassignOrderDriver(newOrder.id, chosenDriver.id, reason: 'Assigned at manual intake');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Manual Order #${newOrder.orderNumber} placed & assigned to ${chosenDriver.fullName}.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Create & Dispatch Order'),
            ),
          ],
        ),
      ),
    );
  }
}
