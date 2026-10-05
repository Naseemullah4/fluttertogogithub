import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/state_service.dart';
import '../theme/app_colors.dart';
import '../screens/common/order_detail_dialog.dart';
import '../screens/laundry/laundry_thermal_invoice_dialog.dart';

class SuperSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onQueryChanged;
  final ValueChanged<LaundryOrder>? onOrderSelected;
  final double maxWidth;

  const SuperSearchBar({
    super.key,
    this.hintText = 'Google-like Super Search: Type order #, customer name, mobile, driver...',
    this.onQueryChanged,
    this.onOrderSelected,
    this.maxWidth = 640,
  });

  @override
  State<SuperSearchBar> createState() => _SuperSearchBarState();
}

class _SuperSearchBarState extends State<SuperSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<LaundryOrder> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.trim().isNotEmpty) {
      _showOverlay();
    } else if (!_focusNode.hasFocus) {
      // Delay closing so clicks on overlay buttons work
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
        }
      });
    }
  }

  void _onSearchChanged() {
    final query = _controller.text.trim();
    widget.onQueryChanged?.call(query);

    final state = Provider.of<StateService>(context, listen: false);
    if (query.isNotEmpty) {
      setState(() {
        _suggestions = state.searchOrders(query).take(6).toList();
      });
      _showOverlay();
    } else {
      setState(() {
        _suggestions = [];
      });
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final screenSize = MediaQuery.of(context).size;
    final globalPos = renderBox.localToGlobal(Offset.zero);

    // Ample width for desktop web search dropdown (540px) or fit mobile/tablet screen
    final double dropdownWidth = math.min(540.0, math.max(renderBox.size.width, screenSize.width - 24));

    // If expanding towards the right exceeds screen boundary, align with the right edge of search bar
    final bool alignToRightEdge = (globalPos.dx + dropdownWidth > screenSize.width - 16);

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: dropdownWidth,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: alignToRightEdge ? Alignment.bottomRight : Alignment.bottomLeft,
          followerAnchor: alignToRightEdge ? Alignment.topRight : Alignment.topLeft,
          offset: const Offset(0, 6),
          child: Material(
            elevation: 16,
            shadowColor: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 440),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _buildSuggestionsList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionsList() {
    final state = Provider.of<StateService>(context, listen: false);
    final dateFormat = DateFormat('MMM dd, HH:mm');

    if (_suggestions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.search_off_rounded, color: Colors.black38, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No matching order, customer, or phone for "${_controller.text}"',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'LIVE SEARCH SUGGESTIONS (${_suggestions.length} MATCHES)',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Esc to close', style: TextStyle(fontSize: 10, color: Colors.black38)),
            ],
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            shrinkWrap: true,
            itemCount: _suggestions.length,
            separatorBuilder: (c, i) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final order = _suggestions[index];
              return InkWell(
                onTap: () {
                  _removeOverlay();
                  if (widget.onOrderSelected != null) {
                    widget.onOrderSelected!(order);
                  } else {
                    OrderDetailDialog.show(context, order);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Status Icon
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: order.status.color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(order.status.icon, color: order.status.color, size: 16),
                      ),
                      const SizedBox(width: 10),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Order #, Status Pill, Date
                            Row(
                              children: [
                                Text(
                                  '#${order.orderNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A)),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: order.status.color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      order.status.displayName,
                                      style: TextStyle(color: order.status.color, fontSize: 10, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  dateFormat.format(order.createdAt),
                                  style: const TextStyle(fontSize: 10, color: Colors.black45),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            // Customer & Phone
                            Row(
                              children: [
                                const Icon(Icons.person, size: 12, color: Colors.black45),
                                const SizedBox(width: 3),
                                Flexible(
                                  flex: 2,
                                  child: Text(
                                    order.customerName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.phone, size: 11, color: Colors.black45),
                                const SizedBox(width: 3),
                                Flexible(
                                  flex: 2,
                                  child: Text(
                                    order.customerPhone,
                                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Laundry: ${order.laundryName} • Driver: ${order.assignedDriverName}',
                              style: const TextStyle(fontSize: 10, color: Colors.black45),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Total & Quick Action Buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.formatCurrency(order.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  _removeOverlay();
                                  OrderDetailDialog.show(context, order);
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility_outlined, size: 12, color: Color(0xFF475569)),
                                      SizedBox(width: 3),
                                      Text('View', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              InkWell(
                                onTap: () {
                                  _removeOverlay();
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => LaundryThermalInvoiceDialog(order: order),
                                  );
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.print_outlined, size: 12, color: AppColors.primary),
                                      SizedBox(width: 3),
                                      Text('Print', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        constraints: BoxConstraints(maxWidth: widget.maxWidth),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: _focusNode.hasFocus ? AppColors.primary : const Color(0xFFE2E8F0),
            width: _focusNode.hasFocus ? 1.5 : 1.0,
          ),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.black45),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged();
                    },
                  )
                : Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: const Text('SUPER SEARCH', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF475569))),
                        ),
                      ],
                    ),
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
