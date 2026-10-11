import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import '../../widgets/stat_card.dart';
import '../common/order_detail_dialog.dart';

class SuperAdminCustomersTab extends StatefulWidget {
  final bool isAr;

  const SuperAdminCustomersTab({super.key, this.isAr = false});

  @override
  State<SuperAdminCustomersTab> createState() => _SuperAdminCustomersTabState();
}

class _SuperAdminCustomersTabState extends State<SuperAdminCustomersTab> {
  String _searchQuery = '';

  // Sample managed customers roster
  final List<Map<String, dynamic>> _customerProfiles = [
    {
      'id': 'cust-01',
      'name': 'Jassim Al-Kuwari',
      'email': 'jassim@example.qa',
      'phone': '+974 5589 1234',
      'city': 'Doha',
      'address': 'Villa 14, Al Waab St, Zone 55',
      'walletBalance': 250.0,
      'loyaltyPoints': 480,
      'totalOrders': 24,
      'isActive': true,
      'tier': 'VIP Gold',
    },
    {
      'id': 'cust-02',
      'name': 'Sheikha Maryam Al-Thani',
      'email': 'maryam.thani@royalty.qa',
      'phone': '+974 6677 8899',
      'city': 'Doha',
      'address': 'Palace Compound 3, West Bay Lagoon',
      'walletBalance': 1850.0,
      'loyaltyPoints': 2400,
      'totalOrders': 58,
      'isActive': true,
      'tier': 'Royal Diamond',
    },
    {
      'id': 'cust-03',
      'name': 'Dr. Khalid Al-Dosari',
      'email': 'khalid.dosari@qf.org.qa',
      'phone': '+974 3344 5566',
      'city': 'Doha',
      'address': 'Villa 8, Zone 66, West Bay Lagoon',
      'walletBalance': 420.0,
      'loyaltyPoints': 620,
      'totalOrders': 19,
      'isActive': true,
      'tier': 'VIP Gold',
    },
    {
      'id': 'cust-04',
      'name': 'Fatima Al-Ansari',
      'email': 'fatima.ansari@qatarairways.qa',
      'phone': '+974 5522 3344',
      'city': 'Doha',
      'address': 'Apt 402, Al Sadd Sports Club St',
      'walletBalance': 95.0,
      'loyaltyPoints': 180,
      'totalOrders': 12,
      'isActive': true,
      'tier': 'Silver Preferred',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final isAr = widget.isAr;

    final filtered = _customerProfiles.where((c) {
      if (_searchQuery.isEmpty) return true;
      final name = (c['name'] as String).toLowerCase();
      final phone = (c['phone'] as String).toLowerCase();
      final email = (c['email'] as String).toLowerCase();
      return name.contains(_searchQuery) || phone.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Header & Metrics
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
                            const Icon(Icons.people_alt_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'إدارة حسابات العملاء والمحافظ الرقمية' : 'Customer Relationship & Accounts Management',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr
                            ? 'سجل العملاء، الأرصدة، نقاط الولاء، الطلبات السابقة، وحالة الحساب'
                            : 'Customer registry, wallets, loyalty rewards, order history, and account governance',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                      label: Text(isAr ? '+ تسجيل عميل جديد' : '+ Register Customer', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () => _showAddCustomerDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metrics Row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'إجمالي العملاء المسجلين' : 'Registered Clients',
                        value: '${_customerProfiles.length}',
                        icon: Icons.people_outline_rounded,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'عملاء VIP' : 'VIP Accounts',
                        value: '${_customerProfiles.where((c) => (c['tier'] as String).contains('VIP') || (c['tier'] as String).contains('Royal')).length}',
                        icon: Icons.workspace_premium_rounded,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'أرصدة المحافظ' : 'Total Wallets',
                        value: '${_customerProfiles.fold<double>(0.0, (acc, c) => acc + (c['walletBalance'] as double)).toStringAsFixed(0)} QAR',
                        icon: Icons.account_balance_wallet_rounded,
                        color: const Color(0xFF059669),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: isAr ? 'إجمالي الطلبات المنفذة' : 'Client Orders',
                        value: '${_customerProfiles.fold<int>(0, (acc, c) => acc + (c['totalOrders'] as int))}',
                        icon: Icons.receipt_long_rounded,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search Bar
                Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: isAr ? 'البحث بالاسم، الهاتف، البريد، العنوان...' : 'Search customer by name, mobile, email, address...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Customer Feed
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final cust = filtered[idx];
                final isActive = cust['isActive'] as bool;

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
                        radius: 22,
                        backgroundColor: const Color(0xFF0F172A),
                        child: Text(
                          (cust['name'] as String).split(' ').take(2).map((n) => n[0]).join(),
                          style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 13),
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
                                  cust['name'] as String,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(cust['tier'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                ),
                                const Spacer(),
                                BadgePill(label: isActive ? 'Active Account' : 'Suspended', color: isActive ? const Color(0xFF16A34A) : Colors.grey),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(cust['phone'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                                const SizedBox(width: 14),
                                const Icon(Icons.email_outlined, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(cust['email'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                                const SizedBox(width: 14),
                                const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(cust['address'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Wallet: ${cust["walletBalance"]} QAR', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                                const SizedBox(width: 14),
                                Text('Loyalty: ${cust["loyaltyPoints"]} pts', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                const SizedBox(width: 14),
                                Text('Orders: ${cust["totalOrders"]} completed', style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                            icon: const Icon(Icons.history_rounded, size: 14),
                            label: const Text('Orders', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              final userOrders = state.orders.where((o) => o.customerPhone == cust['phone']).toList();
                              if (userOrders.isNotEmpty) {
                                OrderDetailDialog.show(context, userOrders.first);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No active orders for customer')),
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded, size: 26, color: isActive ? const Color(0xFF16A34A) : Colors.grey),
                            tooltip: isActive ? 'Suspend Account' : 'Activate Account',
                            onPressed: () {
                              setState(() {
                                cust['isActive'] = !isActive;
                              });
                            },
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
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register New Customer', style: TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Full Name')),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Phone')),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
              const SizedBox(height: 10),
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Delivery Address')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                _customerProfiles.insert(0, {
                  'id': 'cust-${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'city': 'Doha',
                  'address': addrCtrl.text.trim(),
                  'walletBalance': 0.0,
                  'loyaltyPoints': 50,
                  'totalOrders': 0,
                  'isActive': true,
                  'tier': 'Silver Standard',
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text('Register Customer'),
          ),
        ],
      ),
    );
  }
}
