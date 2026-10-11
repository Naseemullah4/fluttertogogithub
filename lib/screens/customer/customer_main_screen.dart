import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event_offer.dart';
import '../../services/state_service.dart';
import '../../services/catalog_data.dart';
import '../../services/localization_service.dart';
import '../../models/catalog_item.dart';
import '../../models/order_item.dart';
import '../../models/order.dart';
import '../../theme/app_colors.dart';
import 'item_detail_sheet.dart';
import 'cart_sheet.dart';
import 'address_picker_sheet.dart';
import 'order_stepper_screen.dart';
import 'customer_profile_tab.dart';
import 'customer_offers_tab.dart';
import '../../widgets/uniwash_logo.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _currentTabIndex =
      0; // 0: Services / Catalog, 1: Offers & Ads, 2: Profile
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openItemDetailSheet(
    BuildContext context,
    StateService state,
    CatalogItem item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemDetailSheet(
        item: item,
        onAdd: (serviceType, qtyOrWeight, notes) {
          state.addToCart(
            item,
            serviceType,
            quantityOrWeight: qtyOrWeight,
            notes: notes,
          );
          final qtyLabel = item.pricingUnit == PricingUnit.kg
              ? '${qtyOrWeight.toStringAsFixed(1)} KG'
              : '${qtyOrWeight.round()} Pcs';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🧺 Added $qtyLabel of ${item.itemName} (${serviceType.displayName}) to basket',
              ),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      ),
    );
  }

  void _showOfferDetailDialog(
    BuildContext context,
    EventOffer offer,
    bool isAr,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(offer.iconEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAr ? offer.titleAr : offer.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: offer.bannerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${offer.discountPercent.toStringAsFixed(0)}% DISCOUNT • Code: ${offer.promoCode}',
                style: TextStyle(
                  color: offer.bannerColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isAr ? offer.descriptionAr : offer.description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Valid until: ${DateFormat('dd MMMM yyyy').format(offer.validUntil)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: offer.bannerColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: offer.promoCode));
              Navigator.pop(ctx);
              setState(() => _currentTabIndex = 0);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🎉 Promo Code "${offer.promoCode}" copied to clipboard!',
                  ),
                  backgroundColor: offer.bannerColor,
                ),
              );
            },
            child: const Text('Copy Code & Shop'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final activeOrder = state.currentCustomerActiveOrder;
    final theme = state.currentOccasionTheme;
    final isAr = state.currentLanguage == AppLanguage.ar;

    final filteredItems = state.catalogItems.where((item) {
      final q = _searchQuery.toLowerCase();
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch =
          item.itemName.toLowerCase().contains(q) ||
          item.itemNameAr.contains(_searchQuery) ||
          item.category.toLowerCase().contains(q) ||
          item.categoryAr.contains(_searchQuery) ||
          (item.specialOfferTag ?? '').toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();

    Widget bodyContent;
    if (_currentTabIndex == 1) {
      bodyContent = CustomerOffersTab(
        onOrderNow: () => setState(() => _currentTabIndex = 0),
      );
    } else if (_currentTabIndex == 2) {
      bodyContent = const CustomerProfileTab();
    } else {
      bodyContent = Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Active Order Alert Bar (Entire bar is Clickable!)
              if (activeOrder != null)
                SliverToBoxAdapter(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderStepperScreen(order: activeOrder),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: activeOrder.isUrgent
                            ? Colors.red.shade50
                            : activeOrder.status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: activeOrder.isUrgent
                              ? const Color(0xFFDC2626)
                              : activeOrder.status.color.withValues(alpha: 0.4),
                          width: activeOrder.isUrgent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            activeOrder.isUrgent
                                ? Icons.electric_bolt_rounded
                                : activeOrder.status.icon,
                            color: activeOrder.isUrgent
                                ? const Color(0xFFDC2626)
                                : activeOrder.status.color,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (activeOrder.isUrgent)
                                      Container(
                                        margin: const EdgeInsets.only(right: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          '🚨 URGENT RUSH',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        'Order #${activeOrder.orderNumber} • ${activeOrder.status.displayName}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: activeOrder.isUrgent
                                              ? const Color(0xFFDC2626)
                                              : activeOrder.status.color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activeOrder.isUrgent
                                      ? '⚡ 4-Hour Express Turnaround • ${activeOrder.scheduleSummary}'
                                      : 'Tap to view live order progress • ${activeOrder.scheduleSummary}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: activeOrder.isUrgent
                                        ? const Color(0xFFB91C1C)
                                        : AppColors.textMuted,
                                    fontWeight: activeOrder.isUrgent
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: activeOrder.isUrgent
                                  ? const Color(0xFFDC2626)
                                  : activeOrder.status.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Track',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Admin Active Offer / National Day Banner (Only appears when Admin activates an offer!)
              _buildAdminActiveOfferBanner(context, state, isAr),

              // Friendly Personalized Welcome & Hero Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.25),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr
                                        ? 'مرحباً، ${state.currentUser.fullName.split(' ').first}! 👋'
                                        : 'Welcome, ${state.currentUser.fullName.split(' ').first}! 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isAr
                                        ? 'ما الذي تود غسله وكيه بعناية اليوم؟ ✨'
                                        : 'What can we wash & steam-press for you today? ✨',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '3-Hr Express',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Quick Friendly Service Category Selectors
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickServicePill(
                                '👔 Steam Press',
                                () => setState(
                                  () => _selectedCategory =
                                      'Ironing & Steam Press',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickServicePill(
                                '🧺 Wash by KG',
                                () => setState(
                                  () =>
                                      _selectedCategory = 'Wash by Weight (KG)',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickServicePill(
                                '✨ Traditional Thobes',
                                () => setState(
                                  () => _selectedCategory = 'Traditional Wear',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickServicePill(
                                '🧼 Dry Clean Suits',
                                () => setState(
                                  () => _selectedCategory = 'Dry Clean Suits',
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildQuickServicePill(
                                '🏠 Bedding & Home',
                                () => setState(
                                  () => _selectedCategory = 'Bedding & Home',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Friendly 3-Step "How it works" Guide
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStepItem(
                            '1️⃣',
                            isAr ? 'اختر ملابسك' : 'Pick Clothes',
                            isAr ? 'من القائمة' : 'Add to basket',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Colors.grey,
                            ),
                          ),
                          _buildStepItem(
                            '2️⃣',
                            isAr ? 'استلام السائق' : 'Driver Pickup',
                            isAr ? 'عند بابك' : 'At your door',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: Colors.grey,
                            ),
                          ),
                          _buildStepItem(
                            '3️⃣',
                            isAr ? 'تصلك معطرة' : 'Fresh Delivery',
                            isAr ? 'مكوية كالجديدة' : 'Clean & crisp',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText:
                          'Search Kandura, Abaya, Suit, Bedding, Shirts...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // Category Tabs Bar
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: CatalogData.categories.length,
                    itemBuilder: (context, index) {
                      final cat = CatalogData.categories[index];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                          ),
                          onSelected: (val) {
                            setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Garment Catalog Grid (WHOLE CARD IS CLICKABLE!)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = filteredItems[index];

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => _openItemDetailSheet(context, state, item),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceMuted,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(15),
                                            ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item.icon,
                                          style: const TextStyle(fontSize: 42),
                                        ),
                                      ),
                                    ),
                                    // Badges: Sale %, By KG
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (item.pricingUnit ==
                                              PricingUnit.kg)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.accent,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'BY KG',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            )
                                          else
                                            const SizedBox(),
                                          if (item.isOnSale)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${item.saleDiscountPercent.toStringAsFixed(0)}% OFF',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (item.hasSpecialOffer)
                                      Positioned(
                                        bottom: 6,
                                        left: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFFDE68A),
                                            ),
                                          ),
                                          child: Text(
                                            '🏷️ ${item.specialOfferTag}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF92400E),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.currentLanguage == AppLanguage.ar &&
                                              item.categoryAr.isNotEmpty
                                          ? item.categoryAr
                                          : item.category.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.itemName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    if (item.itemNameAr.isNotEmpty) ...[
                                      const SizedBox(height: 1),
                                      Text(
                                        item.itemNameAr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (item.isOnSale) ...[
                                                  Text(
                                                    state.formatCurrency(
                                                      item.basePriceQar,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${state.formatCurrency(item.effectivePriceQar)} ${item.pricingUnit.shortLabel}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color:
                                                          AppColors.primaryDark,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  Text(
                                                    '${state.formatCurrency(item.basePriceQar)} ${item.pricingUnit.shortLabel}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: AppColors.textDark,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(
                                                Icons.add,
                                                size: 13,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                'Add',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: filteredItems.length),
                ),
              ),
            ],
          ),

          // Floating Basket Button
          if (state.cart.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CartSheet(
                      onOrderPlaced: () {
                        final newOrder = state.currentCustomerActiveOrder;
                        if (newOrder != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderStepperScreen(order: newOrder),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${state.cart.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isAr
                                ? 'عرض السلة (${state.cart.length})'
                                : 'View Basket (${state.cart.length} items)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            state.formatCurrency(state.cartTotal),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leadingWidth: 46,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Center(
            child: UniWashLogo.badge(
              size: 34,
              onTap: () => setState(() => _currentTabIndex = 2),
            ),
          ),
        ),
        titleSpacing: 8,
        title: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => AddressPickerSheet(
                currentAddress: state.selectedAddress,
                onSaved: (addr) => state.updateAddress(addr),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Flexible(
                    child: Text(
                      'Deliver to',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      state.selectedAddress.city,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Country / Currency Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButton<String>(
              value: state.selectedCountry.code,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, size: 14),
              isDense: true,
              onChanged: (code) {
                if (code != null) state.setSelectedCountry(code);
              },
              items: LocalizationService.countries.values.map((c) {
                return DropdownMenuItem<String>(
                  value: c.code,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.flag, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 3),
                      Text(
                        c.currencyCode,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 2),
          // Language Switcher
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(28, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => state.toggleLanguage(),
            child: Text(
              state.currentLanguage == AppLanguage.ar ? 'EN' : 'عربي',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: AppColors.primary,
              ),
            ),
          ),
          // Profile Avatar Quick Jump
          InkWell(
            onTap: () => setState(() => _currentTabIndex = 2),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
              child: Text(
                state.currentUser.fullName.isNotEmpty
                    ? state.currentUser.fullName[0].toUpperCase()
                    : 'C',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
          // Right padding so top-right floating portal switcher never overlaps actions
          const SizedBox(width: 68),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer_outlined),
            activeIcon: Icon(Icons.local_offer),
            label: 'Offers & Ads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Displays a single, clean, prominent promotional banner on the customer home screen
  /// ONLY when an offer or National Day promotion is actively enabled by the Admin.
  /// If the admin has not enabled any offer, this returns [SizedBox.shrink] so the screen remains 100% clean.
  Widget _buildAdminActiveOfferBanner(
    BuildContext context,
    StateService state,
    bool isAr,
  ) {
    final activeOffers = state.activeEventOffers;
    if (activeOffers.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final offer = activeOffers.first;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: InkWell(
          onTap: () => _showOfferDetailDialog(context, offer, isAr),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  offer.bannerColor,
                  offer.bannerColor.withValues(alpha: 0.82),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: offer.bannerColor.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    offer.iconEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              offer.eventType == 'national_day'
                                  ? (isAr
                                        ? 'عروض اليوم الوطني'
                                        : 'NATIONAL DAY SPECIAL')
                                  : (isAr ? 'عرض إداري خاص' : 'OFFICIAL OFFER'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF08A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${offer.discountPercent.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                color: Color(0xFF854D0E),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAr && offer.titleAr.isNotEmpty
                            ? offer.titleAr
                            : offer.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAr && offer.descriptionAr.isNotEmpty
                            ? offer.descriptionAr
                            : offer.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAr ? 'استفد الآن' : 'Claim >',
                    style: TextStyle(
                      color: offer.bannerColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickServicePill(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem(String emoji, String title, String subtitle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}
