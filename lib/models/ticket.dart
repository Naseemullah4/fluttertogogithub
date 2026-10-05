enum TicketType {
  complaint,
  suggestion,
  damagedItem,
  delayNotice,
  vehicleBreakdown,
}

class SupportTicket {
  final String id;
  final String authorName;
  final String authorRole; // customer, driver, laundry
  final TicketType type;
  final String title;
  final String description;
  final DateTime createdAt;
  String status; // 'open', 'in_review', 'resolved'
  final String? attachmentName;

  SupportTicket({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.type,
    required this.title,
    required this.description,
    required this.createdAt,
    this.status = 'open',
    this.attachmentName,
  });
}

class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}
