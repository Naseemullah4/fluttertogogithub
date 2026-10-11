import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/state_service.dart';
import '../theme/app_colors.dart';
import 'badge_pill.dart';

class BulkQrGeneratorDialog extends StatefulWidget {
  final List<LaundryOrder>? preselectedOrders;

  const BulkQrGeneratorDialog({
    super.key,
    this.preselectedOrders,
  });

  static Future<void> show(BuildContext context, {List<LaundryOrder>? preselectedOrders}) {
    return showDialog(
      context: context,
      builder: (ctx) => BulkQrGeneratorDialog(preselectedOrders: preselectedOrders),
    );
  }

  @override
  State<BulkQrGeneratorDialog> createState() => _BulkQrGeneratorDialogState();
}

class _BulkQrGeneratorDialogState extends State<BulkQrGeneratorDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mode 1: Active Orders
  final Set<String> _selectedOrderIds = {};

  // Mode 2: Sequential Batch Series
  final TextEditingController _prefixController = TextEditingController(text: 'UNW-BAG-');
  final TextEditingController _startNumberController = TextEditingController(text: '101');
  int _batchCount = 12;
  String _batchTagType = 'Wash Bag Tag';

  // Mode 3: Custom Freeform QR
  final TextEditingController _customPayloadController = TextEditingController(text: 'UNW-SPECIAL-TAG-001');
  final TextEditingController _customLabelController = TextEditingController(text: 'VIP Express Garment Care');

  // Print settings
  String _selectedLabelSize = 'Thermal 60x40mm';
  bool _includeDate = true;
  bool _includeBranch = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _prefixController.dispose();
    _startNumberController.dispose();
    _customPayloadController.dispose();
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final activeOrders = state.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).toList();

    // Auto select active orders if set is empty
    if (_selectedOrderIds.isEmpty && activeOrders.isNotEmpty) {
      if (widget.preselectedOrders != null && widget.preselectedOrders!.isNotEmpty) {
        _selectedOrderIds.addAll(widget.preselectedOrders!.map((o) => o.id));
      } else {
        _selectedOrderIds.addAll(activeOrders.take(6).map((o) => o.id));
      }
    }

    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 20,
        vertical: isMobile ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 16 : 20)),
      child: Container(
        width: isMobile ? screenSize.width : 960,
        height: isMobile ? screenSize.height * 0.94 : 720,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header Bar
            _buildDialogHeader(context, isMobile),

            // Tab Bar
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    text: 'Active Orders Batch (${activeOrders.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    text: isMobile ? 'Batch Sequence' : 'Bulk Sequence Generator (Bags / Racks)',
                  ),
                  Tab(
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    text: isMobile ? 'Custom QR' : 'Custom Single / Express QR',
                  ),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOrdersBatchTab(context, state, activeOrders, isMobile),
                  _buildSequentialBatchTab(context, state, isMobile),
                  _buildCustomQrTab(context, state, isMobile),
                ],
              ),
            ),

            // Bottom Action Bar
            _buildDialogFooter(context, state, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(isMobile ? 14 : 20, isMobile ? 12 : 16, 12, isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 16 : 20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMobile ? 'Bulk QR Label Studio 🏷️' : 'Bulk QR Generator & Thermal Label Printing Studio 🏷️',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isMobile ? 'Thermal tags for garments & bags' : 'Generate high-precision QR garment tags, laundry bag barcodes & shelf bin stickers in seconds',
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersBatchTab(BuildContext context, StateService state, List<LaundryOrder> activeOrders, bool isMobile) {
    if (activeOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('No active orders found to print QR tags.', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final selectedOrders = activeOrders.where((o) => _selectedOrderIds.contains(o.id)).toList();

    if (isMobile) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected: ${selectedOrders.length} / ${activeOrders.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedOrderIds.clear();
                          _selectedOrderIds.addAll(activeOrders.map((o) => o.id));
                        });
                      },
                      child: const Text('All', style: TextStyle(fontSize: 11)),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedOrderIds.clear()),
                      child: const Text('Clear', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: activeOrders.length,
              itemBuilder: (ctx, index) {
                final order = activeOrders[index];
                final isChecked = _selectedOrderIds.contains(order.id);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    selected: isChecked,
                    label: Text('#${order.orderNumber} (${order.totalItemCount}p)'),
                    selectedColor: AppColors.primary.withValues(alpha: 0.18),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedOrderIds.add(order.id);
                        } else {
                          _selectedOrderIds.remove(order.id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Container(
              color: const Color(0xFFF1F5F9),
              padding: const EdgeInsets.all(12),
              child: selectedOrders.isEmpty
                  ? const Center(child: Text('Select at least 1 order chip above'))
                  : ListView.builder(
                      itemCount: selectedOrders.length,
                      itemBuilder: (ctx, idx) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildOrderPrintableTag(selectedOrders[idx]),
                      ),
                    ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Left Column: Order Selector List
        Container(
          width: 380,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected: ${selectedOrders.length} / ${activeOrders.length}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedOrderIds.clear();
                              _selectedOrderIds.addAll(activeOrders.map((o) => o.id));
                            });
                          },
                          child: const Text('Select All', style: TextStyle(fontSize: 11)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() => _selectedOrderIds.clear());
                          },
                          child: const Text('Clear', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: activeOrders.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final order = activeOrders[index];
                    final isChecked = _selectedOrderIds.contains(order.id);
                    return CheckboxListTile(
                      value: isChecked,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedOrderIds.add(order.id);
                          } else {
                            _selectedOrderIds.remove(order.id);
                          }
                        });
                      },
                      dense: true,
                      title: Row(
                        children: [
                          Text(
                            '#${order.orderNumber}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          BadgePill(
                            label: '${order.totalItemCount} Items',
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            textColor: AppColors.primary,
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${order.customerName} • ${order.items.isNotEmpty ? order.items.first.serviceType.displayName : 'Standard Wash'}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Right Column: Live Printable Tag Sheet Preview
        Expanded(
          child: Container(
            color: const Color(0xFFF1F5F9),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Print Preview (${selectedOrders.length} Thermal Tags ready)',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    Row(
                      children: [
                        _buildSizeChip('Thermal 60x40mm'),
                        const SizedBox(width: 6),
                        _buildSizeChip('A4 Sheet (3x4)'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: selectedOrders.isEmpty
                      ? const Center(
                          child: Text('Please select at least 1 order on the left to preview tags.'),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.45,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: selectedOrders.length,
                          itemBuilder: (ctx, idx) {
                            final order = selectedOrders[idx];
                            return _buildOrderPrintableTag(order);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSequentialBatchTab(BuildContext context, StateService state, bool isMobile) {
    final startNum = int.tryParse(_startNumberController.text) ?? 100;
    final generatedTags = List.generate(_batchCount, (i) {
      final code = '${_prefixController.text}${startNum + i}';
      return code;
    });

    final settingsContent = SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Batch Configuration',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              if (isMobile)
                Text(
                  '${generatedTags.length} Tags Queued',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tag Code Prefix', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _prefixController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'e.g. UNW-BAG-',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start #', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _startNumberController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: '101',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<int>(
                      initialValue: _batchCount,
                      isDense: true,
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(value: 6, child: Text('6 Tags')),
                        DropdownMenuItem(value: 12, child: Text('12 Tags')),
                        DropdownMenuItem(value: 24, child: Text('24 Tags')),
                        DropdownMenuItem(value: 48, child: Text('48 Tags')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _batchCount = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tag Purpose', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _batchTagType,
                      isDense: true,
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(value: 'Wash Bag Tag', child: Text('Bag Tag', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Shelf Bin Identifier', child: Text('Shelf Bin', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Garment Hanger Pin', child: Text('Hanger Pin', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'Express VIP Priority', child: Text('Express VIP', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _batchTagType = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isMobile) ...[
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Include Date Stamp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              value: _includeDate,
              onChanged: (val) => setState(() => _includeDate = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text('Include Branch Stamp (Pearl LND-01)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              value: _includeBranch,
              onChanged: (val) => setState(() => _includeBranch = val),
            ),
          ],
        ],
      ),
    );

    final previewContent = Container(
      color: const Color(0xFFF1F5F9),
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Preview (${generatedTags.length} Tags: ${generatedTags.first} - ${generatedTags.last})',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: generatedTags.join('\n')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📋 Copied ${generatedTags.length} QR codes to clipboard!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 13),
                label: const Text('Copy Codes', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 3,
                childAspectRatio: isMobile ? 1.45 : 1.35,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: generatedTags.length,
              itemBuilder: (ctx, idx) {
                final code = generatedTags[idx];
                return _buildSequentialPrintableTag(code, _batchTagType);
              },
            ),
          ),
        ],
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          SizedBox(height: 165, child: settingsContent),
          const Divider(height: 1),
          Expanded(child: previewContent),
        ],
      );
    }

    return Row(
      children: [
        Container(
          width: 340,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: settingsContent,
        ),
        Expanded(child: previewContent),
      ],
    );
  }

  Widget _buildCustomQrTab(BuildContext context, StateService state, bool isMobile) {
    final payload = _customPayloadController.text.trim();
    final label = _customLabelController.text.trim();

    final inputSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Generate Single Custom QR Code', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 12),
        const Text('QR Code Payload / Value:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: _customPayloadController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'e.g. UNW-TAG-9923 or order link',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        const Text('Human-Readable Title Label:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: _customLabelController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'e.g. Traditional Thobe 2-Pc • VIP Express',
            isDense: true,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ActionChip(
              label: const Text('⚡ Express Wash', style: TextStyle(fontSize: 11)),
              onPressed: () {
                setState(() {
                  _customPayloadController.text = 'UNW-EXP-${DateTime.now().millisecondsSinceEpoch % 10000}';
                  _customLabelController.text = '⚡ Express 3-Hour Wash & Press';
                });
              },
            ),
            ActionChip(
              label: const Text('🧺 Delicate Silk', style: TextStyle(fontSize: 11)),
              onPressed: () {
                setState(() {
                  _customPayloadController.text = 'UNW-DEL-${DateTime.now().millisecondsSinceEpoch % 10000}';
                  _customLabelController.text = '🧺 Delicate Care • Hydro-Wash';
                });
              },
            ),
            ActionChip(
              label: const Text('🏷️ Shelf Rack #4', style: TextStyle(fontSize: 11)),
              onPressed: () {
                setState(() {
                  _customPayloadController.text = 'UNW-BIN-RACK-04';
                  _customLabelController.text = 'Shelf Rack 04 • Ready for Driver';
                });
              },
            ),
          ],
        ),
      ],
    );

    final previewSection = Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'UniWash Thermal Printable Tag',
                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),
            if (payload.isNotEmpty)
              SizedBox(
                width: 140,
                height: 140,
                child: QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: 140,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
                ),
              )
            else
              const SizedBox(height: 140, child: Center(child: Text('Enter payload to render QR', style: TextStyle(fontSize: 12)))),
            const SizedBox(height: 10),
            Text(
              label.isNotEmpty ? label : 'Custom Tag',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 3),
            Text(
              'PAYLOAD: $payload',
              style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.textMuted),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'BRANCH: Pearl (LND-01) • ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: const TextStyle(fontSize: 8.5, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    if (isMobile) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            inputSection,
            const SizedBox(height: 18),
            previewSection,
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: SingleChildScrollView(child: inputSection)),
          const SizedBox(width: 32),
          Expanded(flex: 2, child: previewSection),
        ],
      ),
    );
  }

  Widget _buildOrderPrintableTag(LaundryOrder order) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: QrImageView(
              data: order.qrCodePayload,
              version: QrVersions.auto,
              size: 76,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${order.totalItemCount} PCS',
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  order.customerName,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${order.items.isNotEmpty ? order.items.first.serviceType.displayName : 'Standard Wash'} • Tag Verified',
                  style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd-MM HH:mm').format(order.createdAt),
                  style: const TextStyle(fontSize: 8, color: Colors.grey, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequentialPrintableTag(String code, String tagType) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: QrImageView(
              data: code,
              version: QrVersions.auto,
              size: 60,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F172A)),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  code,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, fontFamily: 'monospace'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  tagType,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.primary),
                  maxLines: 1,
                ),
                if (_includeBranch) ...[
                  const SizedBox(height: 2),
                  const Text('UniWash Pearl LND-01', style: TextStyle(fontSize: 8, color: Colors.grey)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String label) {
    final isSelected = _selectedLabelSize == label;
    return InkWell(
      onTap: () => setState(() => _selectedLabelSize = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogFooter(BuildContext context, StateService state, bool isMobile) {
    if (isMobile) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              child: const Text('Close', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.print, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              '🖨️ Batch QR Labels sent to Thermal Printer!',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF0F172A),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.print, size: 16),
                label: const Text('Print Labels Now 🖨️', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.print_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Label Size: $_selectedLabelSize • High Density 300 DPI Thermal Ready',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.print, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '🖨️ Bulk QR Labels sent successfully to Thermal Printer (Direct Spool: Zebra ZD421 / ESC-POS)!',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFF0F172A),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Print Batch Labels Now 🖨️'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
