import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/advertisement.dart';
import '../../models/contract.dart';
import '../../models/driver.dart';
import '../../models/laundry.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/super_search_bar.dart';
import '../../widgets/uniwash_logo.dart';
import '../admin/admin_assign_driver_dialog.dart';
import '../admin/admin_contract_dialog.dart';
import '../admin/admin_escalation_dialog.dart';
import '../admin/admin_staff_dialog.dart';
import '../common/driver_folder_dialog.dart';
import '../common/laundry_profile_dialog.dart';
import '../common/order_detail_dialog.dart';
import '../laundry/laundry_thermal_invoice_dialog.dart';
import 'super_admin_catalog_tab.dart';
import 'super_admin_event_offers_dialog.dart';
import 'super_admin_hourly_audit_tab.dart';
import 'super_admin_countries_branches_tab.dart';
import 'super_admin_admins_team_tab.dart';
import 'super_admin_live_orders_tab.dart';
import 'super_admin_order_problems_tab.dart';
import 'super_admin_audit_logs_tab.dart';
import 'super_admin_customers_tab.dart';
import 'super_admin_reports_dialog.dart';

class SuperAdminMainScreen extends StatefulWidget {
  const SuperAdminMainScreen({super.key});

  @override
  State<SuperAdminMainScreen> createState() => _SuperAdminMainScreenState();
}

class _SuperAdminMainScreenState extends State<SuperAdminMainScreen> with SingleTickerProviderStateMixin {
  // Navigation: 0 = Admin, 1 = Laundry, 2 = Driver, 3 = Management System, 4 = Settings, 5 = About, 6 = Help
  int _selectedNavIndex = 0;

  // Management System Sub-tab: 0 = Orders, 1 = Ads & Promos, 2 = Catalog & Pricing, 3 = Hourly Audit, 4 = Staff Approvals
  int _mgmtSubTabIndex = 0;

  // Search and filters
  String _ordersFilter = 'all';
  String _laundrySearch = '';
  String _driverSearch = '';

  // Settings State variables
  bool _autoDispatchEnabled = false;
  bool _whatsappAlertsEnabled = true;
  bool _smsGatewayEnabled = true;
  double _taxVatRate = 0.0; // 0% Qatar

  final List<Map<String, dynamic>> _territories = [
    {
      'name': 'Qatar',
      'flag': '🇶🇦',
      'code': 'QAT',
      'currency': 'QAR',
      'customersCount': 5420,
      'activeLaundries': 18,
      'driversCount': 36,
      'orders': 14280,
      'revenue': '1,480,900 QAR',
      'hqAddress': 'Level 24, Al Fardan Commercial Towers, West Bay, Doha, Qatar',
      'officeStaff': [
        {'name': 'Eng. Sheikh Faisal Al-Thani', 'role': 'Regional Managing Director', 'phone': '+974 4499 1000', 'email': 'faisal.director@uniwash.qa'},
        {'name': 'Mona Al-Kuwari', 'role': 'Regional Operations & QA Lead', 'phone': '+974 4499 1001', 'email': 'mona.ops@uniwash.qa'},
        {'name': 'Ahmed Tariq', 'role': 'Logistics & Fleet Supervisor', 'phone': '+974 4499 1002', 'email': 'dispatch.doha@uniwash.qa'},
        {'name': 'Sara Mansoor', 'role': 'Customer Dispute & Accounts Officer', 'phone': '+974 4499 1003', 'email': 'support.doha@uniwash.qa'},
      ],
    },
    {
      'name': 'United Arab Emirates',
      'flag': '🇦🇪',
      'code': 'UAE',
      'currency': 'AED',
      'customersCount': 14800,
      'activeLaundries': 42,
      'driversCount': 85,
      'orders': 38200,
      'revenue': '3,820,000 AED',
      'hqAddress': 'Level 18, Burj Daman Building, DIFC, Dubai, UAE',
      'officeStaff': [
        {'name': 'Zayed Al-Nuaimi', 'role': 'UAE General Manager', 'phone': '+971 4 330 9900', 'email': 'zayed.gm@uniwash.ae'},
        {'name': 'Farah El-Sayed', 'role': 'Dubai & Northern Emirates Ops Lead', 'phone': '+971 4 330 9901', 'email': 'farah.ops@uniwash.ae'},
        {'name': 'Rashid Al-Falasi', 'role': 'Fleet & Dispatch Coordinator', 'phone': '+971 4 330 9902', 'email': 'fleet.dubai@uniwash.ae'},
        {'name': 'Kavita Patel', 'role': 'Regional Quality Inspector', 'phone': '+971 4 330 9903', 'email': 'quality.uae@uniwash.ae'},
      ],
    },
    {
      'name': 'Saudi Arabia',
      'flag': '🇸🇦',
      'code': 'KSA',
      'currency': 'SAR',
      'customersCount': 24900,
      'activeLaundries': 65,
      'driversCount': 130,
      'orders': 62100,
      'revenue': '5,940,000 SAR',
      'hqAddress': 'King Fahd Road, Al-Olaya Business District, Riyadh, KSA',
      'officeStaff': [
        {'name': 'Sultan Al-Ghamdi', 'role': 'KSA Country Managing Director', 'phone': '+966 11 400 8800', 'email': 'sultan.md@uniwash.sa'},
        {'name': 'Abdulaziz Al-Shehri', 'role': 'Central & Western Provinces Ops Lead', 'phone': '+966 11 400 8801', 'email': 'aziz.ops@uniwash.sa'},
        {'name': 'Fahad Al-Otaibi', 'role': 'Kingdom Logistics & Van Fleet Officer', 'phone': '+966 11 400 8802', 'email': 'fleet.riyadh@uniwash.sa'},
        {'name': 'Laila Al-Harbi', 'role': 'Customer Experience & Regulatory Lead', 'phone': '+966 11 400 8803', 'email': 'laila.support@uniwash.sa'},
      ],
    },
    {
      'name': 'Kuwait',
      'flag': '🇰🇼',
      'code': 'KWT',
      'currency': 'KWD',
      'customersCount': 4200,
      'activeLaundries': 12,
      'driversCount': 28,
      'orders': 9800,
      'revenue': '280,000 KWD',
      'hqAddress': 'Arraya Commercial Center, Al-Shuhada St, Kuwait City',
      'officeStaff': [
        {'name': 'Yousef Al-Kandari', 'role': 'Kuwait Country Director', 'phone': '+965 2220 1100', 'email': 'yousef.kwt@uniwash.com'},
        {'name': 'Dina Al-Sabah', 'role': 'Operations & Quality Lead', 'phone': '+965 2220 1101', 'email': 'dina.kwt@uniwash.com'},
      ],
    },
    {
      'name': 'Oman',
      'flag': '🇴🇲',
      'code': 'OMN',
      'currency': 'OMR',
      'customersCount': 2100,
      'activeLaundries': 9,
      'driversCount': 20,
      'orders': 4500,
      'revenue': '145,000 OMR',
      'hqAddress': 'Muscat Grand Mall Complex, Dohat Al Adab St, Muscat, Oman',
      'officeStaff': [
        {'name': 'Haitham Al-Balushi', 'role': 'Regional Ops Director', 'phone': '+968 2440 2200', 'email': 'haitham.omn@uniwash.com'},
        {'name': 'Salim Al-Harthy', 'role': 'Muscat Logistics Lead', 'phone': '+968 2440 2201', 'email': 'salim.fleet@uniwash.com'},
      ],
    },
    {
      'name': 'Bahrain',
      'flag': '🇧🇭',
      'code': 'BHR',
      'currency': 'BHD',
      'customersCount': 1950,
      'activeLaundries': 8,
      'driversCount': 18,
      'orders': 3900,
      'revenue': '110,000 BHD',
      'hqAddress': 'Bahrain Financial Harbour, West Tower, Manama, Bahrain',
      'officeStaff': [
        {'name': 'Salman Al-Khalifa', 'role': 'Country Manager', 'phone': '+973 1750 3300', 'email': 'salman.bhr@uniwash.com'},
      ],
    },
    {
      'name': 'United Kingdom',
      'flag': '🇬🇧',
      'code': 'GBR',
      'currency': 'GBP',
      'customersCount': 8900,
      'activeLaundries': 24,
      'driversCount': 50,
      'orders': 19400,
      'revenue': '£580,000',
      'hqAddress': '45 Berkeley Square, Mayfair, London W1J 5AS, UK',
      'officeStaff': [
        {'name': 'Edward Sterling', 'role': 'UK & Ireland Regional Director', 'phone': '+44 20 7946 0192', 'email': 'edward.uk@uniwash.com'},
      ],
    },
    {
      'name': 'United States',
      'flag': '🇺🇸',
      'code': 'USA',
      'currency': 'USD',
      'customersCount': 28000,
      'activeLaundries': 55,
      'driversCount': 110,
      'orders': 51000,
      'revenue': '\$1,850,000',
      'hqAddress': '1251 Avenue of the Americas, Manhattan, New York, NY 10020',
      'officeStaff': [
        {'name': 'Marcus Vance', 'role': 'North America Vice President', 'phone': '+1 212 555 0188', 'email': 'marcus.us@uniwash.com'},
      ],
    },
    {
      'name': 'Canada',
      'flag': '🇨🇦',
      'code': 'CAN',
      'currency': 'CAD',
      'customersCount': 5600,
      'activeLaundries': 14,
      'driversCount': 30,
      'orders': 11200,
      'revenue': 'CAD 420,000',
      'hqAddress': '100 King St W, Financial District, Toronto, ON M5X 1A9',
      'officeStaff': [
        {'name': 'David Bouchard', 'role': 'Canada Country Lead', 'phone': '+1 416 555 0144', 'email': 'david.can@uniwash.com'},
      ],
    },
    {
      'name': 'Europe (France / Germany)',
      'flag': '🇪🇺',
      'code': 'EUR',
      'currency': 'EUR',
      'customersCount': 13200,
      'activeLaundries': 31,
      'driversCount': 62,
      'orders': 26400,
      'revenue': '€890,000',
      'hqAddress': '28 Rue du Quatre-Septembre, 75002 Paris, France',
      'officeStaff': [
        {'name': 'Jean-Luc Moreau', 'role': 'Continental Europe Director', 'phone': '+33 1 42 68 55 00', 'email': 'jeanluc.eu@uniwash.com'},
      ],
    },
    {
      'name': 'Singapore',
      'flag': '🇸🇬',
      'code': 'SGP',
      'currency': 'SGD',
      'customersCount': 6400,
      'activeLaundries': 11,
      'driversCount': 24,
      'orders': 12800,
      'revenue': 'SGD 390,000',
      'hqAddress': 'Marina Bay Financial Centre Tower 1, Singapore 018981',
      'officeStaff': [
        {'name': 'Wei Ling Tan', 'role': 'Southeast Asia Regional Head', 'phone': '+65 6712 3400', 'email': 'weiling.sg@uniwash.com'},
      ],
    },
    {
      'name': 'Malaysia',
      'flag': '🇲🇾',
      'code': 'MYS',
      'currency': 'MYR',
      'customersCount': 7800,
      'activeLaundries': 16,
      'driversCount': 35,
      'orders': 15400,
      'revenue': 'MYR 280,000',
      'hqAddress': 'Menara KLCC, Jalan Ampang, 50088 Kuala Lumpur, Malaysia',
      'officeStaff': [
        {'name': 'Azman bin Razak', 'role': 'Malaysia Country Manager', 'phone': '+60 3 2168 8000', 'email': 'azman.my@uniwash.com'},
      ],
    },
    {
      'name': 'Pakistan',
      'flag': '🇵🇰',
      'code': 'PAK',
      'currency': 'PKR',
      'customersCount': 12500,
      'activeLaundries': 20,
      'driversCount': 45,
      'orders': 22000,
      'revenue': 'PKR 18,500,000',
      'hqAddress': 'Islamabad Stock Exchange Towers, Blue Area, Islamabad',
      'officeStaff': [
        {'name': 'Chaudhry Kamran', 'role': 'Pakistan Country Lead', 'phone': '+92 51 289 0100', 'email': 'kamran.pak@uniwash.com'},
      ],
    },
    {
      'name': 'India',
      'flag': '🇮🇳',
      'code': 'IND',
      'currency': 'INR',
      'customersCount': 26000,
      'activeLaundries': 35,
      'driversCount': 78,
      'orders': 44000,
      'revenue': 'INR 32,000,000',
      'hqAddress': 'One BKC, G-Block, Bandra Kurla Complex, Mumbai 400051',
      'officeStaff': [
        {'name': 'Rajesh Sharma', 'role': 'India Regional Managing Director', 'phone': '+91 22 6100 8800', 'email': 'rajesh.in@uniwash.com'},
      ],
    },
    {
      'name': 'South Africa',
      'flag': '🇿🇦',
      'code': 'ZAF',
      'currency': 'ZAR',
      'customersCount': 3100,
      'activeLaundries': 7,
      'driversCount': 16,
      'orders': 5100,
      'revenue': 'ZAR 840,000',
      'hqAddress': 'Sandton City Office Towers, 5th St, Sandton, Johannesburg',
      'officeStaff': [
        {'name': 'Thabo Mokoena', 'role': 'South Africa Country Manager', 'phone': '+27 11 784 0011', 'email': 'thabo.za@uniwash.com'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = state.currentLanguage == AppLanguage.ar;
    final isWide = MediaQuery.of(context).size.width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Clean soft fintech slate
      drawer: isWide ? null : Drawer(child: _buildLeftSidebar(context, state, isAr, inDrawer: true)),
      body: Row(
        children: [
          // 1. LEFT SIDE NAVIGATION MENU (Permanent on Desktop/Tablet)
          if (isWide)
            SizedBox(
              width: 270,
              child: _buildLeftSidebar(context, state, isAr, inDrawer: false),
            ),

          // 2. MAIN WORKSPACE CONTENT
          Expanded(
            child: Column(
              children: [
                // Top Executive Header Bar
                _buildTopExecutiveBar(context, state, isAr, isWide),

                // Main Display Screen
                Expanded(
                  child: _buildSelectedView(context, state, isAr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LEFT SIDEBAR (BANK-GRADE EXECUTIVE THEME)
  // ==========================================
  Widget _buildLeftSidebar(BuildContext context, StateService state, bool isAr, {required bool inDrawer}) {
    final pendingCount = state.orders.where((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed).length;

    return Container(
      color: const Color(0xFF0F172A), // Deep obsidian banking navy
      child: SafeArea(
        child: Column(
          children: [
            // Enterprise Hub Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const UniWashLogo.badge(size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'UniWash',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('GLOBAL', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Multi-National Core • Bank SSL',
                          style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  if (inDrawer)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),

            // Live Engine Status Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Engine: Operational 256-bit', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    Text(state.selectedCountry.flag, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),

            // Main Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                children: [
                  _navSectionLabel(isAr ? 'العمليات الأساسية والطلبات' : 'CORE OPERATIONS & ORDERS'),
                  _navItem(
                    index: 0,
                    icon: Icons.dashboard_rounded,
                    label: isAr ? 'لوحة القيادة' : 'Executive Overview',
                    subtitle: isAr ? 'المؤشرات والعمليات الحية' : 'Executive Command Center',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 11,
                    icon: Icons.radar_rounded,
                    label: isAr ? 'الطلبات الحية' : 'Live Order Tracking',
                    subtitle: '${state.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length} In-Flight Pipeline',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 12,
                    icon: Icons.warning_amber_rounded,
                    label: isAr ? 'أخطاء الطلبات والاستثناءات' : 'Order Problems & Fixes',
                    subtitle: '${state.unresolvedProblemsCount} Action Required',
                    badgeCount: state.unresolvedProblemsCount,
                    badgeColor: AppColors.error,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 1,
                    icon: Icons.storefront_rounded,
                    label: isAr ? 'المصابغ' : 'Laundries & Facilities',
                    subtitle: '${state.laundries.length} Active Facilities',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 2,
                    icon: Icons.sports_motorsports_rounded,
                    label: isAr ? 'الأسطول والسائقين' : 'Driver Fleet & Duty',
                    subtitle: '${state.drivers.length} Fleet Couriers',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 10,
                    icon: Icons.people_alt_rounded,
                    label: isAr ? 'العملاء والمحافظ' : 'Customers & Wallets',
                    subtitle: 'Accounts, Loyalty & Orders',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(color: Colors.white12, height: 1),
                  ),

                  _navSectionLabel(isAr ? 'الدول والفروع والمشرفين' : 'TERRITORIES & GOVERNANCE'),
                  _navItem(
                    index: 7,
                    icon: Icons.public_rounded,
                    label: isAr ? 'الدول والفروع' : 'Countries & Branches',
                    subtitle: '${state.countries.length} Nations • ${state.allBranches.length} Branches',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 8,
                    icon: Icons.admin_panel_settings_rounded,
                    label: isAr ? 'المشرفين الإقليميين' : 'Regional Admins',
                    subtitle: '${state.admins.length} Staff • RBAC Rights',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 9,
                    icon: Icons.group_work_rounded,
                    label: isAr ? 'فرق العمل وخدمة العملاء' : 'Operations Team & CS',
                    subtitle: '${state.teamMembers.length} Operational Agents',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 13,
                    icon: Icons.history_edu_rounded,
                    label: isAr ? 'سجلات التدقيق الأمني' : 'Audit Logs & Security',
                    subtitle: '${state.auditLogs.length} Compliance Events',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 3,
                    icon: Icons.account_tree_rounded,
                    label: isAr ? 'نظام الإدارة' : 'Management System',
                    subtitle: isAr ? 'طلبات، إعلانات، أسعار' : 'Orders, Ads, Catalog & Audit',
                    badgeCount: pendingCount,
                    badgeColor: const Color(0xFFEF4444),
                    inDrawer: inDrawer,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Divider(color: Colors.white12, height: 1),
                  ),

                  _navSectionLabel(isAr ? 'الإعدادات والدعم' : 'SYSTEM & GOVERNANCE'),
                  _navItem(
                    index: 4,
                    icon: Icons.settings_suggest_rounded,
                    label: isAr ? 'الإعدادات' : 'Settings',
                    subtitle: isAr ? 'العملات، الضرائب، المنصة' : 'Currency, Tax & Rules',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 5,
                    icon: Icons.domain_rounded,
                    label: isAr ? 'عن الشركة' : 'About Holding HQ',
                    subtitle: '15 Nations Holding HQ',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                  _navItem(
                    index: 6,
                    icon: Icons.support_agent_rounded,
                    label: isAr ? 'المساعدة والدعم' : 'Help & Escalation',
                    subtitle: isAr ? 'طوارئ وتصعيد' : '24/7 Incident Hotline',
                    badgeCount: 0,
                    inDrawer: inDrawer,
                  ),
                ],
              ),
            ),

            // Profile & Switch Portal Footer
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black.withValues(alpha: 0.25),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF38BDF8),
                        child: Text('FA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Sheikh Faisal Al-Thani', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11), overflow: TextOverflow.ellipsis),
                            Text('Super Admin Executive', style: TextStyle(color: Colors.white54, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.swap_horiz, size: 14, color: Color(0xFF38BDF8)),
                      label: const Text('Switch Portal Role', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        if (inDrawer) Navigator.pop(context);
                        _showRoleSwitcherDialog(context, state);
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

  Widget _navSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
    required String subtitle,
    required int badgeCount,
    Color? badgeColor,
    required bool inDrawer,
  }) {
    final isSelected = _selectedNavIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() => _selectedNavIndex = index);
            if (inDrawer) Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? const Color(0xFF38BDF8).withValues(alpha: 0.3) : Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isSelected ? const Color(0xFF38BDF8) : Colors.white60,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TOP EXECUTIVE BAR
  // ==========================================
  Widget _buildTopExecutiveBar(BuildContext context, StateService state, bool isAr, bool isWide) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          if (!isWide) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0F172A)),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: 4),
          ],

          // Title & Active Breadcrumb
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getViewTitle(isAr),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text('ENTERPRISE TIER', style: TextStyle(color: Color(0xFF059669), fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                Text(
                  'Multi-National Platform • Active Territory: ${state.selectedCountry.name} (${state.selectedCountry.currencyCode})',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Google Super Search Omnibar (Desktop/Tablet)
          if (isWide)
            Container(
              width: 300,
              padding: const EdgeInsets.only(right: 12),
              child: SuperSearchBar(
                hintText: isAr ? 'بحث فائق: طلب، هاتف، عميل...' : 'Super Search: Order #, Mobile...',
                onOrderSelected: (order) => OrderDetailDialog.show(context, order),
              ),
            ),

          // Executive Report & Print Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            icon: const Icon(Icons.summarize_rounded, size: 16, color: Color(0xFF0F172A)),
            label: Text(isAr ? 'التقرير التنفيذي' : 'Executive Report', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            onPressed: () => SuperAdminReportsDialog.show(context, state),
          ),
          // Event & National Day Offers Engine
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              side: const BorderSide(color: Color(0xFF0284C7)),
              foregroundColor: const Color(0xFF0284C7),
            ),
            icon: const Icon(Icons.celebration_rounded, size: 16, color: Color(0xFF0284C7)),
            label: Text(isAr ? 'العروض واليوم الوطني' : 'Offers & National Days', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => SuperAdminEventOffersDialog.show(context),
          ),
          const SizedBox(width: 8),

          // Quick Create Ad / Promo Banner Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.campaign_rounded, size: 16, color: Color(0xFF38BDF8)),
            label: Text(isAr ? '+ إعلان جديد' : '+ New Ad / Banner', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            onPressed: () => _showCreateAdDialog(context, state),
          ),
          const SizedBox(width: 8),

          // Territory Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButton<String>(
              value: state.selectedCountry.code,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF475569), size: 18),
              onChanged: (code) {
                if (code != null) {
                  state.setSelectedCountry(code);
                }
              },
              items: LocalizationService.countries.values.map((c) {
                return DropdownMenuItem<String>(
                  value: c.code,
                  child: Row(
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(c.code, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF1E293B))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 8),

          // Language Switcher
          IconButton(
            tooltip: isAr ? 'English' : 'العربية',
            icon: const Icon(Icons.language_rounded, color: Color(0xFF475569), size: 20),
            onPressed: () => state.toggleLanguage(),
          ),
        ],
      ),
    );
  }

  String _getViewTitle(bool isAr) {
    switch (_selectedNavIndex) {
      case 0:
        return isAr ? 'لوحة القيادة الإدارية' : 'Executive Command Center';
      case 1:
        return isAr ? 'إدارة المصابغ ومجلداتها' : 'Laundries & Facilities Hub';
      case 2:
        return isAr ? 'إدارة الأسطول والمهمات' : 'Driver Fleet & Missions';
      case 3:
        return isAr ? 'نظام الإدارة المتكامل' : 'Enterprise Management System';
      case 4:
        return isAr ? 'إعدادات المنصة' : 'Platform & System Settings';
      case 5:
        return isAr ? 'عن الشركة القابضة والدول' : 'UniWash Global Infrastructure';
      case 6:
        return isAr ? 'مركز الدعم والتصعيد' : 'Executive Help & Escalation';
      case 7:
        return isAr ? 'إدارة الدول والفروع الإقليمية' : 'Country & Branch Enterprise Management';
      case 8:
        return isAr ? 'إدارة المشرفين الإقليميين' : 'Regional Admins & RBAC Governance';
      case 9:
        return isAr ? 'فرق العمل وخدمة العملاء وموظفي المكاتب' : 'Operations Team & Customer Support Roster';
      case 10:
        return isAr ? 'إدارة العملاء والحسابات والمحافظ' : 'Customer Relationship Management & Wallets';
      case 11:
        return isAr ? 'تتبع مسار الطلبات الحية' : 'Live Order Tracking & Stage Pipeline';
      case 12:
        return isAr ? 'معالجة مشكلات الطلبات والاستثناءات' : 'Order Problems & Operational Exceptions Hub';
      case 13:
        return isAr ? 'سجلات التدقيق الإداري والامتثال الأمني' : 'Enterprise Audit Logs & Security Ledger';
      default:
        return 'Super Admin Dashboard';
    }
  }

  // ==========================================
  // VIEW ROUTER
  // ==========================================
  Widget _buildSelectedView(BuildContext context, StateService state, bool isAr) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildAdminOverviewView(context, state, isAr);
      case 1:
        return _buildLaundriesView(context, state, isAr);
      case 2:
        return _buildDriversView(context, state, isAr);
      case 3:
        return _buildManagementSystemView(context, state, isAr);
      case 4:
        return _buildSettingsView(context, state, isAr);
      case 5:
        return _buildAboutView(context, state, isAr);
      case 6:
        return _buildHelpView(context, state, isAr);
      case 7:
        return SuperAdminCountriesBranchesTab(isAr: isAr);
      case 8:
        return SuperAdminAdminsTeamTab(isAr: isAr, initialSubTab: 0);
      case 9:
        return SuperAdminAdminsTeamTab(isAr: isAr, initialSubTab: 1);
      case 10:
        return SuperAdminCustomersTab(isAr: isAr);
      case 11:
        return SuperAdminLiveOrdersTab(isAr: isAr);
      case 12:
        return SuperAdminOrderProblemsTab(isAr: isAr);
      case 13:
        return SuperAdminAuditLogsTab(isAr: isAr);
      default:
        return _buildAdminOverviewView(context, state, isAr);
    }
  }

  // ==========================================
  // 1. ADMIN OVERVIEW (EXECUTIVE COMMAND HUB)
  // ==========================================
  Widget _buildAdminOverviewView(BuildContext context, StateService state, bool isAr) {
    final pendingCount = state.orders.where((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed).length;
    final inWashingCount = state.orders.where((o) => o.status == OrderStatus.inLaundry || o.status == OrderStatus.pickedUp || o.status == OrderStatus.readyForDelivery).length;
    final outForDeliveryCount = state.orders.where((o) => o.status == OrderStatus.outForDelivery).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Banking KPI Metrics Row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: isAr ? 'الدول النشطة' : 'Active Territories',
                  value: '15 Nations',
                  subtitle: isAr ? 'الخليج وأوروبا وأمريكا' : 'GCC, EU, US, UK, Asia',
                  icon: Icons.public_rounded,
                  iconColor: const Color(0xFF2563EB),
                  onTap: () => _showActiveTerritoriesDialog(context, state),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: isAr ? 'المصابغ المتعاقدة' : 'Active Facilities',
                  value: '${state.laundries.length} Hubs',
                  subtitle: '100% Contracted',
                  icon: Icons.storefront_rounded,
                  iconColor: const Color(0xFF0D9488),
                  onTap: () => setState(() => _selectedNavIndex = 1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: isAr ? 'الأسطول الميداني' : 'Driver Fleet',
                  value: '${state.drivers.length} Drivers',
                  subtitle: 'GPS Broadcast Online',
                  icon: Icons.sports_motorsports_rounded,
                  iconColor: const Color(0xFFD97706),
                  onTap: () => setState(() => _selectedNavIndex = 2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: isAr ? 'إجمالي الأرباح' : 'Lifetime Platform GMV',
                  value: state.formatCurrency(148500.0),
                  subtitle: '15% Net SaaS Fee',
                  icon: Icons.account_balance_rounded,
                  iconColor: const Color(0xFF16A34A),
                  onTap: () => _showGlobalGmvLedgerDialog(context, state),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatCard(
                  title: isAr ? 'بانتظار السائق' : 'Pending Driver Dispatch',
                  value: '$pendingCount Orders',
                  subtitle: pendingCount > 0 ? '🚨 Assign Immediately' : 'All Missions Dispatched',
                  icon: Icons.notifications_active_rounded,
                  iconColor: pendingCount > 0 ? const Color(0xFFEF4444) : const Color(0xFF0284C7),
                  onTap: () {
                    setState(() {
                      _selectedNavIndex = 3;
                      _mgmtSubTabIndex = 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Urgent Admin Driver Dispatch Alert
          if (pendingCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'تنبيه إداري: $pendingCount طلب جديد بحاجة لتعيين سائق!' : 'Admin Action Required: $pendingCount new order(s) awaiting Driver Dispatch!',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF991B1B), fontSize: 13),
                        ),
                        Text(
                          isAr ? 'الطلبات وصلت من العميل مباشرة للإدارة. عيّن السائق فوراً للبدء.' : 'Orders placed by customer go directly to Admin. Assign driver below to begin pickup mission.',
                          style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.person_add_rounded, size: 15),
                    label: Text(isAr ? 'تعيين السائقين الآن' : 'Dispatch Orders Now'),
                    onPressed: () {
                      setState(() {
                        _selectedNavIndex = 3;
                        _mgmtSubTabIndex = 0;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Quick Action Command Center Card
          Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 20),
                        SizedBox(width: 8),
                        Text('Executive Command Shortcuts', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
                      ],
                    ),
                    Text(
                      'All actions verified & live',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _quickActionButton(
                      icon: Icons.campaign_rounded,
                      color: const Color(0xFF2563EB),
                      label: isAr ? 'إنشاء إعلان وبانر' : 'Create / Add Promo Ad',
                      onTap: () => _showCreateAdDialog(context, state),
                    ),
                    _quickActionButton(
                      icon: Icons.storefront_rounded,
                      color: const Color(0xFF0D9488),
                      label: isAr ? 'إضافة مصبغة جديدة' : 'Onboard Partner Laundry',
                      onTap: () => _showAddLaundryDialog(context, state),
                    ),
                    _quickActionButton(
                      icon: Icons.delivery_dining_rounded,
                      color: const Color(0xFFD97706),
                      label: isAr ? 'تسجيل سائق جديد' : 'Register Fleet Driver',
                      onTap: () => _showAddDriverDialog(context, state),
                    ),
                    _quickActionButton(
                      icon: Icons.person_add_alt_1_rounded,
                      color: const Color(0xFF7C3AED),
                      label: isAr ? 'توظيف ومراجعة كادر' : 'Staff Onboarding',
                      onTap: () => showDialog(context: context, builder: (_) => AdminStaffDialog(stateService: state)),
                    ),
                    _quickActionButton(
                      icon: Icons.crisis_alert_rounded,
                      color: const Color(0xFFDC2626),
                      label: isAr ? 'تصعيد حادث تشغيلي' : 'Escalate Incident',
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AdminEscalationDialog(
                          entityName: 'Central Logistics & Dispatch Unit',
                          entityType: 'Regional Operations',
                          currentLevel: WarningLevel.none,
                          onApply: (lvl) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Escalation status set to: ${lvl.displayName}')),
                            );
                          },
                        ),
                      ),
                    ),
                    _quickActionButton(
                      icon: Icons.receipt_long_rounded,
                      color: const Color(0xFF475569),
                      label: isAr ? 'سجل الفواتير الحرارية' : 'Thermal POS Invoices',
                      onTap: () {
                        if (state.orders.isNotEmpty) {
                          showDialog(context: context, builder: (_) => LaundryThermalInvoiceDialog(order: state.orders.first));
                        }
                      },
                    ),
                    _quickActionButton(
                      icon: Icons.celebration_rounded,
                      color: const Color(0xFFB45309),
                      label: isAr ? 'عروض اليوم الوطني والمناسبات' : 'Occasion Themes & Offers',
                      onTap: () => showDialog(context: context, builder: (_) => const SuperAdminEventOffersDialog()),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Operational Status & Live Orders Feed
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Live Orders Feed
              Expanded(
                flex: 3,
                child: Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.receipt_long_rounded, color: Color(0xFF0F172A), size: 18),
                              SizedBox(width: 8),
                              Text('Real-Time Orders Feed', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedNavIndex = 3;
                                _mgmtSubTabIndex = 0;
                              });
                            },
                            child: const Text('View All Orders →', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (state.orders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('No orders recorded.')),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.orders.length > 5 ? 5 : state.orders.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final o = state.orders[i];
                            final needsDriver = o.assignedDriverId.isEmpty || o.status == OrderStatus.placed;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: needsDriver ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                                child: Icon(
                                  needsDriver ? Icons.sports_motorsports_rounded : Icons.check_circle_outline,
                                  color: needsDriver ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                  size: 18,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text('#${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                  const SizedBox(width: 6),
                                  BadgePill(
                                    label: o.status.displayName,
                                    backgroundColor: o.status.color.withValues(alpha: 0.12),
                                    textColor: o.status.color,
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${o.customerName} • ${o.totalItemCount} items • ${o.address.city}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state.formatCurrency(o.totalAmount),
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(width: 8),
                                  if (needsDriver)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDC2626),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                                      ),
                                      onPressed: () => AdminAssignDriverDialog.show(context, o),
                                      child: const Text('Assign Driver'),
                                    )
                                  else
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                      ),
                                      onPressed: () => OrderDetailDialog.show(context, o),
                                      child: const Text('View'),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Right: Operations Telemetry & Facility Health
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.speed_rounded, color: Color(0xFF2563EB), size: 18),
                              SizedBox(width: 8),
                              Text('Fleet Dispatch Telemetry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _telemetryRow('In Processing & Washing', '$inWashingCount Missions', const Color(0xFFF59E0B)),
                          const SizedBox(height: 8),
                          _telemetryRow('Out for Delivery', '$outForDeliveryCount Active Vans', const Color(0xFF0D9488)),
                          const SizedBox(height: 8),
                          _telemetryRow('Fleet Readiness', '${(state.drivers.where((d) => d.isOnline).length / (state.drivers.isEmpty ? 1 : state.drivers.length) * 100).round()}% Online', const Color(0xFF16A34A)),
                          const SizedBox(height: 8),
                          _telemetryRow('Platform Reliability', '99.98% SLA', const Color(0xFF2563EB)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Quick Ads Manager Preview Widget
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.campaign_outlined, color: Color(0xFF7C3AED), size: 18),
                                  SizedBox(width: 8),
                                  Text('Active Ad Banners', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                ],
                              ),
                              Text('${state.activeAdvertisements.length} Active', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (state.activeAdvertisements.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFDDD6FE)),
                              ),
                              child: Row(
                                children: [
                                  Text(state.activeAdvertisements.first.graphicEmoji, style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(state.activeAdvertisements.first.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                        Text(state.activeAdvertisements.first.message, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedNavIndex = 3;
                                  _mgmtSubTabIndex = 1;
                                });
                              },
                              child: const Text('Manage All Ads & Promos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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
        ],
      ),
    );
  }

  Widget _quickActionButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _telemetryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
        ),
      ],
    );
  }

  // ==========================================
  // 2. LUNDARY (FACILITIES DIRECTORY & HUBS)
  // ==========================================
  Widget _buildLaundriesView(BuildContext context, StateService state, bool isAr) {
    final filteredLaundries = state.laundries.where((l) {
      if (_laundrySearch.isEmpty) return true;
      return l.name.toLowerCase().contains(_laundrySearch.toLowerCase()) ||
          l.country.toLowerCase().contains(_laundrySearch.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Top Search & Onboard Facility Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _laundrySearch = val),
                  decoration: InputDecoration(
                    hintText: isAr ? 'ابحث عن المصبغة بالاسم أو المنطقة...' : 'Search Laundry Partner by name or region...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: Text(isAr ? 'إضافة مصبغة' : 'Onboard Partner Facility'),
                onPressed: () => _showAddLaundryDialog(context, state),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Laundries List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredLaundries.length,
            itemBuilder: (context, index) {
              final laundry = filteredLaundries[index];
              final ordersForLaundry = state.orders.where((o) => o.laundryId == laundry.id).toList();

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_laundry_service_rounded, color: Color(0xFF0D9488), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(laundry.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('100% TM CONTRACTED', style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 ${laundry.country} (${laundry.legalRegNumber}) • 📞 ${laundry.phone}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text('${laundry.rating}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                                const SizedBox(width: 12),
                                Text('${ordersForLaundry.length} Active / Processed Orders', style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.folder_shared_outlined, size: 14),
                            label: const Text('Partner Folder', style: TextStyle(fontSize: 11)),
                            onPressed: () => LaundryProfileDialog.show(context, laundry),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.assignment_outlined, size: 14),
                            label: const Text('Contract View', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              final contract = state.contracts.firstWhere(
                                (c) => c.laundryId == laundry.id,
                                orElse: () => LaundryContract(
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
                              showDialog(context: context, builder: (_) => AdminContractDialog(contract: contract));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 3. DRIVER (FLEET COMMAND & MISSIONS)
  // ==========================================
  Widget _buildDriversView(BuildContext context, StateService state, bool isAr) {
    final filteredDrivers = state.drivers.where((d) {
      if (_driverSearch.isEmpty) return true;
      return d.fullName.toLowerCase().contains(_driverSearch.toLowerCase()) ||
          d.phone.contains(_driverSearch) ||
          d.documents.vehicleRegPlate.toLowerCase().contains(_driverSearch.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Top Search & Register Driver Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _driverSearch = val),
                  decoration: InputDecoration(
                    hintText: isAr ? 'ابحث عن السائق بالاسم، الهاتف، لوحة المركبة...' : 'Search Driver by name, mobile, vehicle plate...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text(isAr ? 'تسجيل سائق' : 'Register Fleet Driver'),
                onPressed: () => _showAddDriverDialog(context, state),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Drivers List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDrivers.length,
            itemBuilder: (context, index) {
              final driver = filteredDrivers[index];
              final driverOrders = state.getOrdersForDriver(driver.id);
              final activeMissions = driverOrders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.15),
                            child: Text(
                              driver.fullName.isNotEmpty ? driver.fullName.substring(0, 1) : 'D',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB45309), fontSize: 18),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: driver.isOnline ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: driver.isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    driver.isOnline ? 'ONLINE • GPS BROADCAST' : 'OFFLINE',
                                    style: TextStyle(
                                      color: driver.isOnline ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📞 ${driver.phone} • 🚗 Plate: ${driver.documents.vehicleRegPlate}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text('${driver.rating}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                                const SizedBox(width: 12),
                                Text(
                                  '$activeMissions Active Missions • ${driver.completedTrips} Lifetime Completed',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: activeMissions > 0 ? const Color(0xFF0284C7) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.folder_shared_outlined, size: 14),
                            label: const Text('Digital Folder', style: TextStyle(fontSize: 11)),
                            onPressed: () => DriverFolderDialog.show(context, driver),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.lock_reset_rounded, size: 14),
                            label: const Text('Reset PIN', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Temporary dispatch PIN for ${driver.fullName} reset to: 1234')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. MANAGEMENT SYSTEM (MULTI-MODULE ENGINE)
  // ==========================================
  Widget _buildManagementSystemView(BuildContext context, StateService state, bool isAr) {
    final pendingOrdersCount = state.orders.where((o) => o.assignedDriverId.isEmpty || o.status == OrderStatus.placed).length;

    return Column(
      children: [
        // Sub-Navigation Tab Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              _subTabButton(
                index: 0,
                icon: Icons.receipt_long_rounded,
                label: isAr ? 'الطلبات والإرسال' : 'Orders & Dispatch',
                badgeCount: pendingOrdersCount,
              ),
              const SizedBox(width: 8),
              _subTabButton(
                index: 1,
                icon: Icons.campaign_rounded,
                label: isAr ? 'مدير الإعلانات والبانرات' : 'Ads & Promotions',
                badgeCount: state.activeAdvertisements.length,
              ),
              const SizedBox(width: 8),
              _subTabButton(
                index: 2,
                icon: Icons.price_change_outlined,
                label: isAr ? 'قائمة الأسعار والخدمات' : 'Catalog & Pricing',
              ),
              const SizedBox(width: 8),
              _subTabButton(
                index: 3,
                icon: Icons.access_time_rounded,
                label: isAr ? 'التدقيق بالساعات' : 'Hourly Operations Audit',
              ),
              const SizedBox(width: 8),
              _subTabButton(
                index: 4,
                icon: Icons.verified_user_rounded,
                label: isAr ? 'طلبات التوظيف والعقود' : 'Staff Approvals',
                badgeCount: state.staffRequests.length,
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Sub-Tab Content
        Expanded(
          child: IndexedStack(
            index: _mgmtSubTabIndex,
            children: [
              // 0: Orders & Live Dispatch
              _buildOrdersAndDispatchSubTab(context, state, isAr),

              // 1: Ads & Promotions Manager
              _buildAdsAndPromotionsSubTab(context, state, isAr),

              // 2: Catalog & Pricing Manager
              const SuperAdminCatalogTab(),

              // 3: Hourly Operations Audit Timeline
              const SuperAdminHourlyAuditTab(),

              // 4: Staff Approvals & Documents
              _buildApprovalQueueTab(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _subTabButton({required int index, required IconData icon, required String label, int badgeCount = 0}) {
    final isSelected = _mgmtSubTabIndex == index;

    return InkWell(
      onTap: () => setState(() => _mgmtSubTabIndex = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF475569)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            if (badgeCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- SUB-TAB 0: ORDERS & LIVE DISPATCH ---
  Widget _buildOrdersAndDispatchSubTab(BuildContext context, StateService state, bool isAr) {
    final filtered = state.orders.where((o) {
      if (_ordersFilter == 'pending') {
        return o.assignedDriverId.isEmpty || o.status == OrderStatus.placed;
      }
      if (_ordersFilter == 'in_progress') {
        return o.status == OrderStatus.inLaundry || o.status == OrderStatus.pickedUp || o.status == OrderStatus.readyForDelivery;
      }
      if (_ordersFilter == 'out_for_delivery') {
        return o.status == OrderStatus.outForDelivery;
      }
      if (_ordersFilter == 'delivered') {
        return o.status == OrderStatus.delivered;
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Filter Chips Row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              _filterChip('all', isAr ? 'جميع الطلبات (${state.orders.length})' : 'All Orders (${state.orders.length})'),
              const SizedBox(width: 6),
              _filterChip('pending', isAr ? 'بانتظار تعيين السائق' : 'Awaiting Driver Dispatch', isAlert: true),
              const SizedBox(width: 6),
              _filterChip('in_progress', isAr ? 'في الغسيل والمصبغة' : 'In Facility Processing'),
              const SizedBox(width: 6),
              _filterChip('out_for_delivery', isAr ? 'في الطريق للتوصيل' : 'Out for Delivery'),
              const SizedBox(width: 6),
              _filterChip('delivered', isAr ? 'تم التسليم بنجاح' : 'Delivered'),
            ],
          ),
        ),
        const Divider(height: 1),

        // Orders Table
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    isAr ? 'لا توجد طلبات مطابقة لهذا الفلتر' : 'No orders found matching this filter.',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    final needsDriver = order.assignedDriverId.isEmpty || order.status == OrderStatus.placed;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: needsDriver ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                          width: needsDriver ? 1.5 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: needsDriver ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                needsDriver ? Icons.sports_motorsports_rounded : Icons.receipt_long_rounded,
                                color: needsDriver ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('#${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                      const SizedBox(width: 8),
                                      BadgePill(
                                        label: order.status.displayName,
                                        backgroundColor: order.status.color.withValues(alpha: 0.12),
                                        textColor: order.status.color,
                                      ),
                                      if (needsDriver) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(4)),
                                          child: const Text('🚨 ADMIN ASSIGN DRIVER REQUIRED', style: TextStyle(color: Color(0xFFDC2626), fontSize: 9, fontWeight: FontWeight.w800)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Customer: ${order.customerName} (${order.customerPhone}) • ${order.address.formatted}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Driver: ${order.assignedDriverName.isEmpty ? "Unassigned" : order.assignedDriverName} • Facility: ${order.laundryName} • ${order.totalItemCount} Items',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  state.formatCurrency(order.totalAmount),
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (needsDriver)
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFDC2626),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                        ),
                                        icon: const Icon(Icons.person_add_rounded, size: 14),
                                        label: const Text('Assign Driver'),
                                        onPressed: () => AdminAssignDriverDialog.show(context, order),
                                      )
                                    else
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                        ),
                                        onPressed: () => AdminAssignDriverDialog.show(context, order),
                                        child: const Text('Reassign'),
                                      ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(Icons.receipt_outlined, size: 18),
                                      tooltip: 'Thermal POS Invoice',
                                      onPressed: () => showDialog(context: context, builder: (_) => LaundryThermalInvoiceDialog(order: order)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, size: 18),
                                      tooltip: 'Order Details',
                                      onPressed: () => OrderDetailDialog.show(context, order),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String key, String title, {bool isAlert = false}) {
    final isSelected = _ordersFilter == key;

    return FilterChip(
      label: Text(title),
      selected: isSelected,
      onSelected: (_) => setState(() => _ordersFilter = key),
      selectedColor: isAlert ? const Color(0xFFFEE2E2) : const Color(0xFF0F172A).withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? (isAlert ? const Color(0xFFDC2626) : const Color(0xFF0F172A)) : const Color(0xFF475569),
      ),
    );
  }

  // --- SUB-TAB 1: ADS & PROMOTIONS MANAGER ---
  Widget _buildAdsAndPromotionsSubTab(BuildContext context, StateService state, bool isAr) {
    final allAds = state.advertisements;

    return Column(
      children: [
        // Action Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Advertisements, Banners & Push Broadcasts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  Text(
                    'Manage public banners visible in Customer App, Offers tab & home carousels (${allAds.length} banners)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.celebration_rounded, size: 16),
                    label: const Text('Event Occasions & Ramadan'),
                    onPressed: () => showDialog(context: context, builder: (_) => const SuperAdminEventOffersDialog()),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(isAr ? 'إضافة إعلان جديد' : '+ Create New Ad Banner'),
                    onPressed: () => _showCreateAdDialog(context, state),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Ads List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allAds.length,
            itemBuilder: (context, index) {
              final ad = allAds[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: ad.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(ad.graphicEmoji, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(ad.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: ad.countryCode == 'ALL' ? const Color(0xFFEFF6FF) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${ad.countryFlag} ${ad.countryCode}',
                                    style: TextStyle(
                                      color: ad.countryCode == 'ALL' ? const Color(0xFF1D4ED8) : const Color(0xFF92400E),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                if (ad.isBroadcastPushed)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                                    child: const Text('PUSH BROADCAST', style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.w800)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(ad.message, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                            const SizedBox(height: 4),
                            Text(
                              'CTA: "${ad.ctaText}" • Type: ${ad.bannerType.name} • Valid until: ${DateFormat('dd MMM yyyy').format(ad.validUntil)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          // Toggle Active
                          Switch(
                            value: ad.isActive,
                            activeTrackColor: const Color(0xFF16A34A).withValues(alpha: 0.5),
                            onChanged: (_) {
                              state.toggleAdvertisementActive(ad.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ad banner "${ad.title}" status changed to ${!ad.isActive ? "Active" : "Inactive"}.')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),

                          // Push Broadcast
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: Color(0xFF2563EB), size: 18),
                            tooltip: 'Broadcast Push to Customers',
                            onPressed: () {
                              state.broadcastAdvertisementMessage(ad.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('📢 Broadcast message for "${ad.title}" pushed live to all customer devices!')),
                              );
                            },
                          ),

                          // Delete
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                            tooltip: 'Delete Ad Banner',
                            onPressed: () {
                              state.deleteAdvertisement(ad.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ad banner deleted successfully.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. SETTINGS (PLATFORM & REVENUE CONFIG)
  // ==========================================
  Widget _buildSettingsView(BuildContext context, StateService state, bool isAr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.currency_exchange_rounded, color: Color(0xFF0F172A), size: 20),
                    SizedBox(width: 8),
                    Text('Global Financial & Operational Settings', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                const Divider(height: 24),

                // Currency selector
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Operating Territory & Base Currency', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text('Current currency: ${state.selectedCountry.currencyCode} (${state.selectedCountry.name})'),
                  trailing: DropdownButton<String>(
                    value: state.selectedCountry.code,
                    onChanged: (code) {
                      if (code != null) {
                        state.setSelectedCountry(code);
                      }
                    },
                    items: LocalizationService.countries.values.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.code,
                        child: Text('${c.flag} ${c.code} (${c.currencyCode})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 16),

                // Platform VAT / Tax
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Territory VAT & Municipal Sales Tax', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Qatar: 0% VAT • UAE: 5% VAT • KSA: 15% VAT'),
                  trailing: SizedBox(
                    width: 120,
                    child: DropdownButton<double>(
                      value: _taxVatRate,
                      isExpanded: true,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _taxVatRate = val);
                        }
                      },
                      items: const [
                        DropdownMenuItem(value: 0.0, child: Text('0% (Qatar)')),
                        DropdownMenuItem(value: 5.0, child: Text('5% (UAE)')),
                        DropdownMenuItem(value: 15.0, child: Text('15% (KSA)')),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 16),

                // Auto-Dispatch Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Driver Dispatch Engine Mode', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: Text(_autoDispatchEnabled ? 'Auto-Assign Nearest GPS Driver' : 'Strict Regional Admin Manual Dispatch (Active)'),
                  value: _autoDispatchEnabled,
                  activeTrackColor: const Color(0xFF16A34A).withValues(alpha: 0.5),
                  onChanged: (val) => setState(() => _autoDispatchEnabled = val),
                ),
                const Divider(height: 16),

                // Notifications
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('WhatsApp Order Status Gateway', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Automated real-time notifications to customers when driver departs or order is packed'),
                  value: _whatsappAlertsEnabled,
                  activeTrackColor: const Color(0xFF16A34A).withValues(alpha: 0.5),
                  onChanged: (val) => setState(() => _whatsappAlertsEnabled = val),
                ),
                const Divider(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('SMS & Broadcast Push Notifications', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Promotional announcements, OTP authentication and billing updates'),
                  value: _smsGatewayEnabled,
                  activeTrackColor: const Color(0xFF16A34A).withValues(alpha: 0.5),
                  onChanged: (val) => setState(() => _smsGatewayEnabled = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Core System Diagnostics
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.terminal_rounded, color: Color(0xFF0F172A), size: 20),
                    SizedBox(width: 8),
                    Text('Enterprise Infrastructure Diagnostics', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Run Health Check & Re-sync State'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ System Health Check: All 15 Territory nodes & database operational (Latency: 14ms)')),
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

  // ==========================================
  // 6. ABOUT (MULTINATIONAL INFRASTRUCTURE)
  // ==========================================
  Widget _buildAboutView(BuildContext context, StateService state, bool isAr) {
    return _buildGlobalTerritoriesTab(context, state);
  }

  // ==========================================
  // 7. HELP (EXECUTIVE SUPPORT & INCIDENT)
  // ==========================================
  Widget _buildHelpView(BuildContext context, StateService state, bool isAr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.headset_mic_rounded, color: Color(0xFF0F172A), size: 22),
                    SizedBox(width: 10),
                    Text('24/7 Executive Priority Incident & Dispatch Hotline', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Direct priority channel for Super Admins, Laundry Partners, and Regional Directors across the GCC.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Qatar HQ Emergency Hotline', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            const Text('+974 4499 1000 / 800-WASH', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Regional Director Ops Email', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            const Text('executive.ops@uniwash.qa', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.crisis_alert_rounded, size: 18),
                  label: const Text('Open Incident Escalation Center', style: TextStyle(fontWeight: FontWeight.w800)),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AdminEscalationDialog(
                      entityName: 'Executive Command Center',
                      entityType: 'Regional Operations',
                      currentLevel: WarningLevel.none,
                      onApply: (lvl) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Incident status updated to: ${lvl.displayName}')),
                        );
                      },
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
  // CREATE / ADD AD BANNER DIALOG (WORKING)
  // ==========================================
  void _showCreateAdDialog(BuildContext context, StateService state) {
    final titleController = TextEditingController(text: 'Special Executive Discount');
    final titleArController = TextEditingController(text: 'خصم خاص حصري');
    final messageController = TextEditingController(text: 'Enjoy 25% off all premium thobe and delicate laundry care this week!');
    final messageArController = TextEditingController(text: 'استمتع بخصم 25٪ على جميع خدمات غسيل الثياب الفاخرة هذا الأسبوع!');
    final ctaController = TextEditingController(text: 'Order Now');
    String selectedEmoji = '🏷️';
    String selectedCountry = 'ALL';
    const selectedColor = Color(0xFF0F172A);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              padding: const EdgeInsets.all(22),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.campaign_rounded, color: Color(0xFF2563EB), size: 24),
                            SizedBox(width: 10),
                            Text('Create & Publish Ad Banner', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(height: 20),

                    // Title
                    const Text('Banner Title (English)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                    const SizedBox(height: 12),

                    // Title Ar
                    const Text('Banner Title (العربية)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleArController,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                    const SizedBox(height: 12),

                    // Message
                    const Text('Description Message', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: messageController,
                      maxLines: 2,
                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                    ),
                    const SizedBox(height: 12),

                    // Emoji & Territory Target
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Badge Emoji', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedEmoji,
                                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                                items: ['🏷️', '✨', '🇶🇦', '👔', '🧺', '🚗', '👑', '⚡'].map((e) {
                                  return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 20)));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDlgState(() => selectedEmoji = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Target Territory', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCountry,
                                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                                items: const [
                                  DropdownMenuItem(value: 'ALL', child: Text('🌐 Global (ALL)')),
                                  DropdownMenuItem(value: 'QAT', child: Text('🇶🇦 Qatar')),
                                  DropdownMenuItem(value: 'UAE', child: Text('🇦🇪 UAE')),
                                  DropdownMenuItem(value: 'KSA', child: Text('🇸🇦 Saudi Arabia')),
                                  DropdownMenuItem(value: 'KWT', child: Text('🇰🇼 Kuwait')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setDlgState(() => selectedCountry = val);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Publish Ad Banner Live'),
                          onPressed: () {
                            final newAd = Advertisement(
                              id: 'ad_${DateTime.now().millisecondsSinceEpoch}',
                              title: titleController.text.trim(),
                              titleAr: titleArController.text.trim(),
                              message: messageController.text.trim(),
                              messageAr: messageArController.text.trim(),
                              graphicEmoji: selectedEmoji,
                              countryCode: selectedCountry,
                              countryFlag: selectedCountry == 'ALL' ? '🌐' : (LocalizationService.countries[selectedCountry]?.flag ?? '🌐'),
                              ctaText: ctaController.text.trim(),
                              primaryColor: selectedColor,
                              createdAt: DateTime.now(),
                              validUntil: DateTime.now().add(const Duration(days: 30)),
                              isActive: true,
                              isBroadcastPushed: true,
                            );

                            state.addNewAdvertisement(newAd);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('📢 Ad Banner "${newAd.title}" published and pushed live!'),
                                backgroundColor: const Color(0xFF16A34A),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // TERRITORIES TAB & EXISTING ENTERPRISE DIALOGS
  // ==========================================
  Widget _buildGlobalTerritoriesTab(BuildContext context, StateService state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _territories.length,
      itemBuilder: (context, index) {
        final c = _territories[index];
        final isCurrent = state.selectedCountry.code == c['code'];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCurrent ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(c['flag']?.toString() ?? '🌐', style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(c['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                              child: const Text('ACTIVE OPERATING REGION', style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('HQ: ${c['hqAddress']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(height: 6),
                      Text(
                        '${c['customersCount']} Customers • ${c['activeLaundries']} Laundries • ${c['driversCount']} Drivers • GMV: ${c['revenue']}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrent ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        state.setSelectedCountry(c['code']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Switched operating territory to ${c['name']} (${c['currency']})')),
                        );
                      },
                      child: Text(isCurrent ? 'Current' : 'Select'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showTerritoryDetailDialog(context, c, state),
                      child: const Text('Office & Personnel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- APPROVAL QUEUE TAB ---
  Widget _buildApprovalQueueTab(BuildContext context, StateService state) {
    final pendingRequests = state.staffRequests;

    if (pendingRequests.isEmpty) {
      return const Center(child: Text('No pending staff approval applications.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final req = pendingRequests[index];

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(req.fullName.isNotEmpty ? req.fullName.substring(0, 1) : 'S', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(req.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(width: 8),
                          BadgePill(
                            label: req.role,
                            backgroundColor: const Color(0xFFF1F5F9),
                            textColor: const Color(0xFF0F172A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Tel: ${req.phone} • QID: ${req.idCardNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () {
                        state.approveStaffRequest(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Staff member ${req.fullName} approved and onboarded!')),
                        );
                      },
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _showRejectDialog(context, req.id),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String reqId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Staff Application', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide reason for application rejection:'),
            const SizedBox(height: 10),
            TextField(controller: reasonController, decoration: const InputDecoration(border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            onPressed: () {
              Provider.of<StateService>(context, listen: false).rejectStaffRequest(reqId, reason: reasonController.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }

  void _showAddLaundryDialog(BuildContext context, StateService state) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+974 44');
    final addrCtrl = TextEditingController(text: 'Doha, Qatar');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Onboard New Partner Laundry', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Laundry Facility Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Contact Phone', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Physical Address / Zone', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newL = LaundryBranch(
                  id: 'lnd_${DateTime.now().millisecondsSinceEpoch}',
                  userId: 'LND-DOH-${state.laundries.length + 1}',
                  name: nameCtrl.text.trim(),
                  managerName: 'Branch Manager',
                  phone: phoneCtrl.text.trim(),
                  country: addrCtrl.text.trim(),
                  legalRegNumber: 'CR-QA-2026-${state.laundries.length + 10}',
                  documents: LaundryDocumentFolder(
                    crCommercialRegDoc: 'CR-Verified.pdf',
                    municipalityLicenseDoc: 'Munc-License.pdf',
                    civilDefenseCertificateDoc: 'CD-Pass.pdf',
                    ownerQidDoc: 'QID-Owner.pdf',
                    signedContractDoc: 'Contract.pdf',
                    bankIbanCertificate: 'IBAN-QNB.pdf',
                    registrationDate: DateTime.now(),
                  ),
                );
                state.laundries.add(newL);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Laundry "${newL.name}" successfully onboarded!')),
                );
              }
            },
            child: const Text('Add Facility'),
          ),
        ],
      ),
    );
  }

  void _showAddDriverDialog(BuildContext context, StateService state) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+974 ');
    final plateCtrl = TextEditingController(text: 'QTR-');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register New Fleet Driver', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Driver Full Name', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Phone', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: plateCtrl, decoration: const InputDecoration(labelText: 'Vehicle Reg Plate', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final newD = DriverModel(
                  id: 'drv_${DateTime.now().millisecondsSinceEpoch}',
                  userId: 'DRV-QA-${state.drivers.length + 100}',
                  fullName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  licenseNumber: 'DL-9921',
                  qidPassportNumber: '29863401',
                  assignedLaundryId: state.laundries.isNotEmpty ? state.laundries.first.id : 'lnd-1',
                  assignedLaundryName: state.laundries.isNotEmpty ? state.laundries.first.name : 'UniWash Hub',
                  documents: DriverDocumentFolder(
                    passportDocumentName: 'Passport.pdf',
                    visaDocumentName: 'Visa.pdf',
                    drivingLicenseDocumentName: 'License.pdf',
                    qidDocumentName: 'QID.pdf',
                    signedContractDocumentName: 'DriverContract.pdf',
                    vehicleRegPlate: plateCtrl.text.trim(),
                    joinedAt: DateTime.now(),
                  ),
                );
                state.drivers.add(newD);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Driver "${newD.fullName}" registered and activated!')),
                );
              }
            },
            child: const Text('Register Driver'),
          ),
        ],
      ),
    );
  }

  void _showActiveTerritoriesDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Global Territories (15 Nations)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  itemCount: _territories.length,
                  separatorBuilder: (ctx, idx) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final t = _territories[i];
                    return ListTile(
                      leading: Text(t['flag'], style: const TextStyle(fontSize: 24)),
                      title: Text(t['name'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      subtitle: Text('${t['customersCount']} Customers • GMV: ${t['revenue']}'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          state.setSelectedCountry(t['code']);
                          Navigator.pop(ctx);
                        },
                        child: const Text('Select'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGlobalGmvLedgerDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Global GMV Lifetime Financial Ledger', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Gross Lifetime GMV: QAR 1,480,900'),
            const SizedBox(height: 6),
            const Text('Platform Fee Rate: 15% Net SaaS'),
            const SizedBox(height: 6),
            const Text('Driver Payouts: 100% Cleared via Commercial Bank of Qatar / QNB'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showTerritoryDetailDialog(BuildContext context, Map<String, dynamic> c, StateService state) {
    final staff = (c['officeStaff'] as List<dynamic>?) ?? [];
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 600),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(c['flag'] ?? '🌐', style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text('HQ: ${c['hqAddress']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),
              const Text('Regional Appointed Officers', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: staff.length,
                  itemBuilder: (ctx, i) {
                    final s = staff[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
                      title: Text(s['name'], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      subtitle: Text('${s['role']} • ${s['phone']}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleSwitcherDialog(BuildContext context, StateService state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Switch Portal View', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 12),
            ...UserRole.values.map((role) {
              final isSel = role == state.currentUser.role;
              return ListTile(
                onTap: () {
                  state.switchRole(role);
                  Navigator.pop(ctx);
                },
                leading: Icon(
                  role == UserRole.superAdmin ? Icons.admin_panel_settings : Icons.person_outline,
                  color: isSel ? const Color(0xFF38BDF8) : Colors.white70,
                ),
                title: Text(role.title, style: TextStyle(color: isSel ? const Color(0xFF38BDF8) : Colors.white, fontWeight: FontWeight.w700)),
                trailing: isSel ? const Icon(Icons.check, color: Color(0xFF38BDF8)) : null,
              );
            }),
          ],
        ),
      ),
    );
  }
}
