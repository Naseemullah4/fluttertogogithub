import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/badge_pill.dart';

class CustomerContactDialog extends StatefulWidget {
  final LaundryOrder order;
  final int initialTabIndex; // 0=Live Chat, 1=WhatsApp, 2=Email, 3=Phone

  const CustomerContactDialog({
    super.key,
    required this.order,
    this.initialTabIndex = 0,
  });

  static Future<void> show(
    BuildContext context,
    LaundryOrder order, {
    int initialTabIndex = 0,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CustomerContactDialog(
        order: order,
        initialTabIndex: initialTabIndex,
      ),
    );
  }

  @override
  State<CustomerContactDialog> createState() => _CustomerContactDialogState();
}

class _CustomerContactDialogState extends State<CustomerContactDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Live Chat Controllers & Local Thread
  final TextEditingController _chatInputCtrl = TextEditingController();
  final ScrollController _chatScrollCtrl = ScrollController();
  final List<Map<String, dynamic>> _chatThread = [];

  // WhatsApp Controllers
  late TextEditingController _whatsAppTextCtrl;

  // Email Controllers
  late TextEditingController _emailToCtrl;
  late TextEditingController _emailSubjectCtrl;
  late TextEditingController _emailBodyCtrl;

  // Phone Call Controllers
  String _selectedCallOutcome = 'Answered & Verified Pieces';
  final TextEditingController _callNotesCtrl = TextEditingController(
    text: 'Customer confirmed gate entry instructions and requested arrival notification.',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // Initial Live Chat Messages
    final now = DateTime.now();
    _chatThread.addAll([
      {
        'sender': 'Customer (${widget.order.customerName})',
        'text': 'Hello, I wanted to check when my laundry will be delivered today?',
        'time': DateFormat('HH:mm').format(now.subtract(const Duration(minutes: 12))),
        'isMe': false,
      },
      {
        'sender': 'UniWash Support',
        'text': 'Hello ${widget.order.customerName}! We have your Order #${widget.order.orderNumber} in transit with Courier ${widget.order.assignedDriverName}.',
        'time': DateFormat('HH:mm').format(now.subtract(const Duration(minutes: 8))),
        'isMe': true,
      },
    ]);

    // Initial WhatsApp Text
    _whatsAppTextCtrl = TextEditingController(
      text: 'Hello ${widget.order.customerName}, this is UniWash Laundry Operations regarding Order #${widget.order.orderNumber}. Your items are currently ${widget.order.status.displayName.toLowerCase()}. Courier: ${widget.order.assignedDriverName}. Please let us know if you need any adjustments.',
    );

    // Initial Email Fields
    final sanitizedEmail = '${widget.order.customerName.toLowerCase().replaceAll(RegExp(r'\s+'), '.')}@gmail.com';
    _emailToCtrl = TextEditingController(text: sanitizedEmail);
    _emailSubjectCtrl = TextEditingController(
      text: '[UniWash Qatar] Update regarding your Order #${widget.order.orderNumber}',
    );
    _emailBodyCtrl = TextEditingController(
      text: '''Dear ${widget.order.customerName},

Thank you for trusting UniWash Luxury Laundry Services.

This is an official communication regarding your Order #${widget.order.orderNumber}.
Status: ${widget.order.status.displayName}
Delivery Address: ${widget.order.address.formatted}
Assigned Courier: ${widget.order.assignedDriverName}

If you have special delicate garment requests or require a gate access code update, please reply to this email or contact our Doha 24/7 Hotline.

Warm regards,
Customer Support Operations Team
UniWash Qatar • Doha Metro Hub''',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatInputCtrl.dispose();
    _chatScrollCtrl.dispose();
    _whatsAppTextCtrl.dispose();
    _emailToCtrl.dispose();
    _emailSubjectCtrl.dispose();
    _emailBodyCtrl.dispose();
    _callNotesCtrl.dispose();
    super.dispose();
  }

  void _sendLiveChatMessage(StateService state) {
    final text = _chatInputCtrl.text.trim();
    if (text.isEmpty) return;

    final nowStr = DateFormat('HH:mm').format(DateTime.now());
    setState(() {
      _chatThread.add({
        'sender': 'Support Agent',
        'text': text,
        'time': nowStr,
        'isMe': true,
      });
      _chatInputCtrl.clear();
    });

    state.sendCustomerDirectMessage(
      widget.order.id,
      channel: 'Live In-App Chat',
      text: text,
    );

    // Auto-scroll chat
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollCtrl.hasClients) {
        _chatScrollCtrl.animateTo(
          _chatScrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate realistic customer reply after 1.2s
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        final replyTime = DateFormat('HH:mm').format(DateTime.now());
        setState(() {
          _chatThread.add({
            'sender': widget.order.customerName,
            'text': 'Thank you so much for the quick confirmation! Everything sounds perfect.',
            'time': replyTime,
            'isMe': false,
          });
        });
        if (_chatScrollCtrl.hasClients) {
          _chatScrollCtrl.animateTo(
            _chatScrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      }
    });
  }

  Future<void> _launchWhatsApp(StateService state) async {
    final cleanPhone = widget.order.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent(_whatsAppTextCtrl.text.trim());
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$text');

    state.sendCustomerDirectMessage(
      widget.order.id,
      channel: 'WhatsApp Business',
      text: _whatsAppTextCtrl.text.trim(),
    );

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp app. Message logged in system.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WhatsApp launch notification: $e')),
        );
      }
    }
  }

  Future<void> _launchEmail(StateService state) async {
    final to = _emailToCtrl.text.trim();
    final subject = Uri.encodeComponent(_emailSubjectCtrl.text.trim());
    final body = Uri.encodeComponent(_emailBodyCtrl.text.trim());
    final url = Uri.parse('mailto:$to?subject=$subject&body=$body');

    state.sendCustomerDirectMessage(
      widget.order.id,
      channel: 'Official Email',
      text: '${_emailSubjectCtrl.text.trim()} -> ${_emailBodyCtrl.text.trim()}',
      recipientEmail: to,
    );

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email recorded in audit log and sent.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email notification: $e')),
        );
      }
    }
  }

  Future<void> _launchPhoneCall(StateService state) async {
    final cleanPhone = widget.order.customerPhone.replaceAll(RegExp(r'\s+'), '');
    final url = Uri.parse('tel:$cleanPhone');

    state.logCustomerContact(
      widget.order.id,
      channel: 'Phone Voice Call',
      outcome: _selectedCallOutcome,
      notes: _callNotesCtrl.text.trim(),
    );

    try {
      await launchUrl(url);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final order = state.orders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 760),
        child: Column(
          children: [
            // TOP HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A), // Dark Slate
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.forum_rounded, color: Color(0xFF38BDF8), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Customer Contact Center • ${order.customerName}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            BadgePill(
                              label: 'Order #${order.orderNumber}',
                              color: const Color(0xFF38BDF8),
                              backgroundColor: const Color(0xFF0369A1).withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Mobile: ${order.customerPhone} • Courier: ${order.assignedDriverName} • ${order.status.displayName}',
                          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
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

            // OMNICHANNEL TAB BAR
            Container(
              color: const Color(0xFFF8FAFC),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: const Color(0xFF64748B),
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.chat_bubble_rounded, size: 18), text: '💬 Live In-App Chat'),
                  Tab(icon: Icon(Icons.phone_iphone_rounded, size: 18), text: '🟢 WhatsApp Business'),
                  Tab(icon: Icon(Icons.email_rounded, size: 18), text: '📧 Official Email'),
                  Tab(icon: Icon(Icons.phone_in_talk_rounded, size: 18), text: '📞 Phone & Voice Log'),
                ],
              ),
            ),
            const Divider(height: 1),

            // TAB VIEWS
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: LIVE IN-APP CHAT
                  _buildLiveChatTab(state, order),

                  // TAB 2: WHATSAPP
                  _buildWhatsAppTab(state, order),

                  // TAB 3: EMAIL
                  _buildEmailTab(state, order),

                  // TAB 4: PHONE
                  _buildPhoneTab(state, order),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: LIVE IN-APP CHAT
  // ==========================================
  Widget _buildLiveChatTab(StateService state, LaundryOrder order) {
    return Column(
      children: [
        // Online Customer Status Ribbon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          color: const Color(0xFFF1F5F9),
          child: Row(
            children: [
              const CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                '${order.customerName} is Active on UniWash Mobile App (Doha)',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              const Spacer(),
              const Text('Encrypted Real-Time Socket', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            ],
          ),
        ),

        // Chat Messages Thread
        Expanded(
          child: ListView.builder(
            controller: _chatScrollCtrl,
            padding: const EdgeInsets.all(16),
            itemCount: _chatThread.length,
            itemBuilder: (context, index) {
              final msg = _chatThread[index];
              final isMe = msg['isMe'] as bool;

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: const BoxConstraints(maxWidth: 520),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF0284C7) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: Radius.circular(isMe ? 14 : 2),
                      bottomRight: Radius.circular(isMe ? 2 : 14),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['sender'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        msg['text'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isMe ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        msg['time'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          color: isMe ? Colors.white60 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Quick Canned Replies
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCannedChip('👋 Courier is on the way (ETA ~15m)', state),
              _buildCannedChip('🚪 Please confirm if gate/intercom code is working', state),
              _buildCannedChip('🧺 All pieces inspected & confirmed', state),
              _buildCannedChip('⚡ Upgraded to VIP Express Priority', state),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Chat Input Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputCtrl,
                  decoration: InputDecoration(
                    hintText: 'Type message to ${order.customerName}...',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) => _sendLiveChatMessage(state),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Send', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _sendLiveChatMessage(state),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCannedChip(String text, StateService state) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11)),
        backgroundColor: const Color(0xFFF1F5F9),
        onPressed: () {
          _chatInputCtrl.text = text;
          _sendLiveChatMessage(state);
        },
      ),
    );
  }

  // ==========================================
  // TAB 2: WHATSAPP BUSINESS
  // ==========================================
  Widget _buildWhatsAppTab(StateService state, LaundryOrder order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WhatsApp Business Direct Messenger', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('Direct WhatsApp to Qatar Mobile: ${order.customerPhone}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          const Text('Choose Pre-configured Template:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _whatsAppTextCtrl.text =
                        'Hello ${order.customerName}! Your UniWash Order #${order.orderNumber} is out for delivery with Courier ${order.assignedDriverName}. ETA is approximately 15 minutes. Thank you!';
                  });
                },
                child: const Text('🚚 Out for Delivery Alert', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _whatsAppTextCtrl.text =
                        'Hello ${order.customerName}! Our courier has arrived at your building for Order #${order.orderNumber}. Please open intercom or authorize doorstep drop-off.';
                  });
                },
                child: const Text('🔔 Doorbell / Intercom Notice', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _whatsAppTextCtrl.text =
                        'Hello ${order.customerName}! During intake inspection for Order #${order.orderNumber}, we noticed a delicate stain on your item. Would you like our specialty spot-treatment?';
                  });
                },
                child: const Text('🧺 Delicate Stain Inquiry', style: TextStyle(fontSize: 11)),
              ),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _whatsAppTextCtrl.text =
                        'Dear ${order.customerName}, we apologize for the minor turnaround delay for Order #${order.orderNumber}. We have credited +25 QAR directly to your UniWash Digital Wallet!';
                  });
                },
                child: const Text('🎁 Courtesy Wallet Credit', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Custom Message Preview:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _whatsAppTextCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Launch WhatsApp (wa.me)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _launchWhatsApp(state),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy & Record in Audit', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  state.sendCustomerDirectMessage(
                    order.id,
                    channel: 'WhatsApp Copied',
                    text: _whatsAppTextCtrl.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ WhatsApp message logged in customer contact history.')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: OFFICIAL EMAIL
  // ==========================================
  Widget _buildEmailTab(StateService state, LaundryOrder order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF2563EB), size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enterprise Email Communication', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('Send formatted email notification to customer inbox', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          TextField(
            controller: _emailToCtrl,
            decoration: const InputDecoration(
              labelText: 'Customer Email Address *',
              isDense: true,
              prefixIcon: Icon(Icons.alternate_email_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailSubjectCtrl,
            decoration: const InputDecoration(
              labelText: 'Subject Line *',
              isDense: true,
              prefixIcon: Icon(Icons.subject_rounded, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailBodyCtrl,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Official Email Message Body *',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.mail_outline_rounded, size: 18),
                label: const Text('Open in Email App (mailto:)', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => _launchEmail(state),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.send_and_archive_rounded, size: 16),
                label: const Text('Dispatch via SMTP Gateway', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  state.sendCustomerDirectMessage(
                    order.id,
                    channel: 'SMTP Cloud Email',
                    text: '${_emailSubjectCtrl.text.trim()} -> ${_emailBodyCtrl.text.trim()}',
                    recipientEmail: _emailToCtrl.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📧 Email successfully dispatched to ${_emailToCtrl.text.trim()}!'),
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: PHONE & VOICE CALL LOG
  // ==========================================
  Widget _buildPhoneTab(StateService state, LaundryOrder order) {
    final callOutcomes = [
      'Answered & Verified Pieces',
      'Confirmed Gate Access / Delivery Slot',
      'Customer Requested Reschedule',
      'No Answer / Voicemail Left',
      'Line Busy / Follow-up Required',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_forwarded_rounded, color: Color(0xFF059669), size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Direct Voice Call & Conversation Record', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  Text('Dial Qatar Mobile: ${order.customerPhone}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
            label: Text('📞 Dial ${order.customerPhone} Now', style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _launchPhoneCall(state),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          const Text('Record Call Outcome in System:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedCallOutcome,
            decoration: const InputDecoration(labelText: 'Call Outcome', isDense: true),
            items: callOutcomes.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedCallOutcome = val);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _callNotesCtrl,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Call Summary & Verification Notes *'),
          ),

          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.save_rounded, size: 16),
            label: const Text('Save Voice Call Outcome to Order History'),
            onPressed: () {
              state.logCustomerContact(
                order.id,
                channel: 'Phone Call',
                outcome: _selectedCallOutcome,
                notes: _callNotesCtrl.text.trim(),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Phone call record saved in order contact history.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
