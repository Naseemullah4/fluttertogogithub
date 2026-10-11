import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/country_branch.dart';
import '../../models/admin_team.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/stat_card.dart';

class SuperAdminCountriesBranchesTab extends StatefulWidget {
  final bool isAr;

  const SuperAdminCountriesBranchesTab({super.key, this.isAr = false});

  @override
  State<SuperAdminCountriesBranchesTab> createState() => _SuperAdminCountriesBranchesTabState();
}

class _SuperAdminCountriesBranchesTabState extends State<SuperAdminCountriesBranchesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = widget.isAr;
    final countries = state.countries;
    final allBranches = state.allBranches;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Sub-Header Banner & Metric Cards
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.public_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'إدارة الدول والفروع الإقليمية' : 'Country & Branch Enterprise Management',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                            ? 'التحكم الهرمي بالبنية التحتية: الدولة ← الفروع ← المشرفين ← السائقين والعمليات'
                            : 'Hierarchical Infrastructure Control: Country → Branches → Admins → Fleet & Operations',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_location_alt_rounded, size: 16, color: Color(0xFF38BDF8)),
                          label: Text(
                            isAr ? '+ إضافة دولة جديدة' : '+ Add Country',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showAddCountryDialog(context, state),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add_business_rounded, size: 16),
                          label: Text(
                            isAr ? '+ إضافة فرع جديد' : '+ Add Branch',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showAddBranchDialog(context, state),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Operational Metric Counter Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'إجمالي الدول' : 'Active Countries',
                        value: '${countries.where((c) => c.isActive).length} / ${countries.length}',
                        icon: Icons.language_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'شبكة الفروع' : 'Total Branches',
                        value: '${allBranches.length} Stations',
                        icon: Icons.store_mall_directory_rounded,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'المشرفين المعينين' : 'Assigned Admins',
                        value: '${state.admins.length} Regional',
                        icon: Icons.admin_panel_settings_rounded,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'أسطول السائقين' : 'Total Fleet',
                        value: '${state.drivers.length} Couriers',
                        icon: Icons.sports_motorsports_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search & Filter Omnibar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                          decoration: InputDecoration(
                            hintText: isAr ? 'البحث عن دولة، فرع، مدينة، مدير...' : 'Search country, branch, city, manager...',
                            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      indicatorColor: AppColors.primary,
                      tabs: [
                        Tab(text: isAr ? 'قائمة الدول (${countries.length})' : 'Countries (${countries.length})'),
                        Tab(text: isAr ? 'قائمة الفروع (${allBranches.length})' : 'Branches (${allBranches.length})'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar View (Countries / Branches)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCountriesList(context, state, countries),
                _buildBranchesList(context, state, allBranches),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COUNTRIES LIST VIEW
  // ==========================================
  Widget _buildCountriesList(BuildContext context, StateService state, List<CountryModel> countries) {
    final filtered = countries.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) ||
          c.nameAr.toLowerCase().contains(_searchQuery) ||
          c.code.toLowerCase().contains(_searchQuery) ||
          c.currencyCode.toLowerCase().contains(_searchQuery) ||
          c.hqAddress.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              widget.isAr ? 'لا توجد دول مطابقة لبحثك' : 'No countries found matching "$_searchQuery"',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final country = filtered[idx];
        final adminsForCountry = state.admins.where((a) => a.countryCode == country.code).length;
        final driversForCountry = state.teamMembers.where((m) => m.countryCode == country.code && m.category == TeamCategory.driver).length;
        final laundriesForCountry = state.laundries.where((l) => country.code == 'QAT').length; // sample mapping

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flag Emoji Avatar
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(country.flag, style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                country.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                country.nameAr,
                                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  country.code,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                                ),
                              ),
                              const Spacer(),
                              BadgePill(
                                label: country.isActive ? 'Active Market' : 'Inactive',
                                color: country.isActive ? const Color(0xFF16A34A) : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  country.hqAddress,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(country.primaryContactPhone, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(width: 12),
                              const Icon(Icons.email_outlined, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(country.primaryContactEmail, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(width: 12),
                              const Icon(Icons.monetization_on_outlined, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${country.currencyCode} (${country.currencySymbol}) • Rate: ${country.exchangeRateToQar}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
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

                // Statistics Row + Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Wrap(
                      spacing: 16,
                      children: [
                        _metricBadge(Icons.business_rounded, '${country.totalBranches} Branches', const Color(0xFF7C3AED)),
                        _metricBadge(Icons.admin_panel_settings_rounded, '$adminsForCountry Admins', const Color(0xFF0284C7)),
                        _metricBadge(Icons.sports_motorsports_rounded, '$driversForCountry Drivers', const Color(0xFFD97706)),
                        _metricBadge(Icons.local_laundry_service_rounded, '$laundriesForCountry Laundries', const Color(0xFF059669)),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF334155)),
                          label: const Text('Edit', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                          onPressed: () => _showEditCountryDialog(context, state, country),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            side: BorderSide(color: country.isActive ? AppColors.error.withValues(alpha: 0.5) : const Color(0xFF16A34A)),
                          ),
                          icon: Icon(country.isActive ? Icons.block_rounded : Icons.check_circle_outline, size: 14, color: country.isActive ? AppColors.error : const Color(0xFF16A34A)),
                          label: Text(
                            country.isActive ? 'Deactivate' : 'Activate',
                            style: TextStyle(fontSize: 11, color: country.isActive ? AppColors.error : const Color(0xFF16A34A)),
                          ),
                          onPressed: () => state.toggleCountryStatus(country.code),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.add_business_rounded, size: 14, color: Color(0xFF38BDF8)),
                          label: const Text('+ Add Branch', style: TextStyle(fontSize: 11)),
                          onPressed: () => _showAddBranchDialog(context, state, initialCountryCode: country.code),
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
    );
  }

  // ==========================================
  // BRANCHES LIST VIEW
  // ==========================================
  Widget _buildBranchesList(BuildContext context, StateService state, List<BranchModel> branches) {
    final filtered = branches.where((b) {
      if (_searchQuery.isEmpty) return true;
      return b.name.toLowerCase().contains(_searchQuery) ||
          b.nameAr.toLowerCase().contains(_searchQuery) ||
          b.city.toLowerCase().contains(_searchQuery) ||
          b.managerName.toLowerCase().contains(_searchQuery) ||
          b.code.toLowerCase().contains(_searchQuery) ||
          b.countryCode.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_center_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              widget.isAr ? 'لا توجد فروع مطابقة لبحثك' : 'No branches found matching "$_searchQuery"',
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final branch = filtered[idx];
        final country = state.getCountryByCode(branch.countryCode);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branch Icon & Code Badge
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Color(0xFF2563EB), size: 26),
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            branch.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(width: 8),
                          Text(branch.nameAr, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${country?.flag ?? "🌐"} ${branch.code}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                          ),
                          const Spacer(),
                          BadgePill(
                            label: branch.isActive ? 'Active Branch' : 'Inactive',
                            color: branch.isActive ? const Color(0xFF16A34A) : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${branch.city} • ${branch.address}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_rounded, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('Manager: ${branch.managerName}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w600)),
                          const SizedBox(width: 14),
                          const Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(branch.phone, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          const SizedBox(width: 14),
                          const Icon(Icons.email_outlined, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(branch.email, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Assigned Operations Roster & Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            spacing: 12,
                            children: [
                              _metricBadge(Icons.sports_motorsports_rounded, '${branch.activeDriversCount} Drivers', const Color(0xFFD97706)),
                              _metricBadge(Icons.local_laundry_service_rounded, '${branch.activeLaundriesCount} Facilities', const Color(0xFF059669)),
                              _metricBadge(Icons.group_rounded, '${branch.activeStaffCount} Staff', const Color(0xFF7C3AED)),
                            ],
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF334155)),
                                label: const Text('Edit', style: TextStyle(fontSize: 11, color: Color(0xFF334155))),
                                onPressed: () => _showEditBranchDialog(context, state, branch),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: BorderSide(color: branch.isActive ? AppColors.error.withValues(alpha: 0.5) : const Color(0xFF16A34A)),
                                ),
                                icon: Icon(branch.isActive ? Icons.block_rounded : Icons.check_circle_outline, size: 14, color: branch.isActive ? AppColors.error : const Color(0xFF16A34A)),
                                label: Text(
                                  branch.isActive ? 'Deactivate' : 'Activate',
                                  style: TextStyle(fontSize: 11, color: branch.isActive ? AppColors.error : const Color(0xFF16A34A)),
                                ),
                                onPressed: () => state.toggleBranchStatus(branch.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _metricBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // ==========================================
  // DIALOGS: ADD / EDIT COUNTRY
  // ==========================================
  void _showAddCountryDialog(BuildContext context, StateService state) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final nameArCtrl = TextEditingController();
    final flagCtrl = TextEditingController();
    final currCtrl = TextEditingController();
    final currSymCtrl = TextEditingController();
    final hqCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Country Market', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Country Code (e.g. SGP)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: flagCtrl, decoration: const InputDecoration(labelText: 'Flag Emoji (e.g. 🇸🇬)'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Country Name (English)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: nameArCtrl, decoration: const InputDecoration(labelText: 'Name (Arabic)'))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: currCtrl, decoration: const InputDecoration(labelText: 'Currency Code (e.g. SGD)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: currSymCtrl, decoration: const InputDecoration(labelText: 'Currency Symbol (e.g. S\$)'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: hqCtrl, decoration: const InputDecoration(labelText: 'Regional HQ Address')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Primary Phone'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Primary Email'))),
                  ],
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
              if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;
              state.addCountry(CountryModel(
                code: codeCtrl.text.trim().toUpperCase(),
                name: nameCtrl.text.trim(),
                nameAr: nameArCtrl.text.trim().isEmpty ? nameCtrl.text.trim() : nameArCtrl.text.trim(),
                flag: flagCtrl.text.trim().isEmpty ? '🌐' : flagCtrl.text.trim(),
                currencyCode: currCtrl.text.trim().toUpperCase().isEmpty ? 'USD' : currCtrl.text.trim().toUpperCase(),
                currencySymbol: currSymCtrl.text.trim().isEmpty ? '\$' : currSymCtrl.text.trim(),
                currencySymbolAr: currSymCtrl.text.trim().isEmpty ? '\$' : currSymCtrl.text.trim(),
                hqAddress: hqCtrl.text.trim().isEmpty ? 'Regional Financial District' : hqCtrl.text.trim(),
                primaryContactPhone: phoneCtrl.text.trim().isEmpty ? '+1 000 0000' : phoneCtrl.text.trim(),
                primaryContactEmail: emailCtrl.text.trim().isEmpty ? 'ops@uniwash.com' : emailCtrl.text.trim(),
                createdAt: DateTime.now(),
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Create Country'),
          ),
        ],
      ),
    );
  }

  void _showEditCountryDialog(BuildContext context, StateService state, CountryModel country) {
    final nameCtrl = TextEditingController(text: country.name);
    final hqCtrl = TextEditingController(text: country.hqAddress);
    final phoneCtrl = TextEditingController(text: country.primaryContactPhone);
    final emailCtrl = TextEditingController(text: country.primaryContactEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Country: ${country.name} (${country.code})', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Country Name')),
              const SizedBox(height: 10),
              TextField(controller: hqCtrl, decoration: const InputDecoration(labelText: 'HQ Address')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Primary Phone')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Primary Email')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              state.updateCountry(
                country.code,
                name: nameCtrl.text.trim(),
                hqAddress: hqCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DIALOGS: ADD / EDIT BRANCH
  // ==========================================
  void _showAddBranchDialog(BuildContext context, StateService state, {String? initialCountryCode}) {
    String selectedCountryCode = initialCountryCode ?? state.countries.first.code;
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final nameArCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mgrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Branch Station', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCountryCode,
                    decoration: const InputDecoration(labelText: 'Assign Country'),
                    items: state.countries.map((c) => DropdownMenuItem(value: c.code, child: Text('${c.flag} ${c.name} (${c.code})'))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCountryCode = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Branch Code (e.g. DOH-05)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City (e.g. Doha)'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Branch Name (English)'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: nameArCtrl, decoration: const InputDecoration(labelText: 'Name (Arabic)'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Physical Street Address')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: mgrCtrl, decoration: const InputDecoration(labelText: 'Branch Manager Name'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Branch Phone'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Branch Email')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) return;
                state.addBranch(
                  selectedCountryCode,
                  BranchModel(
                    id: 'branch-${selectedCountryCode.toLowerCase()}-${DateTime.now().millisecondsSinceEpoch}',
                    code: codeCtrl.text.trim().toUpperCase(),
                    name: nameCtrl.text.trim(),
                    nameAr: nameArCtrl.text.trim().isEmpty ? nameCtrl.text.trim() : nameArCtrl.text.trim(),
                    countryCode: selectedCountryCode,
                    city: cityCtrl.text.trim().isEmpty ? 'Central' : cityCtrl.text.trim(),
                    address: addrCtrl.text.trim().isEmpty ? 'Commercial Hub' : addrCtrl.text.trim(),
                    phone: phoneCtrl.text.trim().isEmpty ? '+1 000 0000' : phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim().isEmpty ? 'branch@uniwash.com' : emailCtrl.text.trim(),
                    managerName: mgrCtrl.text.trim().isEmpty ? 'Branch Supervisor' : mgrCtrl.text.trim(),
                    createdAt: DateTime.now(),
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Create Branch'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBranchDialog(BuildContext context, StateService state, BranchModel branch) {
    final nameCtrl = TextEditingController(text: branch.name);
    final cityCtrl = TextEditingController(text: branch.city);
    final addrCtrl = TextEditingController(text: branch.address);
    final phoneCtrl = TextEditingController(text: branch.phone);
    final emailCtrl = TextEditingController(text: branch.email);
    final mgrCtrl = TextEditingController(text: branch.managerName);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Branch: ${branch.name} (${branch.code})', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Branch Name')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'City'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: mgrCtrl, decoration: const InputDecoration(labelText: 'Manager Name'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Address')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'))),
                  ],
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
              state.updateBranch(
                branch.id,
                name: nameCtrl.text.trim(),
                city: cityCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                managerName: mgrCtrl.text.trim(),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
