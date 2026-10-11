import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/admin_team.dart';
import '../../models/driver.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/stat_card.dart';

class SuperAdminAdminsTeamTab extends StatefulWidget {
  final bool isAr;
  final int initialSubTab; // 0 = Admins, 1 = Team Roster

  const SuperAdminAdminsTeamTab({
    super.key,
    this.isAr = false,
    this.initialSubTab = 0,
  });

  @override
  State<SuperAdminAdminsTeamTab> createState() => _SuperAdminAdminsTeamTabState();
}

class _SuperAdminAdminsTeamTabState extends State<SuperAdminAdminsTeamTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TeamCategory? _categoryFilter;
  final String _countryFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialSubTab);
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
    final admins = state.admins;
    final teamMembers = state.teamMembers;

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
                            const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'إدارة المشرفين وفرق العمل والعمليات' : 'Admin Governance & Team Management Hub',
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
                            ? 'إدارة صلاحيات المشرفين الإقليميين، وخدمة العملاء، وموظفي المكاتب، وأسطول السائقين'
                            : 'Manage Regional Admins, RBAC Permissions, Customer Service Specialists & Operations Staff',
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
                          icon: const Icon(Icons.admin_panel_settings_rounded, size: 16, color: Color(0xFF38BDF8)),
                          label: Text(
                            isAr ? '+ إضافة مشرف إقليمي' : '+ Add Regional Admin',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showAddAdminDialog(context, state),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                          label: Text(
                            isAr ? '+ إضافة عضو فريق' : '+ Add Team Member',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _showAddTeamMemberDialog(context, state),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'المشرفين الإقليميين' : 'Regional Admins',
                        value: '${admins.where((a) => !a.isSuperAdmin && a.isActive).length} Active',
                        icon: Icons.security_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'خدمة العملاء (CS)' : 'Customer Support',
                        value: '${teamMembers.where((m) => m.category == TeamCategory.customerService && m.isActive).length} Agents',
                        icon: Icons.support_agent_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'موظفي المكاتب' : 'Office Staff',
                        value: '${teamMembers.where((m) => m.category == TeamCategory.officeStaff && m.isActive).length} Leads',
                        icon: Icons.business_center_rounded,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'السائقين بالرتب' : 'Drivers in Roster',
                        value: '${teamMembers.where((m) => m.category == TeamCategory.driver).length} Couriers',
                        icon: Icons.sports_motorsports_rounded,
                        color: const Color(0xFF059669),
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
                            hintText: isAr ? 'البحث عن موظف، مشرف، بريد، هاتف، فرع...' : 'Search admin, staff, email, phone, branch...',
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
                        Tab(text: isAr ? 'المشرفين والصلاحيات (${admins.length})' : 'Admins & Permissions (${admins.length})'),
                        Tab(text: isAr ? 'فرق العمل والعمليات (${teamMembers.length})' : 'Team Members Roster (${teamMembers.length})'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Content View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAdminsList(context, state, admins),
                _buildTeamList(context, state, teamMembers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ADMINS LIST WITH PERMISSIONS MATRIX
  // ==========================================
  Widget _buildAdminsList(BuildContext context, StateService state, List<AdminUserModel> admins) {
    final filtered = admins.where((a) {
      if (_searchQuery.isEmpty) return true;
      return a.fullName.toLowerCase().contains(_searchQuery) ||
          a.email.toLowerCase().contains(_searchQuery) ||
          a.phone.toLowerCase().contains(_searchQuery) ||
          a.countryCode.toLowerCase().contains(_searchQuery);
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final admin = filtered[idx];
        final country = state.getCountryByCode(admin.countryCode);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: admin.isSuperAdmin ? const Color(0xFF38BDF8).withValues(alpha: 0.6) : const Color(0xFFE2E8F0),
              width: admin.isSuperAdmin ? 1.5 : 1.0,
            ),
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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: admin.isSuperAdmin ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                      child: Text(
                        admin.fullName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(),
                        style: TextStyle(
                          color: admin.isSuperAdmin ? const Color(0xFF38BDF8) : const Color(0xFF1D4ED8),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
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
                              Text(
                                admin.fullName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 8),
                              if (admin.isSuperAdmin)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('SUPER ADMIN', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 9.5, fontWeight: FontWeight.w800)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('REGIONAL ADMIN (${admin.countryCode})', style: const TextStyle(color: Color(0xFFB45309), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              const Spacer(),
                              BadgePill(
                                label: admin.isActive ? 'Active Access' : 'Suspended',
                                color: admin.isActive ? const Color(0xFF16A34A) : Colors.grey,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(admin.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(width: 14),
                              const Icon(Icons.phone_outlined, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(admin.phone, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                              const SizedBox(width: 14),
                              const Icon(Icons.location_city_rounded, size: 13, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                admin.isSuperAdmin ? 'Global Multi-Territory Scope' : '${country?.name ?? admin.countryCode} • ${admin.assignedBranchIds.length} Assigned Branches',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Permission Pills Matrix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Permissions: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: admin.isSuperAdmin
                            ? [
                                _permChip('Full Enterprise Master Control (All 25 Modules)', const Color(0xFF059669)),
                              ]
                            : admin.permissions.take(6).map((p) => _permChip(p.label, const Color(0xFF2563EB))).toList()
                          ..addAll(admin.permissions.length > 6
                              ? [_permChip('+${admin.permissions.length - 6} more', Colors.grey)]
                              : []),
                      ),
                    ),
                    if (!admin.isSuperAdmin) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                        icon: const Icon(Icons.edit_outlined, size: 13),
                        label: const Text('Edit Rights', style: TextStyle(fontSize: 11)),
                        onPressed: () => _showEditAdminDialog(context, state, admin),
                      ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          side: BorderSide(color: admin.isActive ? AppColors.error : const Color(0xFF16A34A)),
                        ),
                        icon: Icon(admin.isActive ? Icons.block_rounded : Icons.check_circle_outline, size: 13, color: admin.isActive ? AppColors.error : const Color(0xFF16A34A)),
                        label: Text(admin.isActive ? 'Suspend' : 'Activate', style: TextStyle(fontSize: 11, color: admin.isActive ? AppColors.error : const Color(0xFF16A34A))),
                        onPressed: () => state.toggleAdminStatus(admin.id),
                      ),
                    ],
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
  // TEAM MEMBERS LIST
  // ==========================================
  Widget _buildTeamList(BuildContext context, StateService state, List<TeamMemberModel> teamMembers) {
    final filtered = teamMembers.where((m) {
      if (_categoryFilter != null && m.category != _categoryFilter) return false;
      if (_countryFilter != 'ALL' && m.countryCode != _countryFilter) return false;
      if (_searchQuery.isEmpty) return true;
      return m.fullName.toLowerCase().contains(_searchQuery) ||
          m.email.toLowerCase().contains(_searchQuery) ||
          m.phone.toLowerCase().contains(_searchQuery) ||
          m.jobTitle.toLowerCase().contains(_searchQuery) ||
          m.branchName.toLowerCase().contains(_searchQuery);
    }).toList();

    return Column(
      children: [
        // Category Pills Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All Categories', _categoryFilter == null, () => setState(() => _categoryFilter = null)),
                ...TeamCategory.values.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _filterChip(
                      cat.title,
                      _categoryFilter == cat,
                      () => setState(() => _categoryFilter = cat),
                      icon: cat.icon,
                      color: cat.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final member = filtered[idx];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: member.category.color.withValues(alpha: 0.12),
                      child: Icon(member.category.icon, size: 20, color: member.category.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                member.fullName,
                                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: member.category.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(member.category.title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: member.category.color)),
                              ),
                              if (member.driverAffiliation != null) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: member.driverAffiliation!.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: member.driverAffiliation!.color.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(member.driverAffiliation!.icon, size: 10, color: member.driverAffiliation!.color),
                                      const SizedBox(width: 3),
                                      Text(
                                        member.driverAffiliation!.shortBadge,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: member.driverAffiliation!.color),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              BadgePill(label: member.isActive ? 'Active' : 'Off-Duty', color: member.isActive ? const Color(0xFF16A34A) : Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(member.jobTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.storefront_rounded, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(member.branchName, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(width: 12),
                              const Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(member.phone, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              const SizedBox(width: 12),
                              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 2),
                              Text('${member.rating} Rating (${member.completedOrdersCount} orders)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
                          tooltip: 'Edit Member',
                          onPressed: () => _showEditTeamMemberDialog(context, state, member),
                        ),
                        IconButton(
                          icon: Icon(member.isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, size: 24, color: member.isActive ? const Color(0xFF16A34A) : Colors.grey),
                          tooltip: member.isActive ? 'Deactivate' : 'Activate',
                          onPressed: () => state.toggleTeamMemberStatus(member.id),
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

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap, {IconData? icon, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? (color ?? AppColors.primary) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? Colors.white : (color ?? const Color(0xFF475569))),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }

  // ==========================================
  // DIALOGS: ADD / EDIT ADMIN
  // ==========================================
  void _showAddAdminDialog(BuildContext context, StateService state) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String selectedCountryCode = state.countries.first.code;
    final Set<AppPermission> selectedPerms = Set.from(AppPermission.regionalAdminDefaults);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Onboard New Regional Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Official Corporate Email')),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCountryCode,
                    decoration: const InputDecoration(labelText: 'Assigned Territory (Country)'),
                    items: state.countries.map((c) => DropdownMenuItem(value: c.code, child: Text('${c.flag} ${c.name} (${c.code})'))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCountryCode = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Role-Based Access Control Permissions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                    child: ListView(
                      children: AppPermission.values.map((perm) {
                        final isChecked = selectedPerms.contains(perm);
                        return CheckboxListTile(
                          dense: true,
                          title: Text(perm.label, style: const TextStyle(fontSize: 12)),
                          subtitle: Text(perm.key, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          value: isChecked,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedPerms.add(perm);
                              } else {
                                selectedPerms.remove(perm);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
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
                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) return;
                state.addAdmin(AdminUserModel(
                  id: 'adm-${DateTime.now().millisecondsSinceEpoch}',
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  countryCode: selectedCountryCode,
                  assignedBranchIds: state.getBranchesForCountry(selectedCountryCode).map((b) => b.id).toList(),
                  permissions: selectedPerms,
                  createdAt: DateTime.now(),
                  lastLoginAt: DateTime.now(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Grant Admin Access'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAdminDialog(BuildContext context, StateService state, AdminUserModel admin) {
    final nameCtrl = TextEditingController(text: admin.fullName);
    final emailCtrl = TextEditingController(text: admin.email);
    final phoneCtrl = TextEditingController(text: admin.phone);
    String selectedCountryCode = admin.countryCode;
    final Set<AppPermission> selectedPerms = Set.from(admin.permissions);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit Admin Rights: ${admin.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 16),
                  const Text('Modify Permissions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                    child: ListView(
                      children: AppPermission.values.map((perm) {
                        final isChecked = selectedPerms.contains(perm);
                        return CheckboxListTile(
                          dense: true,
                          title: Text(perm.label, style: const TextStyle(fontSize: 12)),
                          subtitle: Text(perm.key, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                          value: isChecked,
                          onChanged: (val) {
                            setDialogState(() {
                              if (val == true) {
                                selectedPerms.add(perm);
                              } else {
                                selectedPerms.remove(perm);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
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
                state.updateAdmin(
                  admin.id,
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  countryCode: selectedCountryCode,
                  branches: admin.assignedBranchIds,
                  permissions: selectedPerms,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Update Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DIALOGS: ADD / EDIT TEAM MEMBER
  // ==========================================
  void _showAddTeamMemberDialog(BuildContext context, StateService state) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final jobCtrl = TextEditingController();
    TeamCategory selectedCat = TeamCategory.customerService;
    DriverAffiliation selectedAffiliation = DriverAffiliation.companyFleet;
    String selectedCountryCode = state.countries.first.code;
    final branches = state.getBranchesForCountry(selectedCountryCode);
    String selectedBranchId = branches.isNotEmpty ? branches.first.id : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Team Member to Roster', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: jobCtrl, decoration: const InputDecoration(labelText: 'Job Title / Designation'))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TeamCategory>(
                    initialValue: selectedCat,
                    decoration: const InputDecoration(labelText: 'Department / Category'),
                    items: TeamCategory.values.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.title))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCat = val);
                    },
                  ),
                  if (selectedCat == TeamCategory.driver) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DriverAffiliation>(
                      initialValue: selectedAffiliation,
                      decoration: const InputDecoration(labelText: 'Driver Affiliation (Fleet Type)'),
                      items: DriverAffiliation.values.map((aff) {
                        return DropdownMenuItem(
                          value: aff,
                          child: Text(aff.fullTitle, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedAffiliation = val);
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCountryCode,
                    decoration: const InputDecoration(labelText: 'Territory Country'),
                    items: state.countries.map((c) => DropdownMenuItem(value: c.code, child: Text('${c.flag} ${c.name} (${c.code})'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCountryCode = val;
                          final bList = state.getBranchesForCountry(val);
                          selectedBranchId = bList.isNotEmpty ? bList.first.id : '';
                        });
                      }
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
                final bList = state.getBranchesForCountry(selectedCountryCode);
                final branch = bList.firstWhere((b) => b.id == selectedBranchId, orElse: () => bList.first);

                state.addTeamMember(TeamMemberModel(
                  id: 'tm-${DateTime.now().millisecondsSinceEpoch}',
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim().isEmpty ? 'staff@uniwash.com' : emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim().isEmpty ? '+1 000 0000' : phoneCtrl.text.trim(),
                  category: selectedCat,
                  driverAffiliation: selectedCat == TeamCategory.driver ? selectedAffiliation : null,
                  countryCode: selectedCountryCode,
                  branchId: branch.id,
                  branchName: branch.name,
                  jobTitle: jobCtrl.text.trim().isEmpty ? selectedCat.title : jobCtrl.text.trim(),
                  joinedAt: DateTime.now(),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTeamMemberDialog(BuildContext context, StateService state, TeamMemberModel member) {
    final nameCtrl = TextEditingController(text: member.fullName);
    final emailCtrl = TextEditingController(text: member.email);
    final phoneCtrl = TextEditingController(text: member.phone);
    final jobCtrl = TextEditingController(text: member.jobTitle);
    TeamCategory selectedCat = member.category;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit Team Member: ${member.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email'))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: jobCtrl, decoration: const InputDecoration(labelText: 'Job Title')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<TeamCategory>(
                    initialValue: selectedCat,
                    decoration: const InputDecoration(labelText: 'Department / Category'),
                    items: TeamCategory.values.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.title))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCat = val);
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
                state.updateTeamMember(
                  member.id,
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  category: selectedCat,
                  jobTitle: jobCtrl.text.trim(),
                  branchId: member.branchId,
                  branchName: member.branchName,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
