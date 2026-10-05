import 'package:flutter/material.dart';
import '../../models/ticket.dart';

class DriverReportIssueDialog extends StatefulWidget {
  final Function(TicketType type, String title, String description, String? attachment) onSubmit;

  const DriverReportIssueDialog({super.key, required this.onSubmit});

  @override
  State<DriverReportIssueDialog> createState() => _DriverReportIssueDialogState();
}

class _DriverReportIssueDialogState extends State<DriverReportIssueDialog> {
  TicketType _type = TicketType.damagedItem;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();
  String? _attachment;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Report Pickup Issue / Delay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TicketType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Issue Category'),
                items: const [
                  DropdownMenuItem(value: TicketType.damagedItem, child: Text('Pre-existing Garment Damage at Pickup')),
                  DropdownMenuItem(value: TicketType.vehicleBreakdown, child: Text('Vehicle Breakdown / Traffic Accident')),
                  DropdownMenuItem(value: TicketType.delayNotice, child: Text('Severe Weather / Route Obstruction')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Short Summary'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Incident Description & Details'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _attachment = 'evidence_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📸 Photo attached to incident report')),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: Text(_attachment != null ? 'Attached: $_attachment' : 'Capture Photo / Video Proof'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (_title.text.isEmpty || _desc.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill title and description')),
                      );
                      return;
                    }
                    widget.onSubmit(_type, _title.text.trim(), _desc.text.trim(), _attachment);
                    Navigator.pop(context);
                  },
                  child: const Text('Submit Incident to Regional Dispatch'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
