import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../common/order_detail_dialog.dart';
import '../laundry/laundry_thermal_invoice_dialog.dart';

class SuperAdminHourlyAuditTab extends StatefulWidget {
  const SuperAdminHourlyAuditTab({super.key});

  @override
  State<SuperAdminHourlyAuditTab> createState() => _SuperAdminHourlyAuditTabState();
}

class _SuperAdminHourlyAuditTabState extends State<SuperAdminHourlyAuditTab> {
  DateTime _selectedDate = DateTime.now();
  String _activeFilter = 'all'; // 'all', 'delivered', 'processing'

  void _showDayRevenueAuditDialog(BuildContext context, StateService state, List<LaundryOrder> orders, double totalRev) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF16A34A), size: 24),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Day Revenue & Financial Audit', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
                          Text('Audit Date: ${dateFormat.format(_selectedDate)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),
              // Financial summary row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF86EFAC))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Day Gross', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(state.formatCurrency(totalRev), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF16A34A))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF93C5FD))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Laundry Share (85%)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(state.formatCurrency(totalRev * 0.85), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFFAF5FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFD8B4FE))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Platform Royalty (15%)', style: TextStyle(fontSize: 11, color: Colors.black54)),
                          Text(state.formatCurrency(totalRev * 0.15), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF7E22CE))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Order Transactions (${orders.length}):', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
              const SizedBox(height: 8),
              Expanded(
                child: orders.isEmpty
                    ? const Center(child: Text('No orders recorded for this date.', style: TextStyle(color: Colors.black45)))
                    : ListView.separated(
                        itemCount: orders.length,
                        separatorBuilder: (c, i) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final o = orders[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: CircleAvatar(
                              radius: 18,
                              backgroundColor: o.status.color.withValues(alpha: 0.15),
                              child: Icon(o.status.icon, color: o.status.color, size: 16),
                            ),
                            title: Text('Order #${o.orderNumber} • ${o.customerName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                            subtitle: Text('${o.laundryName} • Driver: ${o.assignedDriverName} • Payment: ${o.paymentMethod.toUpperCase()}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(state.formatCurrency(o.totalAmount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                                Text(o.paymentStatus.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              OrderDetailDialog.show(context, o);
                            },
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
                        SnackBar(content: Text('Financial audit exported for ${dateFormat.format(_selectedDate)}!')),
                      );
                    },
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('Print Ledger'),
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

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<StateService>(context);
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');

    // Filter orders matching the selected date
    final dayAllOrders = state.orders.where((o) {
      return o.createdAt.year == _selectedDate.year &&
          o.createdAt.month == _selectedDate.month &&
          o.createdAt.day == _selectedDate.day;
    }).toList();

    final dayTotalRevenue = dayAllOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

    // Apply active filter if user clicked one of the KPI cards
    List<LaundryOrder> filteredOrders;
    if (_activeFilter == 'delivered') {
      filteredOrders = dayAllOrders.where((o) => o.status == OrderStatus.delivered).toList();
    } else if (_activeFilter == 'processing') {
      filteredOrders = dayAllOrders.where((o) => o.status == OrderStatus.inLaundry || o.status == OrderStatus.placed).toList();
    } else {
      filteredOrders = dayAllOrders;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar & Date Selector
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hourly Operations & Timeline Audit',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Hour-by-hour operational breakdown: Click any metric to filter or view audit ledger',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Date Picker Button
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(dateFormat.format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Generating Hourly Operations Audit PDF for ${dateFormat.format(_selectedDate)}...')),
                    );
                  },
                  icon: const Icon(Icons.print_rounded, size: 16),
                  label: const Text('Print Day Audit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Daily Summary KPI Cards (Clickable!)
            Row(
              children: [
                _buildKpiCard(
                  'Total Orders for Day',
                  '${dayAllOrders.length}',
                  Icons.receipt_long_rounded,
                  const Color(0xFF2563EB),
                  isSelected: _activeFilter == 'all',
                  onTap: () {
                    setState(() => _activeFilter = 'all');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Showing all ${dayAllOrders.length} orders for ${dateFormat.format(_selectedDate)}.')),
                    );
                  },
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  'Total Day Revenue',
                  state.formatCurrency(dayTotalRevenue),
                  Icons.payments_rounded,
                  const Color(0xFF16A34A),
                  isSelected: false,
                  badgeText: 'CLICK TO AUDIT',
                  onTap: () => _showDayRevenueAuditDialog(context, state, dayAllOrders, dayTotalRevenue),
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  'Delivered Orders',
                  '${dayAllOrders.where((o) => o.status == OrderStatus.delivered).length}',
                  Icons.task_alt_rounded,
                  const Color(0xFF0D9488),
                  isSelected: _activeFilter == 'delivered',
                  onTap: () {
                    setState(() {
                      _activeFilter = (_activeFilter == 'delivered') ? 'all' : 'delivered';
                    });
                  },
                ),
                const SizedBox(width: 14),
                _buildKpiCard(
                  'In Processing / Washing',
                  '${dayAllOrders.where((o) => o.status == OrderStatus.inLaundry || o.status == OrderStatus.placed).length}',
                  Icons.local_laundry_service_rounded,
                  const Color(0xFFD97706),
                  isSelected: _activeFilter == 'processing',
                  onTap: () {
                    setState(() {
                      _activeFilter = (_activeFilter == 'processing') ? 'all' : 'processing';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Active Filter Notice (if filtered)
            if (_activeFilter != 'all') ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _activeFilter == 'delivered' ? const Color(0xFFCCFBF1) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _activeFilter == 'delivered' ? const Color(0xFF2DD4BF) : const Color(0xFFFCD34D)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _activeFilter == 'delivered' ? Icons.filter_alt : Icons.filter_alt,
                      size: 16,
                      color: _activeFilter == 'delivered' ? const Color(0xFF0F766E) : const Color(0xFFB45309),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _activeFilter == 'delivered'
                          ? 'Filtering: Showing Delivered orders only (${filteredOrders.length} orders)'
                          : 'Filtering: Showing In Processing / Washing orders only (${filteredOrders.length} orders)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _activeFilter == 'delivered' ? const Color(0xFF0F766E) : const Color(0xFFB45309),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _activeFilter = 'all'),
                      child: const Text('Clear Filter (Show All)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 24-Hour Timeline Grid (From 07:00 to 23:00)
            const Text(
              '24-Hour Timeline Matrix (Hour-by-Hour Activity)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 16, // Hours from 07:00 to 22:00
              separatorBuilder: (c, i) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final hour = 7 + index;
                final hourStr = '${hour.toString().padLeft(2, '0')}:00 - ${(hour + 1).toString().padLeft(2, '0')}:00';

                // Orders in this hour matching filter
                final hourOrders = filteredOrders.where((o) => o.createdAt.hour == hour).toList();
                final hourRevenue = hourOrders.fold(0.0, (sum, o) => sum + o.totalAmount);
                final hasOrders = hourOrders.isNotEmpty;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasOrders ? Colors.white : const Color(0xFFFBFBFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasOrders ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
                      width: hasOrders ? 1.5 : 1.0,
                    ),
                    boxShadow: hasOrders
                        ? [
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: hasOrders ? AppColors.primary : const Color(0xFF94A3B8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  hourStr,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            '${hourOrders.length} Orders Created',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: hasOrders ? const Color(0xFF0F172A) : Colors.black45,
                            ),
                          ),
                          const Spacer(),
                          if (hasOrders) ...[
                            Text(
                              'Hourly Gross: ${state.formatCurrency(hourRevenue)}',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
                            ),
                          ] else ...[
                            const Text('No orders in this hour', style: TextStyle(fontSize: 11, color: Colors.black38)),
                          ],
                        ],
                      ),
                      if (hasOrders) ...[
                        const Divider(height: 20),
                        ...hourOrders.map((order) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: order.status.color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(order.status.icon, color: order.status.color, size: 14),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Order #${order.orderNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: order.status.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    order.status.displayName,
                                    style: TextStyle(color: order.status.color, fontSize: 10, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${order.customerName} (${order.customerPhone}) • ${order.laundryName} • Driver: ${order.assignedDriverName}',
                                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  state.formatCurrency(order.totalAmount),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF475569)),
                                  tooltip: 'View Full Record',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => OrderDetailDialog.show(context, order),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.print_outlined, size: 16, color: AppColors.primary),
                                  tooltip: 'Print Receipt',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => LaundryThermalInvoiceDialog(order: order),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool isSelected = false,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : const Color(0xFFE2E8F0),
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? color.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 10 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected ? color : Colors.black54,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: color),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
