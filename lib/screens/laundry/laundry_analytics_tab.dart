import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/stat_card.dart';

class LaundryAnalyticsTab extends StatefulWidget {
  const LaundryAnalyticsTab({super.key});

  @override
  State<LaundryAnalyticsTab> createState() => _LaundryAnalyticsTabState();
}

class _LaundryAnalyticsTabState extends State<LaundryAnalyticsTab> {
  String _selectedRange = 'Monthly';
  final List<String> _ranges = ['Daily', 'Weekly', 'Monthly', 'Yearly', 'Lifetime'];

  Map<String, dynamic> get _currentData {
    switch (_selectedRange) {
      case 'Daily':
        return {
          'orders': '18',
          'completed': '14',
          'pending': '4',
          'gross': '1,420 QAR',
          'commission': '213 QAR (15%)',
          'net': '1,207 QAR',
        };
      case 'Weekly':
        return {
          'orders': '124',
          'completed': '112',
          'pending': '12',
          'gross': '11,450 QAR',
          'commission': '1,717 QAR (15%)',
          'net': '9,733 QAR',
        };
      case 'Monthly':
        return {
          'orders': '482',
          'completed': '460',
          'pending': '22',
          'gross': '48,600 QAR',
          'commission': '7,290 QAR (15%)',
          'net': '41,310 QAR',
        };
      case 'Yearly':
        return {
          'orders': '5,890',
          'completed': '5,820',
          'pending': '70',
          'gross': '592,400 QAR',
          'commission': '88,860 QAR (15%)',
          'net': '503,540 QAR',
        };
      case 'Lifetime':
      default:
        return {
          'orders': '14,280',
          'completed': '14,210',
          'pending': '70',
          'gross': '1,480,900 QAR',
          'commission': '222,135 QAR (15%)',
          'net': '1,258,765 QAR',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Financial & Order Analytics', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              DropdownButton<String>(
                value: _selectedRange,
                underline: const SizedBox(),
                items: _ranges.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontWeight: FontWeight.w700)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedRange = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: [
              StatCard(
                title: 'Gross Revenue',
                value: data['gross'],
                subtitle: '$_selectedRange total intake',
                icon: Icons.monetization_on,
                iconColor: AppColors.primary,
              ),
              StatCard(
                title: 'Net Laundry Payout',
                value: data['net'],
                subtitle: 'After 15% platform commission',
                icon: Icons.account_balance,
                iconColor: AppColors.success,
              ),
              StatCard(
                title: 'Total Orders',
                value: data['orders'],
                subtitle: '${data['completed']} completed, ${data['pending']} pending',
                icon: Icons.inventory_2,
                iconColor: AppColors.accent,
              ),
              StatCard(
                title: 'Platform Royalty (15%)',
                value: data['commission'],
                subtitle: 'Contractually settled monthly',
                icon: Icons.pie_chart,
                iconColor: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                const Text('Garment Care Breakdown by Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 14),
                _progressBar('Traditional (Thobe, Abaya, Ghutra)', 0.42, '42%', AppColors.primary),
                const SizedBox(height: 10),
                _progressBar('Suits & Evening Dresses (Dry Clean)', 0.28, '28%', AppColors.secondary),
                const SizedBox(height: 10),
                _progressBar('Tops & Everyday Laundry (Wash & Fold)', 0.18, '18%', AppColors.accent),
                const SizedBox(height: 10),
                _progressBar('Home Bedding & Linens', 0.12, '12%', AppColors.warning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressBar(String title, double ratio, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: AppColors.surfaceMuted,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
