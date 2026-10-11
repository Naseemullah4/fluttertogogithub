import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../widgets/badge_pill.dart';
import 'customer_contact_dialog.dart';

class EmergencyProblemSolverDialog extends StatefulWidget {
  final LaundryOrder order;

  const EmergencyProblemSolverDialog({super.key, required this.order});

  static Future<void> show(BuildContext context, LaundryOrder order) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => EmergencyProblemSolverDialog(order: order),
    );
  }

  @override
  State<EmergencyProblemSolverDialog> createState() => _EmergencyProblemSolverDialogState();
}

class _EmergencyProblemSolverDialogState extends State<EmergencyProblemSolverDialog> {
  int _selectedCategoryIndex = 0;

  // Controllers for Address Change
  late TextEditingController _buildingCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _zoneCtrl;
  late TextEditingController _apartmentCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _notesCtrl;

  // Controllers for Wallet Compensation
  double _compensationAmount = 25.0;
  final TextEditingController _compReasonCtrl = TextEditingController(
    text: 'Customer courtesy credit for minor delay / service satisfaction',
  );

  // Controllers for Driver Breakdown Reassign
  String? _selectedNewDriverId;
  final TextEditingController _breakdownReasonCtrl = TextEditingController(
    text: 'Driver vehicle emergency breakdown. Immediate transfer to nearest courier.',
  );

  // Controllers for QR Code
  late TextEditingController _replacementQrCtrl;

  @override
  void initState() {
    super.initState();
    final addr = widget.order.address;
    _buildingCtrl = TextEditingController(text: addr.buildingNo);
    _streetCtrl = TextEditingController(text: addr.streetNo);
    _zoneCtrl = TextEditingController(text: addr.zoneNo);
    _apartmentCtrl = TextEditingController(text: addr.apartmentRoom);
    _cityCtrl = TextEditingController(text: addr.city);
    _notesCtrl = TextEditingController(text: widget.order.deliveryLocationNote ?? '');

    _replacementQrCtrl = TextEditingController(
      text: 'UNI-QR-REP-${widget.order.orderNumber}-${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
  }

  @override
  void dispose() {
    _buildingCtrl.dispose();
    _streetCtrl.dispose();
    _zoneCtrl.dispose();
    _apartmentCtrl.dispose();
    _cityCtrl.dispose();
    _notesCtrl.dispose();
    _compReasonCtrl.dispose();
    _breakdownReasonCtrl.dispose();
    _replacementQrCtrl.dispose();
    super.dispose();
  }

  void _showSuccessBanner(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final order = state.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    final categories = [
      {'title': 'Customer Unreachable', 'icon': Icons.doorbell_rounded, 'desc': 'Doorbell / phone not answered'},
      {'title': 'Address Change / Reroute', 'icon': Icons.edit_location_alt_rounded, 'desc': 'Wrong flat / moved location'},
      {'title': 'Wallet Compensation', 'icon': Icons.wallet_giftcard_rounded, 'desc': 'Instant courtesy credit refund'},
      {'title': 'Driver Breakdown Transfer', 'icon': Icons.car_crash_rounded, 'desc': '1-tap emergency courier switch'},
      {'title': 'VIP Express Upgrade', 'icon': Icons.bolt_rounded, 'desc': 'Fast-track laundry turnaround'},
      {'title': 'Waive Delivery Fee', 'icon': Icons.money_off_rounded, 'desc': 'Refund 15 QAR doorstep fee'},
      {'title': 'Emergency QR Regeneration', 'icon': Icons.qr_code_scanner_rounded, 'desc': 'Fix missing or scuffed QR tag'},
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 760),
        child: Column(
          children: [
            // TOP HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF7F1D1D), // Rich Crimson Header
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.build_circle_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'One-Stop Problem Solver • Order #${order.orderNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 10),
                            BadgePill(
                              label: order.status.displayName,
                              color: Colors.white,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Customer: ${order.customerName} (${order.customerPhone}) • Driver: ${order.assignedDriverName}',
                          style: const TextStyle(color: Color(0xFFFECACA), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // MAIN SPLIT BODY
            Expanded(
              child: Row(
                children: [
                  // SIDEBAR NAVIGATION OF PROBLEM TYPES
                  Container(
                    width: 260,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = index == _selectedCategoryIndex;

                        return Material(
                          color: isSelected ? Colors.white : Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _selectedCategoryIndex = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    color: isSelected ? const Color(0xFFDC2626) : Colors.transparent,
                                    width: 3.5,
                                  ),
                                  bottom: const BorderSide(color: Color(0xFFF1F5F9), width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    cat['icon'] as IconData,
                                    size: 18,
                                    color: isSelected ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat['title'] as String,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF334155),
                                          ),
                                        ),
                                        Text(
                                          cat['desc'] as String,
                                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // RESOLUTION CONTENT WORKSPACE
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(22),
                      child: _buildSelectedResolutionWorkspace(context, state, order),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedResolutionWorkspace(BuildContext context, StateService state, LaundryOrder order) {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildUnreachableCustomerPanel(state, order);
      case 1:
        return _buildAddressChangePanel(state, order);
      case 2:
        return _buildWalletCompensationPanel(state, order);
      case 3:
        return _buildDriverBreakdownPanel(state, order);
      case 4:
        return _buildVipExpressPanel(state, order);
      case 5:
        return _buildWaiveDeliveryFeePanel(state, order);
      case 6:
        return _buildEmergencyQrPanel(state, order);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // PANEL 1: UNREACHABLE CUSTOMER / DOORBELL
  // ==========================================
  Widget _buildUnreachableCustomerPanel(StateService state, LaundryOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.doorbell_rounded,
          title: 'Customer Unreachable at Doorstep / Intercom',
          subtitle: 'Resolve delivery standoff when courier arrives and customer does not respond to doorbell or calls.',
        ),
        const SizedBox(height: 18),

        // Action 1: Trigger 15-Minute Grace Window
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.timer_outlined, color: Color(0xFFD97706), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Step 1: Start 15-Minute Grace Waiting Countdown',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Sends automated intercom alerts via WhatsApp & SMS. Driver is instructed to hold station for 15 minutes before return.',
                style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.notifications_active_rounded, size: 16),
                    label: const Text('Start 15m Grace Countdown & Alert Customer'),
                    onPressed: () {
                      state.triggerDoorbellGraceTimer(order.id);
                      _showSuccessBanner('🔔 15m Grace alert initiated & customer pinged via SMS/WhatsApp.');
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(color: Color(0xFF6EE7B7)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.forum_rounded, size: 16),
                    label: const Text('💬 Live Chat / WhatsApp / Email Customer'),
                    onPressed: () => CustomerContactDialog.show(context, order),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action 2: Safe Doorstep Authorization
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.meeting_room_rounded, color: Color(0xFF16A34A), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Step 2: Authorize Contactless Doorstep Drop-Off',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF14532D)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Customer gave verbal permission by phone to leave garments outside apartment door with photographic proof.',
                style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                label: const Text('Authorize Doorstep Drop-off (Photo Required)'),
                onPressed: () {
                  state.authorizeDoorstepDropoff(order.id);
                  _showSuccessBanner('🚪 Doorstep contactless drop-off authorized for courier.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PANEL 2: ADDRESS CHANGE & REROUTE
  // ==========================================
  Widget _buildAddressChangePanel(StateService state, LaundryOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.edit_location_alt_rounded,
          title: 'Update Delivery Destination & Reroute Courier',
          subtitle: 'Customer changed location, apartment number, or provided wrong drop-off coordinates.',
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _buildingCtrl,
                decoration: const InputDecoration(
                  labelText: 'Building / Tower No. *',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _streetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Street Name & Number *',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _zoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Zone / Area (e.g. Zone 66) *',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _apartmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apartment / Flat / Unit *',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'City (e.g. Doha) *',
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesCtrl,
          decoration: const InputDecoration(
            labelText: 'Gate Code / Intercom Access Instructions',
            isDense: true,
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          icon: const Icon(Icons.navigation_rounded, size: 18),
          label: const Text('Save Address & Alert Courier with Reroute Navigation', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            final newAddr = CustomerAddress(
              buildingNo: _buildingCtrl.text.trim(),
              streetNo: _streetCtrl.text.trim(),
              zoneNo: _zoneCtrl.text.trim(),
              apartmentRoom: _apartmentCtrl.text.trim(),
              city: _cityCtrl.text.trim().isEmpty ? 'Doha' : _cityCtrl.text.trim(),
              latitude: order.address.latitude != 0 ? order.address.latitude + 0.001 : 25.2867,
              longitude: order.address.longitude != 0 ? order.address.longitude + 0.001 : 51.5333,
            );
            order.deliveryLocationNote = _notesCtrl.text.trim();
            state.updateOrderAddress(order.id, newAddr);
            _showSuccessBanner('📍 Address updated! Courier notified with new destination.');
          },
        ),
      ],
    );
  }

  // ==========================================
  // PANEL 3: WALLET COURTESY COMPENSATION
  // ==========================================
  Widget _buildWalletCompensationPanel(StateService state, LaundryOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.wallet_giftcard_rounded,
          title: 'Direct Customer Wallet Courtesy Credit',
          subtitle: 'Instantly refund or credit digital wallet to resolve complaints, minor garment defects, or transit delays.',
        ),
        const SizedBox(height: 16),

        const Text('Quick Credit Preset:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [15.0, 25.0, 50.0, 100.0].map((amt) {
            final isSelected = _compensationAmount == amt;
            return ChoiceChip(
              label: Text('+${amt.toInt()} QAR'),
              selected: isSelected,
              selectedColor: const Color(0xFFDC2626),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
              ),
              onSelected: (val) {
                if (val) setState(() => _compensationAmount = amt);
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 16),
        TextField(
          controller: _compReasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Resolution Reason for Audit Log *',
            isDense: true,
          ),
        ),
        const SizedBox(height: 18),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          icon: const Icon(Icons.add_card_rounded, size: 18),
          label: Text(
            'Credit +${_compensationAmount.toStringAsFixed(0)} QAR to Customer Digital Wallet',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            state.compensateCustomerWallet(
              _compensationAmount,
              orderNumber: order.orderNumber,
              reason: _compReasonCtrl.text.trim(),
            );
            _showSuccessBanner('🎁 ${_compensationAmount.toStringAsFixed(0)} QAR credited to ${order.customerName}\'s digital wallet!');
          },
        ),
      ],
    );
  }

  // ==========================================
  // PANEL 4: DRIVER BREAKDOWN EMERGENCY
  // ==========================================
  Widget _buildDriverBreakdownPanel(StateService state, LaundryOrder order) {
    final otherDrivers = state.drivers.where((d) => d.id != order.assignedDriverId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.car_crash_rounded,
          title: 'Driver Breakdown / Emergency Courier Re-Dispatch',
          subtitle: 'Current driver vehicle suffered mechanical failure, flat tire, or road accident. Reassign mission immediately.',
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: _selectedNewDriverId,
          decoration: const InputDecoration(
            labelText: 'Select Available Online Replacement Courier *',
            isDense: true,
          ),
          items: otherDrivers.map((d) {
            return DropdownMenuItem(
              value: d.id,
              child: Text(
                '${d.fullName} (${d.affiliation.shortBadge} • ${d.documents.vehicleRegPlate})',
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedNewDriverId = val),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _breakdownReasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Breakdown Report & Transfer Reason *',
            isDense: true,
          ),
        ),
        const SizedBox(height: 18),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          icon: const Icon(Icons.emergency_rounded, size: 18),
          label: const Text('Execute Emergency Courier Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: _selectedNewDriverId == null
              ? null
              : () {
                  state.reassignOrderDriver(order.id, _selectedNewDriverId!, reason: _breakdownReasonCtrl.text.trim());
                  _showSuccessBanner('🚗 Mission transferred to replacement courier. Priority notification pushed!');
                },
        ),
      ],
    );
  }

  // ==========================================
  // PANEL 5: VIP EXPRESS PRIORITY UPGRADE
  // ==========================================
  Widget _buildVipExpressPanel(StateService state, LaundryOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.bolt_rounded,
          title: 'Expedite to ⚡ VIP Express Rush Priority',
          subtitle: 'Customer urgently needs laundry for a flight or VIP event. Jumps ahead in the washing and pressing line.',
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚡ VIP Priority Impact:',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 6),
              const Text('• Flags laundry floor screen with high-visibility gold express badge.', style: TextStyle(fontSize: 12)),
              const Text('• Courier assigned for direct express doorstep transport without grouping.', style: TextStyle(fontSize: 12)),
              const Text('• Customer receives priority tracking notification on their mobile app.', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                icon: const Icon(Icons.bolt_rounded, size: 18),
                label: const Text('Upgrade Order to ⚡ VIP Express Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  state.upgradeOrderToExpress(order.id);
                  _showSuccessBanner('⚡ Order upgraded to VIP Express! Laundry facility alerted.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PANEL 6: WAIVE DELIVERY FEE
  // ==========================================
  Widget _buildWaiveDeliveryFeePanel(StateService state, LaundryOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.money_off_rounded,
          title: 'Waive Doorstep Delivery Fee (15 QAR Refund)',
          subtitle: 'Grant free delivery to resolve customer dissatisfaction regarding scheduling or service speed.',
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instant 15 QAR Doorstep Fee Reimbursement',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF14532D)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Reimburses the 15 QAR delivery surcharge directly to the customer\'s digital wallet with "Free Delivery Waived" tag on the order.',
                style: TextStyle(fontSize: 12, color: Color(0xFF166534)),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Waive 15 QAR Delivery Fee & Credit Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  state.waiveDeliveryFee(order.id);
                  _showSuccessBanner('💸 Delivery fee waived! 15 QAR credited to customer wallet.');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // PANEL 7: EMERGENCY QR CODE REGENERATION
  // ==========================================
  Widget _buildEmergencyQrPanel(StateService state, LaundryOrder order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.qr_code_scanner_rounded,
          title: 'Emergency Garment Bag QR Re-Tagging',
          subtitle: 'If the physical barcode/QR was torn, lost in transit, or unreadable by the driver camera scanner.',
        ),
        const SizedBox(height: 16),

        TextField(
          controller: _replacementQrCtrl,
          decoration: const InputDecoration(
            labelText: 'New Unique Emergency QR Payload *',
            isDense: true,
          ),
        ),
        const SizedBox(height: 14),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
          label: const Text('Bind New QR Code & Override Garment Payload', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            state.replaceOrderQrPayload(
              order.id,
              _replacementQrCtrl.text.trim(),
              reason: 'CS Supervisor emergency QR re-tagging due to unreadable physical tag',
            );
            _showSuccessBanner('🏷️ Emergency QR bound to order. Driver app scanner updated.');
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFDC2626), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }
}
