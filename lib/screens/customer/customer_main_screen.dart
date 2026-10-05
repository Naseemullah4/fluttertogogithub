import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/advertisement.dart';
import '../../models/event_offer.dart';
import 'customer_offer_popup_dialog.dart';
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
  int _currentTabIndex = 0; // 0: Services / Catalog, 1: Offers & Ads, 2: Profile
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Slow 5-second Ad Slider state (5 sec per ad, slow smooth transition)
  late final PageController _adPageController;
  Timer? _adCarouselTimer;
  int _currentAdSlide = 0;
  bool _popupChecked = false;

  @override
  void initState() {
    super.initState();
    _adPageController = PageController(viewportFraction: 0.92);
    _startAdAutoSlider();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPopupOffer();
    });
  }

  void _startAdAutoSlider() {
    _adCarouselTimer?.cancel();
    _adCarouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_adPageController.hasClients) return;
      final state = Provider.of<StateService>(context, listen: false);
      final total = state.activeAdvertisements.length + state.activeEventOffers.length;
      if (total <= 1) return;
      final next = (_currentAdSlide + 1) % total;
      _adPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 900), // Slow, smooth sliding transition!
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _checkAndShowPopupOffer() {
    if (!mounted || _popupChecked) return;
    _popupChecked = true;
    final state = Provider.of<StateService>(context, listen: false);
    final popup = state.activePopupOffer;
    if (popup != null && popup.isActive && !state.hasDismissedPopupInSession(popup.id)) {
      CustomerOfferPopupDialog.show(
        context,
        offer: popup,
        onClaim: () {
          setState(() => _currentTabIndex = 0);
        },
      );
    }
  }

  @override
  void dispose() {
    _adCarouselTimer?.cancel();
    _adPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final activeOrder = state.currentCustomerActiveOrder;
    final theme = state.currentOccasionTheme;
    final isAr = state.currentLanguage == AppLanguage.ar;
    final latestBroadcast = state.latestBroadcastAnnouncement;

    final filteredItems = state.catalogItems.where((item) {
      final q = _searchQuery.toLowerCase();
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch = item.itemName.toLowerCase().contains(q) ||
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
              // Dynamic Occasion Theme Festive Ribbon
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryDarkColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(theme.iconEmoji, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isAr ? theme.greetingBannerAr : theme.greetingBanner,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${state.selectedCountry.flag} ${theme.name.split(' ')[0]}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),

              // Promotional Broadcast Announcement Banner (from Admin / Super Admin)
              if (latestBroadcast != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.amber.shade400, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.campaign, color: Color(0xFFB45309), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 2,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'PROMO BROADCAST',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF78350F)),
                                    ),
                                  ),
                                  Text(
                                    isAr && latestBroadcast.titleAr.isNotEmpty ? latestBroadcast.titleAr : latestBroadcast.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF78350F)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isAr && latestBroadcast.messageAr.isNotEmpty ? latestBroadcast.messageAr : latestBroadcast.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _currentTabIndex = 1),
                          child: const Text('View All >', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFB45309))),
                        ),
                      ],
                    ),
                  ),
                ),

              // Active Order Alert Bar if exists
              if (activeOrder != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: activeOrder.status.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: activeOrder.status.color.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Icon(activeOrder.status.icon, color: activeOrder.status.color, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order #${activeOrder.orderNumber} • ${activeOrder.status.displayName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: activeOrder.status.color,
                                ),
                              ),
                              const Text(
                                'Tap to view live order progress and driver location',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderStepperScreen(order: activeOrder),
                              ),
                            );
                          },
                          child: const Text('Track', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ),

              // Customer Popup Floating Quick Banner (if active popup exists)
              if (state.activePopupOffer != null && state.activePopupOffer!.isActive)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: InkWell(
                      onTap: () {
                        CustomerOfferPopupDialog.show(
                          context,
                          offer: state.activePopupOffer!,
                          onClaim: () => setState(() => _currentTabIndex = 0),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              state.activePopupOffer!.primaryColor.withValues(alpha: 0.12),
                              state.activePopupOffer!.primaryColor.withValues(alpha: 0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: state.activePopupOffer!.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: state.activePopupOffer!.primaryColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.flash_on, size: 14, color: AppColors.primary),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isAr && state.activePopupOffer!.titleAr.isNotEmpty
                                    ? state.activePopupOffer!.titleAr
                                    : state.activePopupOffer!.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: state.activePopupOffer!.primaryColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: state.activePopupOffer!.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isAr ? 'عرض الإعلان' : 'View Offer',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.chevron_right, size: 12, color: Colors.white),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Dynamic Ads & Event Offers Banners Carousel (5-second slow smooth auto-slide)
              SliverToBoxAdapter(
                child: Builder(
                  builder: (context) {
                    final ads = state.activeAdvertisements;
                    final offers = state.activeEventOffers;
                    final List<dynamic> allSlides = [...ads, ...offers];
                    if (allSlides.isEmpty) return const SizedBox.shrink();

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 168,
                          child: PageView.builder(
                            itemCount: allSlides.length,
                            controller: _adPageController,
                            onPageChanged: (idx) {
                              setState(() => _currentAdSlide = idx);
                              _startAdAutoSlider(); // smoothly reset 5s timer after manual touch
                            },
                            itemBuilder: (context, index) {
                              final item = allSlides[index];
                              if (item is Advertisement) {
                                return _buildAdSlideCard(context, state, item, isAr);
                              } else if (item is EventOffer) {
                                return _buildEventOfferSlideCard(context, state, item, isAr);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Sleek Animated Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(allSlides.length, (i) {
                            final isSel = i == (_currentAdSlide % allSlides.length);
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              height: 4,
                              width: isSel ? 22 : 6,
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primary : AppColors.primary.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                      ],
                    );
                  },
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search Kandura, Abaya, Suit, Bedding, Shirts...',
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textDark,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

              // Garment Catalog Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                    ),
                                    child: Center(
                                      child: Text(item.icon, style: const TextStyle(fontSize: 42)),
                                    ),
                                  ),
                                  // Badges: Sale %, By KG, Special Offer
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    right: 8,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (item.pricingUnit == PricingUnit.kg)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.accent,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'BY KG',
                                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                            ),
                                          )
                                        else
                                          const SizedBox(),
                                        if (item.isOnSale)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.error,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${item.saleDiscountPercent.toStringAsFixed(0)}% OFF',
                                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFFDE68A)),
                                        ),
                                        child: Text(
                                          '🏷️ ${item.specialOfferTag}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
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
                                    state.currentLanguage == AppLanguage.ar && item.categoryAr.isNotEmpty ? item.categoryAr : item.category.toUpperCase(),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (item.isOnSale) ...[
                                                Text(
                                                  state.formatCurrency(item.basePriceQar),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                Text(
                                                  '${state.formatCurrency(item.effectivePriceQar)} ${item.pricingUnit.shortLabel}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primaryDark,
                                                  ),
                                                ),
                                              ] else ...[
                                                Text(
                                                  '${state.formatCurrency(item.basePriceQar)} ${item.pricingUnit.shortLabel}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.textDark,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) => ItemDetailSheet(
                                              item: item,
                                              onAdd: (serviceType, qtyOrWeight, notes) {
                                                state.addToCart(item, serviceType, quantityOrWeight: qtyOrWeight, notes: notes);
                                                final qtyLabel = item.pricingUnit == PricingUnit.kg ? '${qtyOrWeight.toStringAsFixed(1)} KG' : '${qtyOrWeight.round()} Pcs';
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('🧺 Added $qtyLabel of ${item.itemName} (${serviceType.displayName}) to basket'),
                                                    duration: const Duration(milliseconds: 1500),
                                                    backgroundColor: AppColors.primary,
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: const [
                                              Icon(Icons.add, size: 13, color: Colors.white),
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
                    childCount: filteredItems.length,
                  ),
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
                              builder: (_) => OrderStepperScreen(order: newOrder),
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${state.cart.length}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'View Basket',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      ),
                      Text(
                        '${state.cartTotal.toStringAsFixed(2)} QAR >',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
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
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.textMuted),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 13, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      state.selectedAddress.city,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
                      Text(c.currencyCode, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10)),
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
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary),
            ),
          ),
          // Profile Avatar Quick Jump
          InkWell(
            onTap: () => setState(() => _currentTabIndex = 2),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
              child: Text(
                state.currentUser.fullName.isNotEmpty ? state.currentUser.fullName[0].toUpperCase() : 'C',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
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

  Widget _buildAdSlideCard(BuildContext context, StateService state, Advertisement ad, bool isAr) {
    return InkWell(
      onTap: () {
        if (ad.ctaLink == 'express') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🚚 Express VIP Pickup activated for ${ad.countryFlag}!'),
              backgroundColor: ad.primaryColor,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ Promo "${ad.title}" selected! Enjoy premium care.'),
              backgroundColor: ad.primaryColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ad.primaryColor, ad.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ad.primaryColor.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${ad.countryFlag} OFFICIAL PROMO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ad.ctaText,
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr && ad.titleAr.isNotEmpty ? ad.titleAr : ad.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isAr && ad.messageAr.isNotEmpty ? ad.messageAr : ad.message,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                ad.graphicEmoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventOfferSlideCard(BuildContext context, StateService state, EventOffer offer, bool isAr) {
    final color = offer.bannerColor;
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: offer.promoCode));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(offer.iconEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '🎉 Promo Code "${offer.promoCode}" copied! ${offer.discountPercent.toStringAsFixed(0)}% OFF',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: color,
            duration: const Duration(seconds: 3),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.82)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${offer.countryFlag} ${offer.discountPercent.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          offer.promoCode,
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr ? offer.titleAr : offer.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isAr ? offer.descriptionAr : offer.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                offer.iconEmoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
