import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/uniwash_logo.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();

  final TextEditingController _ticketTitle = TextEditingController();
  final TextEditingController _ticketDesc = TextEditingController();
  TicketType _selectedTicketType = TicketType.complaint;
  String? _attachedFileName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    _ticketTitle.dispose();
    _ticketDesc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            UniWashLogo.badge(size: 28),
            SizedBox(width: 10),
            Text('Support & Help Desk'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Live In-App Chat'),
            Tab(icon: Icon(Icons.confirmation_number_outlined), text: 'Tickets & Complaints'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Chat
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFF1F5F9),
                child: Row(
                  children: [
                    const Icon(Icons.support_agent, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Direct connection with Assigned Driver & Customer Ops',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📱 Redirecting to WhatsApp Support: +974 4499 8811'),
                            backgroundColor: Color(0xFF25D366),
                          ),
                        );
                      },
                      icon: const Icon(Icons.phone, size: 14, color: Color(0xFF25D366)),
                      label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF25D366), fontSize: 12)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return Align(
                      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: msg.isMe ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: msg.isMe ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.sender,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: msg.isMe ? Colors.white70 : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              msg.text,
                              style: TextStyle(
                                fontSize: 14,
                                color: msg.isMe ? Colors.white : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('hh:mm a').format(msg.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: msg.isMe ? Colors.white54 : AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onSubmitted: (val) {
                          state.sendChatMessage(val);
                          _chatController.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                      onPressed: () {
                        state.sendChatMessage(_chatController.text);
                        _chatController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tab 2: File Ticket & History
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit a Complaint or Suggestion',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Report garment issues, delays, or submit feature requests directly to regional operations.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TicketType>(
                  initialValue: _selectedTicketType,
                  decoration: const InputDecoration(labelText: 'Ticket Type'),
                  items: TicketType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTicketType = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ticketTitle,
                  decoration: const InputDecoration(labelText: 'Subject / Title *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ticketDesc,
                  decoration: const InputDecoration(labelText: 'Description / Details *'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _attachedFileName = 'garment_photo_proof.jpg');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('📸 Photo attached: garment_photo_proof.jpg')),
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                  label: Text(_attachedFileName != null ? 'Attached: $_attachedFileName' : 'Attach Photo / Video Proof'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_ticketTitle.text.isEmpty || _ticketDesc.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill title and description')),
                        );
                        return;
                      }
                      state.submitTicket(
                        type: _selectedTicketType,
                        title: _ticketTitle.text.trim(),
                        description: _ticketDesc.text.trim(),
                        attachmentName: _attachedFileName,
                      );
                      _ticketTitle.clear();
                      _ticketDesc.clear();
                      setState(() => _attachedFileName = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Ticket filed! Regional support will review shortly.'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: const Text('Submit Ticket to Operations'),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Recent Support Tickets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ...state.tickets.map((t) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: t.status == 'resolved' ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: t.status == 'resolved' ? AppColors.success : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(t.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        if (t.attachmentName != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.attach_file, size: 14, color: AppColors.primary),
                              Text(t.attachmentName!, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
