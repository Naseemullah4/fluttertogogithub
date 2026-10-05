import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../services/state_service.dart';
import '../../services/localization_service.dart';
import '../../theme/app_colors.dart';

class LaundryAttachmentsDialog extends StatefulWidget {
  final LaundryOrder order;

  const LaundryAttachmentsDialog({super.key, required this.order});

  static void show(BuildContext context, LaundryOrder order) {
    showDialog(
      context: context,
      builder: (_) => LaundryAttachmentsDialog(order: order),
    );
  }

  @override
  State<LaundryAttachmentsDialog> createState() => _LaundryAttachmentsDialogState();
}

class _LaundryAttachmentsDialogState extends State<LaundryAttachmentsDialog> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final order = state.orders.firstWhere((o) => o.id == widget.order.id, orElse: () => widget.order);
    final isAr = state.currentLanguage == AppLanguage.ar;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.attach_file_rounded, color: Color(0xFF2563EB), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'مستندات وصور الطلب #${order.orderNumber}' : 'Order Documents & Photos • #${order.orderNumber}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        Text(
                          isAr 
                              ? 'متطلبات العميل، صور البقع، فحص ما قبل الغسيل، ومستندات PDF' 
                              : 'Customer requirements, fabric care specs, inspection photos & PDFs',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 24),

            // Top action bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.attachments.length} ${isAr ? "مرفقات مسجلة" : "Attached Files (Images & PDFs)"}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: () => _showUploadDialog(context, state, order),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                  label: Text(
                    isAr ? 'رفع صورة / مستند PDF' : 'Upload Photo / PDF Document',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Attachments List
            Expanded(
              child: order.attachments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No photos or requirement documents attached yet.',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Laundry staff can upload pre-wash defect scans or stain photos using the button above.',
                            style: TextStyle(fontSize: 11, color: AppColors.textLight),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: order.attachments.length,
                      itemBuilder: (ctx, idx) {
                        final att = order.attachments[idx];
                        final isPdf = att.isPdf;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon thumbnail preview
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: isPdf ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isPdf ? const Color(0xFFFCA5A5) : const Color(0xFFBAE6FD)),
                                ),
                                child: Center(
                                  child: isPdf
                                      ? const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 28)
                                      : const Icon(Icons.image_rounded, color: Color(0xFF0284C7), size: 28),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          att.fileName,
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: att.uploadedBy == 'customer'
                                                ? const Color(0xFFFEF3C7)
                                                : const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            att.uploadedBy == 'customer' ? 'Customer Requirement' : 'Laundry Inspection',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: att.uploadedBy == 'customer' ? const Color(0xFF92400E) : const Color(0xFF166534),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      att.description,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textDark),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${isPdf ? "PDF Document" : "High-Res Image (JPG/PNG)"} • Uploaded ${dateFormat.format(att.uploadedAt)}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // View / Open Button
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPdf ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _openDocumentViewer(context, att),
                                icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                                label: Text(isPdf ? 'Open PDF' : 'View Photo', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDocumentViewer(BuildContext context, OrderAttachment att) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(att.isPdf ? Icons.picture_as_pdf : Icons.image, color: att.isPdf ? Colors.red : Colors.blue),
                      const SizedBox(width: 8),
                      Text(att.fileName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 20),

              // Viewer content
              Expanded(
                child: att.isPdf
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.description, size: 64, color: Color(0xFFDC2626)),
                            const SizedBox(height: 14),
                            Text(
                              att.fileName,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              att.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: const Text('📄 Page 1 of 1 • Signed & Verified Electronic Copy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 56),
                                    const SizedBox(height: 10),
                                    Text(
                                      att.fileName,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text('High Resolution 2400x1800', style: TextStyle(color: Colors.white60, fontSize: 10)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  att.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('⬇️ Downloading "${att.fileName}" to local computer storage...')),
                      );
                    },
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('Download Original'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUploadDialog(BuildContext context, StateService state, LaundryOrder order) {
    final nameController = TextEditingController(text: 'inspection_${DateTime.now().millisecondsSinceEpoch % 1000}.jpg');
    final descController = TextEditingController();
    String fileType = 'image';

    final List<Map<String, String>> presets = [
      {'name': 'prewash_stain_photo.jpg', 'type': 'image', 'desc': 'Pre-wash stubborn coffee stain documented on cuff.'},
      {'name': 'tear_hole_inspection.jpg', 'type': 'image', 'desc': 'Existing seam defect noted prior to washing cycle.'},
      {'name': 'delicate_care_spec.pdf', 'type': 'pdf', 'desc': 'Special temperature & detergent spec sheet.'},
      {'name': 'quality_clearance_signoff.pdf', 'type': 'pdf', 'desc': 'Supervisor quality clearance & packaging audit.'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
                SizedBox(width: 10),
                Text('Upload Order Photo / Document', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ],
            ),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attach pre-wash inspection photos, defect proof, or special PDF care instructions to order records.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 14),

                  // File Type Selector
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.image, size: 16),
                          label: const Text('Photo (JPG, PNG)'),
                          selected: fileType == 'image',
                          onSelected: (val) {
                            if (val) {
                              setDlgState(() {
                                fileType = 'image';
                                if (nameController.text.endsWith('.pdf')) {
                                  nameController.text = nameController.text.replaceAll('.pdf', '.jpg');
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          avatar: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text('Document (PDF)'),
                          selected: fileType == 'pdf',
                          onSelected: (val) {
                            if (val) {
                              setDlgState(() {
                                fileType = 'pdf';
                                if (nameController.text.endsWith('.jpg') || nameController.text.endsWith('.png')) {
                                  nameController.text = nameController.text.replaceAll(RegExp(r'\.(jpg|png)$'), '.pdf');
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Presets
                  const Text('Quick Template Presets:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: presets.map((p) {
                      return ActionChip(
                        avatar: Icon(p['type'] == 'pdf' ? Icons.picture_as_pdf : Icons.image, size: 13),
                        label: Text(p['name']!, style: const TextStyle(fontSize: 10)),
                        onPressed: () {
                          setDlgState(() {
                            nameController.text = p['name']!;
                            descController.text = p['desc']!;
                            fileType = p['type']!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: fileType == 'pdf' ? 'Document Name (.pdf) *' : 'Photo File Name (.jpg/.png) *',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description / Inspection Finding Notes *',
                      hintText: 'e.g. Loose thread on lining, chemical solvent used, etc.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  final newAtt = OrderAttachment(
                    id: 'att-${DateTime.now().millisecondsSinceEpoch}',
                    fileName: nameController.text.trim(),
                    fileType: fileType,
                    uploadedBy: 'laundry',
                    description: descController.text.trim().isEmpty ? 'Laundry facility pre-wash inspection file' : descController.text.trim(),
                    uploadedAt: DateTime.now(),
                  );
                  state.addOrderAttachment(order.id, newAtt);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('📎 Attached "${newAtt.fileName}" successfully to Order #${order.orderNumber}!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Save & Attach'),
              ),
            ],
          );
        },
      ),
    );
  }
}
