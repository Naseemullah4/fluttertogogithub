import 'package:flutter/material.dart';
import '../../models/catalog_item.dart';
import '../../models/order_item.dart';
import '../../theme/app_colors.dart';

class ItemDetailSheet extends StatefulWidget {
  final CatalogItem item;
  final Function(ServiceType serviceType, double quantityOrWeight, String notes) onAdd;

  const ItemDetailSheet({
    super.key,
    required this.item,
    required this.onAdd,
  });

  @override
  State<ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<ItemDetailSheet> {
  ServiceType _selectedService = ServiceType.washIron;
  double _qtyOrWeight = 1.0;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _isKg => widget.item.pricingUnit == PricingUnit.kg;

  double get _currentEffectiveUnitPrice => (widget.item.effectivePriceQar * _selectedService.priceMultiplier).roundToDouble();
  double get _currentOriginalUnitPrice => (widget.item.basePriceQar * _selectedService.priceMultiplier).roundToDouble();
  double get _totalPrice => (_currentEffectiveUnitPrice * _qtyOrWeight).roundToDouble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.item.icon,
                      style: const TextStyle(fontSize: 30),
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
                          Flexible(
                            child: Text(
                              widget.item.itemName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (widget.item.isOnSale) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${widget.item.saleDiscountPercent.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (widget.item.itemNameAr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.item.itemNameAr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${widget.item.category} • ${widget.item.pricingUnit.displayName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isKg ? AppColors.accent : AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (widget.item.hasSpecialOffer) ...[
                        const SizedBox(height: 2),
                        Text(
                          '🏷️ ${widget.item.specialOfferTag}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.item.isOnSale) ...[
                      Text(
                        '${_currentOriginalUnitPrice.toStringAsFixed(0)} QAR',
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                    ],
                    Text(
                      '${_currentEffectiveUnitPrice.toStringAsFixed(0)} QAR',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      widget.item.pricingUnit.shortLabel,
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.item.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                widget.item.description,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
            const SizedBox(height: 20),

            // Service Treatments
            const Text(
              'Select Service Treatment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ServiceType.values.map((type) {
                final isSelected = _selectedService == type;
                final price = (widget.item.effectivePriceQar * type.priceMultiplier).roundToDouble();
                return ChoiceChip(
                  label: Text('${type.displayName} (${price.toStringAsFixed(0)} QAR ${widget.item.pricingUnit.shortLabel})'),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedService = type);
                  },
                  selectedColor: AppColors.primaryLight.withValues(alpha: 0.2),
                  backgroundColor: AppColors.surfaceMuted,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryDark : AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Quantity or Weight Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isKg ? 'Weight (Kilograms - KG)' : 'Garment Quantity (Pieces)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _qtyOrWeight > (_isKg ? 0.5 : 1.0)
                            ? () {
                                setState(() {
                                  _qtyOrWeight = (_qtyOrWeight - (_isKg ? 0.5 : 1.0));
                                  if (_isKg) _qtyOrWeight = (_qtyOrWeight * 10).round() / 10;
                                });
                              }
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          _isKg ? '${_qtyOrWeight.toStringAsFixed(1)} KG' : '${_qtyOrWeight.round()} Pcs',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () {
                          setState(() {
                            _qtyOrWeight = (_qtyOrWeight + (_isKg ? 0.5 : 1.0));
                            if (_isKg) _qtyOrWeight = (_qtyOrWeight * 10).round() / 10;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isKg) ...[
              const SizedBox(height: 10),
              Row(
                children: [0.5, 1.0, 2.0, 3.0, 5.0, 10.0].map((kg) {
                  final isSel = (_qtyOrWeight - kg).abs() < 0.05;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('${kg.toStringAsFixed(kg % 1 == 0 ? 0 : 1)} KG', style: const TextStyle(fontSize: 11)),
                      selected: isSel,
                      onSelected: (val) {
                        if (val) setState(() => _qtyOrWeight = kg);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),

            // Special Garment Care Instructions
            const Text(
              'Special Garment Care Instructions (Optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'e.g. Mild starch, stain removal, delicate hanger...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onAdd(_selectedService, _qtyOrWeight, _notesController.text.trim());
                  Navigator.pop(context);
                },
                child: Text(
                  'Add to Basket • ${_totalPrice.toStringAsFixed(0)} QAR',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
