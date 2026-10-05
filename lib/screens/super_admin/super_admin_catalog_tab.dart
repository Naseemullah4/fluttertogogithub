import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/catalog_item.dart';
import '../../services/state_service.dart';
import '../../services/catalog_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';
import 'super_admin_catalog_editor_dialog.dart';
import 'super_admin_event_offers_dialog.dart';
import '../common/ad_management_dialog.dart';
import '../common/admin_popup_manager_dialog.dart';
import '../common/occasion_theming_dialog.dart';

class SuperAdminCatalogTab extends StatefulWidget {
  const SuperAdminCatalogTab({super.key});

  @override
  State<SuperAdminCatalogTab> createState() => _SuperAdminCatalogTabState();
}

class _SuperAdminCatalogTabState extends State<SuperAdminCatalogTab> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final items = state.catalogItems;

    final filteredItems = items.where((item) {
      final matchesCat = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = item.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.specialOfferTag ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Column(
      children: [
        // Top Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              // Event & Seasonal Offers Control Banner
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF1E3A8A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Seasonal & Event Offers Engine',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${state.activeEventOffers.length} Active On App',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '🌙 Ramadan • 🕌 Eid • 🇶🇦 National Day (50% Off) • 🇦🇪 UAE • 🇸🇦 KSA • 🎄 Carmiss • ☀️ Summer • 🎒 School',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => SuperAdminEventOffersDialog.show(context),
                          icon: const Icon(Icons.tune, size: 15),
                          label: const Text('Event Offers', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => AdManagementDialog.show(context),
                          icon: const Icon(Icons.campaign, size: 15),
                          label: const Text('Ads & Messaging', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => OccasionThemingDialog.show(context),
                          icon: const Icon(Icons.palette, size: 15),
                          label: const Text('Occasion Theming', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => AdminPopupManagerDialog.show(context),
                          icon: const Icon(Icons.flash_on, size: 15),
                          label: const Text('Customer Popup', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search garment, per kg items, sale offers...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () {
                      final newItem = CatalogItem(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        category: _selectedCategory == 'All' ? 'Wash & Fold' : _selectedCategory,
                        itemName: 'New Custom Item',
                        basePriceQar: 20.0,
                        icon: '🧺',
                        pricingUnit: PricingUnit.piece,
                      );
                      showDialog(
                        context: context,
                        builder: (_) => SuperAdminCatalogEditorDialog(
                          item: newItem,
                          onSave: (saved) {
                            state.addNewCatalogItem(saved);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✨ Added "${saved.itemName}" to catalog!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Item / Service'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Category filter pills
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: CatalogData.categories.length,
                  itemBuilder: (ctx, i) {
                    final cat = CatalogData.categories[i];
                    final isSel = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        selected: isSel,
                        label: Text(cat),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceMuted,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? Colors.white : AppColors.textDark,
                        ),
                        onSelected: (val) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Items List Table
        Expanded(
          child: filteredItems.isEmpty
              ? const Center(child: Text('No catalog items match your search.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isOnSale ? AppColors.error.withValues(alpha: 0.4) : AppColors.border,
                          width: item.isOnSale ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(item.icon, style: const TextStyle(fontSize: 26)),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Name, Category & Badges
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.itemName,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    BadgePill(
                                      label: item.pricingUnit.displayName.toUpperCase(),
                                      backgroundColor: item.pricingUnit == PricingUnit.kg
                                          ? AppColors.accent.withValues(alpha: 0.15)
                                          : AppColors.primary.withValues(alpha: 0.12),
                                      textColor: item.pricingUnit == PricingUnit.kg
                                          ? AppColors.accent
                                          : AppColors.primaryDark,
                                    ),
                                    if (item.isOnSale) ...[
                                      const SizedBox(width: 6),
                                      BadgePill(
                                        label: '${item.saleDiscountPercent.toStringAsFixed(0)}% OFF',
                                        backgroundColor: AppColors.error.withValues(alpha: 0.15),
                                        textColor: AppColors.error,
                                        icon: Icons.local_fire_department,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Category: ${item.category} • ID: ${item.id}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                                if (item.hasSpecialOffer) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFFFDE68A)),
                                    ),
                                    child: Text(
                                      '🏷️ Special Offer: "${item.specialOfferTag}"',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Price Up & Down Controls
                          Row(
                            children: [
                              IconButton.filledTonal(
                                onPressed: () {
                                  state.adjustItemPrice(item.id, -1);
                                },
                                icon: const Icon(Icons.remove, size: 16),
                                tooltip: 'Decrease 1 QAR',
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (item.isOnSale) ...[
                                      Text(
                                        '${item.basePriceQar.toStringAsFixed(0)} QAR',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text(
                                        '${item.effectivePriceQar.toStringAsFixed(0)} QAR',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        '${item.basePriceQar.toStringAsFixed(0)} QAR',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 17,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                    Text(
                                      item.pricingUnit.shortLabel,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                onPressed: () {
                                  state.adjustItemPrice(item.id, 1);
                                },
                                icon: const Icon(Icons.add, size: 16),
                                tooltip: 'Increase 1 QAR',
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),

                          // Full Edit Button
                          OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => SuperAdminCatalogEditorDialog(
                                  item: item,
                                  onSave: (updated) {
                                    state.updateCatalogItem(updated);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('✅ Updated "${updated.itemName}" pricing & offers!'),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 14),
                            label: const Text('Edit Sale & Unit'),
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
}
