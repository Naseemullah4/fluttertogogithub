import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/contract.dart';
import '../../models/laundry.dart';
import '../../models/order.dart';
import '../../services/localization_service.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/super_search_bar.dart';
import '../common/driver_folder_dialog.dart';
import '../common/laundry_profile_dialog.dart';
import '../common/order_detail_dialog.dart';
import '../laundry/laundry_thermal_invoice_dialog.dart';
import 'super_admin_catalog_tab.dart';
import 'super_admin_hourly_audit_tab.dart';
import '../../widgets/uniwash_logo.dart';

class SuperAdminMainScreen extends StatefulWidget {
  const SuperAdminMainScreen({super.key});

  @override
  State<SuperAdminMainScreen> createState() => _SuperAdminMainScreenState();
}

class _SuperAdminMainScreenState extends State<SuperAdminMainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        {'name': 'Charlotte Wright', 'role': 'London Logistics & Fleet Manager', 'phone': '+44 20 7946 0193', 'email': 'charlotte.ops@uniwash.com'},
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
        {'name': 'Jessica Miller', 'role': 'Tri-State Operations Supervisor', 'phone': '+1 212 555 0189', 'email': 'jessica.ops@uniwash.com'},
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
        {'name': 'Zainab Qureshi', 'role': 'Operations & Quality Lead', 'phone': '+92 51 289 0101', 'email': 'zainab.ops@uniwash.com'},
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
        {'name': 'Pooja Iyer', 'role': 'Customer Support & Dispatch Supervisor', 'phone': '+91 22 6100 8801', 'email': 'pooja.ops@uniwash.com'},
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showStaffReviewDialog(BuildContext context, StaffOnboardingRequest req) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 580),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Staff Onboarding Verification: ${req.fullName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Text('Role: ${req.role}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('Nationality: ${req.nationality} • Tel: ${req.phone} • Email: ${req.email}'),
              Text('National QID: ${req.idCardNumber} • Passport: ${req.passportNumber}'),
              Text('Residential Address: ${req.address}'),
              Text('Submitted: ${dateFormat.format(req.submittedAt)} by Regional Admin: ${req.regionalAdminName}'),
              const SizedBox(height: 16),
              const Text('Submitted Documents:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 6),
              _docChip(req.passportFileName, Icons.menu_book),
              _docChip(req.qidFileName, Icons.badge),
              _docChip(req.drivingLicenseFileName, Icons.drive_eta),
              _docChip(req.policeClearanceFileName, Icons.gavel),
              _docChip(req.medicalCertificateFileName, Icons.medical_services),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showRejectDialog(context, req.id);
                    },
                    child: const Text('Reject Application', style: TextStyle(color: AppColors.error)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_document, size: 16),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showRequestDocumentUpdateDialog(context, req.id);
                    },
                    label: const Text('Request Doc Update'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                    icon: const Icon(Icons.check, size: 16),
                    onPressed: () {
                      Provider.of<StateService>(context, listen: false).approveStaffRequest(req.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Staff "${req.fullName}" approved & activated!')),
                      );
                    },
                    label: const Text('Approve & Activate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _docChip(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 12, decoration: TextDecoration.underline, color: AppColors.primary)),
          const Spacer(),
          const Text('Verified Scan', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
        ],
      ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Provide reason for application rejection:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'e.g. Expired ID, invalid driver permit', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
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

  void _showRequestDocumentUpdateDialog(BuildContext context, String reqId) {
    final docsController = TextEditingController(text: 'Please re-upload clear high-resolution color scan of QID front & back.');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Document Update', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Specify what missing or renewed documents are required:'),
            const SizedBox(height: 10),
            TextField(
              controller: docsController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              Provider.of<StateService>(context, listen: false).requestStaffDocumentUpdate(reqId, docsController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document update notification sent to applicant & regional admin!')),
              );
            },
            child: const Text('Send Update Request'),
          ),
        ],
      ),
    );
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
            const UniWashLogo.badge(size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'لوحة تحكم المشرف العام العالمية' : 'Super Admin Global Web Portal',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A)),
                ),
                Text(
                  isAr ? 'إصدار المتصفح والكمبيوتر المكتبي • تحكم تشغيلي كامل' : 'Browser Web Edition • Full Operational Control',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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
              hintText: isAr ? 'بحث فائق: رقم الطلب، الهاتف، العميل...' : 'Super Search: Order #, Mobile, Customer...',
              onOrderSelected: (order) => OrderDetailDialog.show(context, order),
            ),
          ),
          const SizedBox(width: 14),

          // Territory / Country & Local Currency Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: DropdownButton<String>(
              value: state.selectedCountry.code,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF475569)),
              onChanged: (code) {
                if (code != null) state.setSelectedCountry(code);
              },
              items: LocalizationService.countries.values.map((c) {
                return DropdownMenuItem<String>(
                  value: c.code,
                  child: Row(
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '${c.code} (${c.currencyCode})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),

          // Language Toggle (EN / AR)
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.language, size: 16),
            label: Text(isAr ? 'English' : 'العربية', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            onPressed: () => state.toggleLanguage(),
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.price_change_outlined),
              text: isAr ? 'الأسعار والخصومات (كجم / قطعة)' : 'Catalog & Pricing (KG / Pcs & Sales)',
            ),
            Tab(
              icon: const Icon(Icons.access_time_rounded),
              text: isAr ? 'التدقيق بالساعات (يومياً وساعة بساعة)' : 'Hourly Operations Timeline',
            ),
            Tab(
              icon: const Icon(Icons.storefront_rounded),
              text: isAr ? 'المصابغ والمجلدات (${state.laundries.length})' : 'Laundry Facilities & Folders (${state.laundries.length})',
            ),
            Tab(
              icon: const Icon(Icons.sports_motorsports_rounded),
              text: isAr ? 'السائقين وبيانات الدخول (${state.drivers.length})' : 'Driver Fleet & Credentials (${state.drivers.length})',
            ),
            Tab(
              icon: const Icon(Icons.verified_user_rounded),
              text: isAr ? 'طلبات الموافقة والتحديثات (${state.staffRequests.length})' : 'Approval Queue & Docs (${state.staffRequests.length})',
            ),
            Tab(
              icon: const Icon(Icons.public_rounded),
              text: isAr ? 'الدول والمالية العالمية (15)' : 'Global Territories & Financials (15)',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Master Aggregate KPI Cards Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: isAr ? 'الدول النشطة' : 'Active Territories',
                    value: '15 Nations',
                    subtitle: isAr ? 'انقر لعرض تفاصيل الدول' : 'Click to inspect 15 nations',
                    icon: Icons.public,
                    iconColor: AppColors.primary,
                    onTap: () => _showActiveTerritoriesDialog(context, state),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: isAr ? 'إجمالي المبيعات العالمية' : 'Global GMV Lifetime',
                    value: state.formatCurrency(3850000.0),
                    subtitle: isAr ? 'انقر لعرض دفتر الأستاذ المالي' : 'Click for Financial Ledger',
                    icon: Icons.trending_up,
                    iconColor: AppColors.success,
                    onTap: () => _showGlobalGmvLedgerDialog(context, state),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: isAr ? 'أرباح العمولة (15%)' : 'Platform Net Royalties',
                    value: state.formatCurrency(577500.0),
                    subtitle: isAr ? 'انقر لعرض توزيع العمولات' : 'Click for 15% SaaS Breakdown',
                    icon: Icons.savings,
                    iconColor: AppColors.secondary,
                    onTap: () => _showPlatformRoyaltiesDialog(context, state),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: isAr ? 'الطلبات المسجلة' : 'Total Orders Recorded',
                    value: '${state.orders.length + 32450} Orders',
                    subtitle: isAr ? 'انقر لسجل الطلبات الكامل' : 'Click for Lifetime Archive',
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFF0284C7),
                    onTap: () => _showLifetimeOrdersLedgerDialog(context, state),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Catalog & Pricing Manager
                const SuperAdminCatalogTab(),

                // Tab 2: Hourly Timeline Audit (Day-by-Day, Hour-by-Hour)
                const SuperAdminHourlyAuditTab(),

                // Tab 3: Laundry Facilities Directory & Folders
                _buildLaundriesDirectoryTab(context, state),

                // Tab 4: Fleet & Driver Folders (User IDs & Password Vault)
                _buildDriversDirectoryTab(context, state),

                // Tab 5: Approval Queue & Document Updates
                _buildApprovalQueueTab(context, state),

                // Tab 6: Global Territories & Master Financials
                _buildGlobalTerritoriesTab(context, state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 3: Laundry Facilities Directory & Folders
  Widget _buildLaundriesDirectoryTab(BuildContext context, StateService state) {
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
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(laundry.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: laundry.warningStatus.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                laundry.warningStatus.displayName,
                                style: TextStyle(color: laundry.warningStatus.color, fontWeight: FontWeight.w800, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Branch User ID: ${laundry.userId} • CR: ${laundry.legalRegNumber} • Manager: ${laundry.managerName} (${laundry.phone})',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  // Button to Open Laundry Digital Profile & Folders
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.folder_shared_outlined, size: 16),
                    label: const Text('Open Profile & Folders'),
                    onPressed: () => LaundryProfileDialog.show(context, laundry),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Daily, Weekly, Monthly, Lifetime quick chips
              Row(
                children: [
                  _quickMetricBadge('Today Received', '${stats.todayReceived} orders', const Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  _quickMetricBadge('Today In-Process', '${stats.todayInProcessing} washing', const Color(0xFFD97706)),
                  const SizedBox(width: 10),
                  _quickMetricBadge('Today Ready', '${stats.todayReady} ready', const Color(0xFF16A34A)),
                  const SizedBox(width: 10),
                  _quickMetricBadge('Month Gross', state.formatCurrency(stats.monthlyRevenue), const Color(0xFF0D9488)),
                  const SizedBox(width: 10),
                  _quickMetricBadge('Lifetime Gross', state.formatCurrency(stats.lifetimeRevenue), const Color(0xFF7C3AED)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _quickMetricBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  // TAB 4: Driver Fleet & Credentials Vault
  Widget _buildDriversDirectoryTab(BuildContext context, StateService state) {
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
              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_motorsports_rounded, color: Color(0xFF2563EB), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                        const SizedBox(width: 6),
                        if (driver.starRating > 0) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              driver.starRating,
                              (i) => const Icon(Icons.star_rounded, color: Color(0xFFEAB308), size: 15),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (driver.hasBlueTag)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF0284C7), borderRadius: BorderRadius.circular(10)),
                            child: const Text('BLUE TAG', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                        if (driver.hasGoldenBadge) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFD97706), borderRadius: BorderRadius.circular(10)),
                            child: const Text('GOLD BADGE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                        ],
                        if (driver.hasPremiumDiamondBadge) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('DIAMOND 300+', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                          ),
                        ],
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: driver.warningStatus.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            driver.warningStatus.displayName,
                            style: TextStyle(color: driver.warningStatus.color, fontWeight: FontWeight.w800, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'User ID: ${driver.userId} • Tel: ${driver.phone} • Vehicle: ${driver.documents.vehicleRegPlate}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 3),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                          child: Text('Completed: ${driver.completedTrips} trips', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                          child: Text('Rating: ${driver.rating} ★', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                          child: Text('Bonus Rate: ${driver.bonusRatePerOrder.toStringAsFixed(2)} QAR/ord', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(4)),
                          child: Text('Acc. Bonus: ${driver.totalBonusEarnings.toStringAsFixed(1)} QAR', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF4338CA))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Button to Open Driver Folder & Password Vault
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.folder_shared_outlined, size: 16),
                label: const Text('Open Folder & Password Vault'),
                onPressed: () => DriverFolderDialog.show(context, driver),
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 5: Approval Queue & Document Updates
  Widget _buildApprovalQueueTab(BuildContext context, StateService state) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.staffRequests.length,
      itemBuilder: (context, index) {
        final req = state.staffRequests[index];
        Color statusColor;
        switch (req.status) {
          case ApprovalStatus.approved:
            statusColor = AppColors.success;
            break;
          case ApprovalStatus.rejected:
            statusColor = AppColors.error;
            break;
          case ApprovalStatus.updateRequired:
            statusColor = const Color(0xFFD97706);
            break;
          case ApprovalStatus.pending:
            statusColor = const Color(0xFF2563EB);
            break;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(req.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      req.status.displayName.toUpperCase(),
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Designation: ${req.role} • QID: ${req.idCardNumber} • Passport: ${req.passportNumber} • Tel: ${req.phone}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              Text(
                'Regional Operations Admin: ${req.regionalAdminName} • Address: ${req.address}',
                style: const TextStyle(fontSize: 11, color: Colors.black87),
              ),
              if (req.requiredDocumentDetails != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
                  child: Text('Document Update Requested: ${req.requiredDocumentDetails}', style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
              const Divider(height: 24),
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.description_outlined, size: 16),
                    label: const Text('View Full Profile & Documents'),
                    onPressed: () => _showStaffReviewDialog(context, req),
                  ),
                  const Spacer(),
                  if (req.status != ApprovalStatus.approved) ...[
                    OutlinedButton(
                      onPressed: () => _showRejectDialog(context, req.id),
                      child: const Text('Reject', style: TextStyle(color: AppColors.error)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () => _showRequestDocumentUpdateDialog(context, req.id),
                      child: const Text('Request Doc Update'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve & Activate'),
                      onPressed: () {
                        state.approveStaffRequest(req.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Staff "${req.fullName}" approved & activated!')),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 6: Global Territories & Financials (Interactive)
  Widget _buildGlobalTerritoriesTab(BuildContext context, StateService state) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _territories.length,
      itemBuilder: (context, index) {
        final c = _territories[index];
        final isCurrent = state.selectedCountry.code == c['code'];
        final staff = (c['officeStaff'] as List<dynamic>?) ?? [];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showTerritoryDetailDialog(context, c, state),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isCurrent ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: isCurrent ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isCurrent ? AppColors.primary.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(c['flag']?.toString() ?? '🌐', style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(c['name']?.toString() ?? 'Territory', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(width: 8),
                            BadgePill(
                              label: '${c['code'] ?? ""} • ${c['currency'] ?? ""}',
                              backgroundColor: AppColors.surfaceMuted,
                              textColor: AppColors.textDark,
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                child: const Text('ACTIVE SELECTION', style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.w900)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${c['customersCount'] ?? 0} Customers • ${c['activeLaundries'] ?? 0} Laundries • ${c['driversCount'] ?? 0} Drivers • ${staff.length} Office Staff',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'HQ: ${c['hqAddress']}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(c['revenue']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrent ? const Color(0xFF16A34A) : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            icon: Icon(isCurrent ? Icons.check : Icons.public, size: 13),
                            label: Text(isCurrent ? 'Current' : 'Select'),
                            onPressed: () {
                              state.setSelectedCountry(c['code']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Switched territory to ${c['name']} (${c['currency']})')),
                              );
                            },
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () => _showTerritoryDetailDialog(context, c, state),
                            child: const Text('View Office & Record'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // DIALOG 1: Active Global Territories
  void _showActiveTerritoriesDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 740, maxHeight: 640),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.public, color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Text('Active Global Territories (15 Nations)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),
              const Text('Click any territory to view its operational records, key office personnel, or set as active platform region:', style: TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _territories.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = _territories[i];
                    final isCurrent = state.selectedCountry.code == c['code'];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Text(c['flag']?.toString() ?? '🌐', style: const TextStyle(fontSize: 28)),
                      title: Row(
                        children: [
                          Text(c['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const SizedBox(width: 8),
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                              child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF15803D), fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                        ],
                      ),
                      subtitle: Text('${c['customersCount']} Customers • ${c['activeLaundries']} Facilities • ${c['driversCount']} Drivers', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(c['revenue']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.primary)),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCurrent ? const Color(0xFF16A34A) : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              state.setSelectedCountry(c['code']);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Switched active territory to ${c['name']} (${c['currency']})')),
                              );
                            },
                            child: Text(isCurrent ? 'Current' : 'Select'),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showTerritoryDetailDialog(context, c, state);
                      },
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

  // DIALOG 2: Global GMV Lifetime Financial Ledger
  void _showGlobalGmvLedgerDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 620),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up_rounded, color: AppColors.success, size: 24),
                      SizedBox(width: 10),
                      Text('Global GMV Lifetime Financial Ledger', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF86EFAC))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Gross Merchandise Volume (GMV)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(state.formatCurrency(3850000.0), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF16A34A))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Disbursed to Laundries (85%)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(state.formatCurrency(3272500.0), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Payment Settlement Channels:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              _channelTile('Credit Card / Apple Pay / Google Pay', '68%', state.formatCurrency(2618000.0), Icons.credit_card, const Color(0xFF2563EB)),
              _channelTile('Cash on Delivery (Driver Remittance)', '22%', state.formatCurrency(847000.0), Icons.money, const Color(0xFF16A34A)),
              _channelTile('POS Wireless Terminal on Delivery', '10%', state.formatCurrency(385000.0), Icons.point_of_sale, const Color(0xFFD97706)),
              const SizedBox(height: 16),
              const Text('Top Generating Operational Hubs:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 6),
              Expanded(
                child: ListView(
                  children: [
                    _hubTile('🇸🇦 Saudi Arabia (Riyadh & Jeddah Hubs)', '5,940,000 SAR', '62,100 Orders', '65 Laundries'),
                    _hubTile('🇦🇪 United Arab Emirates (Dubai & Abu Dhabi)', '3,820,000 AED', '38,200 Orders', '42 Laundries'),
                    _hubTile('🇶🇦 Qatar (Doha & Pearl Marina Hubs)', '1,480,900 QAR', '14,280 Orders', '18 Laundries'),
                    _hubTile('🇺🇸 United States (New York & Houston)', '\$1,850,000 USD', '51,000 Orders', '55 Laundries'),
                    _hubTile('🇬🇧 United Kingdom (London Metropolitan)', '£580,000 GBP', '19,400 Orders', '24 Laundries'),
                  ],
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generating Comprehensive Lifetime Financial Ledger PDF...')),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Export Lifetime Financial Audit'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DIALOG 3: Platform Net Royalties Breakdown
  void _showPlatformRoyaltiesDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 660, maxHeight: 580),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.savings_rounded, color: AppColors.secondary, size: 24),
                      SizedBox(width: 10),
                      Text('Platform Net Royalties (15% SaaS)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFD8B4FE))),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lifetime Net Royalty Accrued (15%)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(state.formatCurrency(577500.0), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF7E22CE))),
                        ],
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Franchise Royalty Rate', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text('15.0% Fixed', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Platform Royalty Fund Allocation Breakdown:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              _allocationTile('Net Operating Profit (HQ Equity)', '60%', state.formatCurrency(346500.0), const Color(0xFF16A34A)),
              _allocationTile('Driver Fleet Bonus & Rewards Pool', '20%', state.formatCurrency(115500.0), const Color(0xFF0284C7)),
              _allocationTile('Cloud Infrastructure & GPS Server Ops', '12%', state.formatCurrency(69300.0), const Color(0xFF64748B)),
              _allocationTile('Customer Protection & Garment Insurance', '8%', state.formatCurrency(46200.0), const Color(0xFFD97706)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 16, color: Color(0xFF475569)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('All platform royalties are audited in real time against laundry settlement disbursements.', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting 15% Platform Royalties Statement PDF...')),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Export Royalties Statement'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DIALOG 4: Global Lifetime Orders Ledger
  void _showLifetimeOrdersLedgerDialog(BuildContext context, StateService state) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 820, maxHeight: 680),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, color: Color(0xFF0284C7), size: 24),
                      const SizedBox(width: 10),
                      Text('Global Lifetime Orders Ledger (${state.orders.length} Active Records)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),
              const Text(
                'Complete permanent lifetime archive of all customer orders across all 15 operational territories.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: state.orders.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final o = state.orders[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: o.status.color.withValues(alpha: 0.15),
                        child: Icon(o.status.icon, color: o.status.color, size: 16),
                      ),
                      title: Row(
                        children: [
                          Text('Order #${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: o.status.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                            child: Text(o.status.displayName, style: TextStyle(color: o.status.color, fontSize: 10, fontWeight: FontWeight.w700)),
                          ),
                          const Spacer(),
                          Text(state.formatCurrency(o.totalAmount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary)),
                        ],
                      ),
                      subtitle: Text('${o.customerName} (${o.customerPhone}) • Laundry: ${o.laundryName} • Driver: ${o.assignedDriverName}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF475569)),
                            tooltip: 'View Record',
                            onPressed: () {
                              Navigator.pop(ctx);
                              OrderDetailDialog.show(context, o);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.print_outlined, size: 18, color: AppColors.primary),
                            tooltip: 'Print Thermal Receipt',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => LaundryThermalInvoiceDialog(order: o),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Exporting Global Lifetime Orders Archive (CSV / PDF)...')),
                      );
                    },
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Export Lifetime Records'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DIALOG 5: Territory Detail Dialog with Complete Record & Office Staff
  void _showTerritoryDetailDialog(BuildContext context, Map<String, dynamic> c, StateService state) {
    final staff = (c['officeStaff'] as List<dynamic>?) ?? [];
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 780, maxHeight: 720),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(c['flag']?.toString() ?? '🌐', style: const TextStyle(fontSize: 38)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(c['name']?.toString() ?? 'Territory', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                            const SizedBox(width: 8),
                            BadgePill(
                              label: '${c['code']} • ${c['currency']}',
                              backgroundColor: AppColors.surfaceMuted,
                              textColor: AppColors.textDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text('HQ Address: ${c['hqAddress'] ?? "Regional Office Hub"}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('SELECT THIS COUNTRY'),
                    onPressed: () {
                      state.setSelectedCountry(c['code']);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Active platform country switched to ${c['name']} (${c['currency']})!')),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 4 Operational Metrics KPI
                      Row(
                        children: [
                          _buildTerritoryMetricBox('Customers Registered', '${c['customersCount']}', Icons.groups_rounded, const Color(0xFF2563EB)),
                          const SizedBox(width: 10),
                          _buildTerritoryMetricBox('Laundry Facilities', '${c['activeLaundries']}', Icons.storefront_rounded, const Color(0xFF0D9488)),
                          const SizedBox(width: 10),
                          _buildTerritoryMetricBox('Fleet Drivers', '${c['driversCount']}', Icons.sports_motorsports_rounded, const Color(0xFFD97706)),
                          const SizedBox(width: 10),
                          _buildTerritoryMetricBox('Completed Orders', '${c['orders']}', Icons.task_alt_rounded, const Color(0xFF16A34A)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Financial Ledger Summary Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.monetization_on_outlined, color: AppColors.primary, size: 18),
                                SizedBox(width: 8),
                                Text('TERRITORY FINANCIAL LEDGER', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF1E293B))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Gross Lifetime GMV', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                    Text(c['revenue']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary)),
                                  ],
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Platform Royalty Rate', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                    Text('15% Net SaaS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF16A34A))),
                                  ],
                                ),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Settlement Status', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                    Text('100% Up-to-Date', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0284C7))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Regional Office & Key Personnel Directory
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.business_rounded, color: Color(0xFF0F172A), size: 18),
                              SizedBox(width: 8),
                              Text('REGIONAL OFFICE & KEY PERSONNEL (WHO IS IN OFFICE)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF0F172A))),
                            ],
                          ),
                          Text('${staff.length} Appointed Officers', style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Staff Directory Tiles
                      ...staff.map((st) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFF1F5F9),
                                child: Icon(Icons.person, color: Color(0xFF475569), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(st['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                          child: Text(st['role']?.toString() ?? '', style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 10, fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('Tel: ${st['phone']} • Email: ${st['email']}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF16A34A)),
                                tooltip: 'Call Officer',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling ${st['name']} (${st['phone']})...')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.email_outlined, size: 16, color: AppColors.primary),
                                tooltip: 'Email Officer',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Opening email dispatch to ${st['email']}...')),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Generating Regulatory & Financial Audit Report for ${c['name']}...')),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Export Territory Audit PDF'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sub-widgets for dialogs
  Widget _channelTile(String name, String percentage, String amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(percentage, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _hubTile(String hubName, String gmv, String orders, String facilities) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hubName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          Text('$gmv • $orders • $facilities', style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _allocationTile(String title, String pct, String amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          Text(pct, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: color)),
          const SizedBox(width: 10),
          Text(amount, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTerritoryMetricBox(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
          ],
        ),
      ),
    );
  }
}
