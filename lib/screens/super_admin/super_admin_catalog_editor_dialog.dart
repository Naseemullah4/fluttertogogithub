import 'package:flutter/material.dart';
import '../../models/catalog_item.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class SuperAdminCatalogEditorDialog extends StatefulWidget {
  final CatalogItem item;
  final Function(CatalogItem updatedItem) onSave;

  const SuperAdminCatalogEditorDialog({
    super.key,
    required this.item,
    required this.onSave,
  });

  @override
  State<SuperAdminCatalogEditorDialog> createState() => _SuperAdminCatalogEditorDialogState();
}

class _SuperAdminCatalogEditorDialogState extends State<SuperAdminCatalogEditorDialog> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _discountController;
  late TextEditingController _offerTagController;
  late TextEditingController _descController;
  late PricingUnit _pricingUnit;
  late String _selectedIcon;
  late double _currentPrice;
  late double _discountPercent;
  late TextEditingController _customIconController;
  String _selectedIconCategory = '👕 Tops & Daily';

  final Map<String, List<String>> _categorizedIcons = {
    '👕 Tops & Daily': ['👕', '👔', '👚', '🧶', '🦺', '🥋', '🥼', '🎽', '🩱', '👘'],
    '👖 Pants & Casual': ['👖', '🩳', '🩲', '👙', '🩴', '🧦', '👗', '💃', '🕺'],
    '🧕 Traditional': ['🧕', '👑', '🕌', '👳', '🥻', '🧣', '🕋', '🪔', '⚜️', '🪙'],
    '🤵 Formal & Outerwear': ['🤵', '🧥', '🎩', '💼', '🧤', '🌂', '🎓', '🎖️', '👔'],
    '🛏️ Bedding & Home': ['🛏️', '🛌', '🛋️', '🪟', '🧺', '🧵', '🧶', '📦', '🧴'],
    '🛁 Bath & Towels': ['🛁', '🧖', '🧖‍♂️', '🏖️', '💆', '🧼', '🚿', '🧽'],
    '👟 Footwear & Bags': ['👞', '👟', '👠', '👡', '👢', '👜', '👛', '🎒', '🧳'],
    '✨ Care & Express': ['🧺', '🫧', '💧', '✨', '🏷️', '⚡', '🌟', '⏱️', '📦'],
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.itemName);
    _currentPrice = widget.item.basePriceQar;
    _priceController = TextEditingController(text: _currentPrice.toStringAsFixed(0));
    _discountPercent = widget.item.saleDiscountPercent;
    _discountController = TextEditingController(text: _discountPercent.toStringAsFixed(0));
    _offerTagController = TextEditingController(text: widget.item.specialOfferTag ?? '');
    _descController = TextEditingController(text: widget.item.description);
    _pricingUnit = widget.item.pricingUnit;
    _selectedIcon = widget.item.icon;
    _customIconController = TextEditingController(text: widget.item.icon);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _offerTagController.dispose();
    _descController.dispose();
    _customIconController.dispose();
    super.dispose();
  }

  double get _effectivePrice {
    if (_discountPercent <= 0) return _currentPrice;
    final discounted = _currentPrice * (1.0 - (_discountPercent / 100.0));
    return (discounted * 10).roundToDouble() / 10;
  }

  void _adjustPrice(double delta) {
    setState(() {
      _currentPrice = (_currentPrice + delta).clamp(1.0, 9999.0);
      _priceController.text = _currentPrice.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const UniWashLogo.badge(size: 32),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_selectedIcon, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Super Admin Pricing & Offer Manager',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          Text(
                            'Category: ${widget.item.category} • ID: ${widget.item.id}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 24),

              // Item Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Garment / Item Name *'),
              ),
              const SizedBox(height: 16),

              // Pricing Unit Selector (Per Item vs Per KG)
              const Text('Pricing Mode (Per Item or By Weight / KG)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _pricingUnit = PricingUnit.piece),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _pricingUnit == PricingUnit.piece ? AppColors.primary.withValues(alpha: 0.12) : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _pricingUnit == PricingUnit.piece ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.checkroom, size: 18, color: _pricingUnit == PricingUnit.piece ? AppColors.primary : AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              'Per Piece / Item (Pcs)',
                              style: TextStyle(
                                fontWeight: _pricingUnit == PricingUnit.piece ? FontWeight.w700 : FontWeight.w500,
                                color: _pricingUnit == PricingUnit.piece ? AppColors.primaryDark : AppColors.textDark,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _pricingUnit = PricingUnit.kg),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _pricingUnit == PricingUnit.kg ? AppColors.accent.withValues(alpha: 0.12) : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _pricingUnit == PricingUnit.kg ? AppColors.accent : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.scale, size: 18, color: _pricingUnit == PricingUnit.kg ? AppColors.accent : AppColors.textMuted),
                            const SizedBox(width: 8),
                            Text(
                              'Per KG (By Weight)',
                              style: TextStyle(
                                fontWeight: _pricingUnit == PricingUnit.kg ? FontWeight.w700 : FontWeight.w500,
                                color: _pricingUnit == PricingUnit.kg ? AppColors.accent : AppColors.textDark,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price Adjust Up & Down
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Base Price (QAR)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(
                    'Unit: ${_pricingUnit.shortLabel}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => _adjustPrice(-5),
                    icon: const Text('-5', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    tooltip: 'Decrease 5 QAR',
                  ),
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    onPressed: () => _adjustPrice(-1),
                    icon: const Icon(Icons.remove, size: 18),
                    tooltip: 'Decrease 1 QAR',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                        suffixText: 'QAR',
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val);
                        if (parsed != null && parsed > 0) {
                          setState(() => _currentPrice = parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _adjustPrice(1),
                    icon: const Icon(Icons.add, size: 18),
                    tooltip: 'Increase 1 QAR',
                  ),
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    onPressed: () => _adjustPrice(5),
                    icon: const Text('+5', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                    tooltip: 'Increase 5 QAR',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sale On Price (Discount %)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sale Discount on Price', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(
                    _discountPercent > 0 ? '${_discountPercent.toStringAsFixed(0)}% OFF (ON SALE)' : 'No Sale Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _discountPercent > 0 ? AppColors.error : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ...[0, 10, 20, 30, 50].map((pct) {
                    final isSel = _discountPercent == pct;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('$pct%'),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _discountPercent = pct.toDouble();
                              _discountController.text = '$pct';
                            });
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),

              // Special Offer Text / Badge
              TextField(
                controller: _offerTagController,
                decoration: const InputDecoration(
                  labelText: 'Special Offer Tag (Visible on Customer App)',
                  hintText: 'e.g. HOT DEAL, RAMADAN 50% OFF, WEEKEND SPECIAL...',
                  prefixIcon: Icon(Icons.local_offer_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 14),

              // Customer App Live Preview Pill
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility, color: Color(0xFFB45309), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Customer App Display Preview:',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF92400E)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '$_selectedIcon ${_nameController.text.isEmpty ? widget.item.itemName : _nameController.text} • ',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              if (_discountPercent > 0) ...[
                                Text(
                                  '${_currentPrice.toStringAsFixed(0)} QAR',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_effectivePrice.toStringAsFixed(0)} QAR ${_pricingUnit.shortLabel}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDark),
                                ),
                              ] else ...[
                                Text(
                                  '${_currentPrice.toStringAsFixed(0)} QAR ${_pricingUnit.shortLabel}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDark),
                                ),
                              ],
                              if (_offerTagController.text.trim().isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _offerTagController.text.trim(),
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Icon Picker & Custom Upload
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Garment / Service Icon (Proper Icon per Item)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      _showUploadCustomIconDialog(context);
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text('Upload / Custom Icon', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category Selector for Icons
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _categorizedIcons.keys.map((catKey) {
                    final isSel = catKey == _selectedIconCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(catKey, style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500)),
                        selected: isSel,
                        visualDensity: VisualDensity.compact,
                        onSelected: (val) {
                          if (val) setState(() => _selectedIconCategory = catKey);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),

              // Icons in the selected category
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: (_categorizedIcons[_selectedIconCategory] ?? []).length,
                  itemBuilder: (ctx, i) {
                    final ic = _categorizedIcons[_selectedIconCategory]![i];
                    final isSel = ic == _selectedIcon;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIcon = ic;
                          _customIconController.text = ic;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: isSel ? 2 : 1),
                        ),
                        child: Text(ic, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Quick Custom Icon / Emoji typing field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customIconController,
                      decoration: const InputDecoration(
                        labelText: 'Or Type / Paste Custom Icon or Emoji',
                        hintText: 'e.g. 🧕, 👑, 👘, 🧼, 👔, 🪡...',
                        prefixIcon: Icon(Icons.edit_note, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() => _selectedIcon = val.trim());
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary),
                    ),
                    alignment: Alignment.center,
                    child: Text(_selectedIcon, style: const TextStyle(fontSize: 22)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save Action
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final updated = widget.item.copyWith(
                      itemName: _nameController.text.trim().isEmpty ? widget.item.itemName : _nameController.text.trim(),
                      basePriceQar: _currentPrice,
                      pricingUnit: _pricingUnit,
                      saleDiscountPercent: _discountPercent,
                      specialOfferTag: _offerTagController.text.trim().isEmpty ? null : _offerTagController.text.trim(),
                      icon: _selectedIcon,
                    );
                    widget.onSave(updated);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Save & Apply Live to Customer App', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadCustomIconDialog(BuildContext context) {
    final uploadTextController = TextEditingController(text: _selectedIcon);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Upload Custom Icon / Asset', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload a custom icon file from your device, or paste a custom emoji, SVG symbol, or image badge to ensure every garment has its proper distinguished icon.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),

              // File Upload Simulation Button
              InkWell(
                onTap: () {
                  // Simulate file picker choice
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📁 File picked: custom_item_icon.svg (128x128 High-Res Vector)'),
                      backgroundColor: AppColors.primaryDark,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), style: BorderStyle.solid),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.file_upload_outlined, color: AppColors.primary, size: 36),
                      SizedBox(height: 8),
                      Text(
                        'Click to Browse & Upload Icon File (SVG, PNG, WebP)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryDark),
                      ),
                      Text(
                        'Supports vector & high-definition laundry badges up to 5MB',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Or Select from Specialized Proper Badges:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '🧕 Kandura/Thobe',
                  '👘 Delicate Abaya',
                  '👑 Golden Bisht',
                  '👔 Corporate Oxford',
                  '🥼 Hospital Scrubs',
                  '🪔 Arabic Oud Perfumed',
                  '🧵 Tailoring Repair',
                  '🧺 10kg Bulk Basket',
                  '💎 Luxury Silk',
                ].map((badge) {
                  final iconPart = badge.split(' ').first;
                  return ActionChip(
                    avatar: Text(iconPart, style: const TextStyle(fontSize: 14)),
                    label: Text(badge.replaceFirst(iconPart, '').trim(), style: const TextStyle(fontSize: 11)),
                    onPressed: () {
                      uploadTextController.text = iconPart;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: uploadTextController,
                decoration: const InputDecoration(
                  labelText: 'Custom Icon / Character / Symbol',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.palette_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final chosen = uploadTextController.text.trim();
              if (chosen.isNotEmpty) {
                setState(() {
                  _selectedIcon = chosen;
                  _customIconController.text = chosen;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Apply Icon'),
          ),
        ],
      ),
    );
  }
}
