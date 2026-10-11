import 'package:flutter/material.dart';
import 'order_item.dart';
import '../theme/app_colors.dart';

enum OrderStatus {
  placed,
  driverAssigned,
  pickedUp,
  inLaundry,
  readyForDelivery,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed (Sent to Admin)';
      case OrderStatus.driverAssigned:
        return 'Driver Assigned by Admin';
      case OrderStatus.pickedUp:
        return 'Picked Up & In Transit to Laundry';
      case OrderStatus.inLaundry:
        return 'In Washing / Dry Cleaning / Pressing';
      case OrderStatus.readyForDelivery:
        return 'Order Ready for Delivery';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.driverAssigned:
        return 1;
      case OrderStatus.pickedUp:
        return 2;
      case OrderStatus.inLaundry:
        return 3;
      case OrderStatus.readyForDelivery:
        return 4;
      case OrderStatus.outForDelivery:
        return 5;
      case OrderStatus.delivered:
        return 6;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.placed:
        return AppColors.statusPlaced;
      case OrderStatus.driverAssigned:
        return AppColors.statusDriver;
      case OrderStatus.pickedUp:
        return AppColors.statusLaundry;
      case OrderStatus.inLaundry:
        return AppColors.statusProcessing;
      case OrderStatus.readyForDelivery:
        return AppColors.statusReady;
      case OrderStatus.outForDelivery:
        return AppColors.statusDelivery;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.placed:
        return Icons.receipt_long_rounded;
      case OrderStatus.driverAssigned:
        return Icons.electric_moped_rounded;
      case OrderStatus.pickedUp:
        return Icons.local_shipping_rounded;
      case OrderStatus.inLaundry:
        return Icons.local_laundry_service_rounded;
      case OrderStatus.readyForDelivery:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.task_alt_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

class CustomerAddress {
  final String buildingNo;
  final String streetNo;
  final String zoneNo;
  final String apartmentRoom;
  final String city;
  final double latitude;
  final double longitude;

  const CustomerAddress({
    required this.buildingNo,
    required this.streetNo,
    required this.zoneNo,
    required this.apartmentRoom,
    this.city = 'Doha',
    this.latitude = 25.2854,
    this.longitude = 51.5310,
  });

  String get formatted => 'Bldg $buildingNo, St $streetNo, Zone $zoneNo, Apt $apartmentRoom, $city';
}

class OrderAttachment {
  final String id;
  final String fileName;
  final String fileType; // 'image' or 'pdf'
  final String uploadedBy; // 'customer', 'laundry', 'driver'
  final String description;
  final DateTime uploadedAt;
  final String? fileUrl;
  final int fileSizeBytes;

  const OrderAttachment({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadedBy,
    required this.description,
    required this.uploadedAt,
    this.fileUrl,
    this.fileSizeBytes = 512000,
  });

  bool get isPdf => fileType.toLowerCase() == 'pdf' || fileName.toLowerCase().endsWith('.pdf');
  bool get isImage => !isPdf;
}

class LaundryOrder {
  final String id;
  final int orderNumber;
  final String customerName;
  final String customerPhone;
  CustomerAddress address;
  final List<OrderItem> items;
  OrderStatus status;
  final double deliveryFee;
  final String paymentMethod; // 'cash', 'pos_card', 'online'
  String paymentStatus; // 'pending', 'paid'
  String specialInstructions;
  final DateTime createdAt;
  String assignedDriverId;
  String assignedDriverName;
  String assignedDriverPhone;
  String laundryName;
  String laundryId;
  bool isCountVerifiedByLaundry;
  bool isAcceptedByLaundry;
  bool isDriverRideStarted;
  DateTime? driverRideStartedAt;
  int driverPingCount;
  DateTime? lastDriverPingAt;
  List<OrderAttachment> attachments;
  double? laundryRating;
  double? driverRating;
  String? laundryReview;
  String? driverReview;

  // Driver Workflow Tracking
  DriverWorkflowStep workflowStep;

  // 1. Collection Phase
  DateTime? collectionStartedAt;
  bool collectionQrScanned;
  DateTime? collectionQrScannedAt;
  String? collectionProofPhoto;
  DateTime? collectionProofUploadedAt;
  DateTime? collectionCompletedAt;

  // 2. Laundry Arrival Phase
  DateTime? arrivedAtLaundryAt;
  bool laundryQrScanned;
  DateTime? laundryQrScannedAt;
  String? laundryProofPhoto;
  DateTime? dispatchedToLaundryAt;

  // 3. Delivery Loading Phase
  DateTime? deliveryLoadingStartedAt;
  bool deliveryLoadingQrScanned;
  bool deliveryLoadedInVan;
  String? deliveryLoadingBagHangerPhoto;
  String? deliveryLoadingPlatePhoto;
  String? deliveryLoadingLaundryPhoto;

  // 4. Delivery Phase
  DateTime? deliveryStartedAt;
  bool deliveryQrScanned;
  DateTime? deliveryQrScannedAt;
  String? deliveryProofPhoto;
  DateTime? deliveryProofUploadedAt;
  String? deliveryLocation;
  String? deliveryLocationNote;
  DateTime? deliveredAt;
  double? earnedBonus;

  // 5. Cancellation
  OrderCancellationRecord? cancellationRecord;

  // 6. Garment Tags & QR Code Management
  List<String> tags;
  String? customQrTag;

  // 7. Scheduling & Customer Service Controls
  DateTime? scheduledPickupDate;
  String? scheduledPickupSlot;
  DateTime? scheduledDeliveryDate;
  String? scheduledDeliverySlot;
  List<String> customerContactNotes;
  bool isCustomerVerified;

  // 8. Urgent Order & Express Rush Turnaround
  bool isUrgent;
  double urgentFee;

  LaundryOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.address,
    required this.items,
    this.status = OrderStatus.placed,
    this.deliveryFee = 15.0,
    this.paymentMethod = 'pos_card',
    this.paymentStatus = 'pending',
    this.specialInstructions = '',
    required this.createdAt,
    this.assignedDriverId = '',
    this.assignedDriverName = 'Unassigned',
    this.assignedDriverPhone = '',
    this.laundryName = 'UniWash Pearl Branch',
    this.laundryId = 'laundry-doha-01',
    this.isCountVerifiedByLaundry = false,
    this.isAcceptedByLaundry = false,
    this.isDriverRideStarted = false,
    this.driverRideStartedAt,
    this.driverPingCount = 0,
    this.lastDriverPingAt,
    List<OrderAttachment>? attachments,
    this.laundryRating,
    this.driverRating,
    this.laundryReview,
    this.driverReview,
    this.workflowStep = DriverWorkflowStep.assigned,
    this.collectionStartedAt,
    this.collectionQrScanned = false,
    this.collectionQrScannedAt,
    this.collectionProofPhoto,
    this.collectionProofUploadedAt,
    this.collectionCompletedAt,
    this.arrivedAtLaundryAt,
    this.laundryQrScanned = false,
    this.laundryQrScannedAt,
    this.laundryProofPhoto,
    this.dispatchedToLaundryAt,
    this.deliveryLoadingStartedAt,
    this.deliveryLoadingQrScanned = false,
    this.deliveryLoadedInVan = false,
    this.deliveryLoadingBagHangerPhoto,
    this.deliveryLoadingPlatePhoto,
    this.deliveryLoadingLaundryPhoto,
    this.deliveryStartedAt,
    this.deliveryQrScanned = false,
    this.deliveryQrScannedAt,
    this.deliveryProofPhoto,
    this.deliveryProofUploadedAt,
    this.deliveryLocation,
    this.deliveryLocationNote,
    this.deliveredAt,
    this.earnedBonus,
    this.cancellationRecord,
    List<String>? tags,
    this.customQrTag,
    this.scheduledPickupDate,
    this.scheduledPickupSlot,
    this.scheduledDeliveryDate,
    this.scheduledDeliverySlot,
    List<String>? customerContactNotes,
    this.isCustomerVerified = false,
    this.isUrgent = false,
    this.urgentFee = 25.0,
  })  : attachments = attachments ?? [],
        tags = tags ?? [],
        customerContactNotes = customerContactNotes ?? [];

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.effectiveTotal);
  double get totalAmount => subtotal + deliveryFee + (isUrgent ? urgentFee : 0.0);
  int get totalItemCount => items.fold(0, (sum, item) => sum + (item.verifiedQuantity ?? item.quantity));

  String get scheduleSummary {
    final pSlot = scheduledPickupSlot ?? 'Standard Slot';
    final dSlot = scheduledDeliverySlot ?? (isUrgent ? '⚡ Express 4-Hour' : 'Standard Next-Day');
    return 'Pickup: $pSlot • Drop-off: $dSlot';
  }

  String get qrCodePayload => customQrTag ?? 'UNIWASH-ORD-$orderNumber-$customerPhone';
  set qrCodePayload(String value) => customQrTag = value;
}

enum DriverWorkflowStep {
  assigned,
  collectionStarted,
  collectionQrScanned,
  collectionProofUploaded,
  collectionCompleted,
  receivedAtLaundry,
  laundryQrScanCompleted,
  laundryProofUploaded,
  dispatchedToLaundry,
  deliveryStarted,
  orderScannedForDelivery,
  loadedInVan,
  deliveryStartedForOrder,
  deliveryProofUploaded,
  deliveryLocationSelected,
  delivered,
  cancelled,
}

extension DriverWorkflowStepExtension on DriverWorkflowStep {
  String get displayName {
    switch (this) {
      case DriverWorkflowStep.assigned:
        return 'Order Assigned';
      case DriverWorkflowStep.collectionStarted:
        return 'Collection Started';
      case DriverWorkflowStep.collectionQrScanned:
        return 'QR Code Scanned';
      case DriverWorkflowStep.collectionProofUploaded:
        return 'Collection Proof Uploaded';
      case DriverWorkflowStep.collectionCompleted:
        return 'Collection Completed';
      case DriverWorkflowStep.receivedAtLaundry:
        return 'Received at Laundry';
      case DriverWorkflowStep.laundryQrScanCompleted:
        return 'Laundry QR Scan Completed';
      case DriverWorkflowStep.laundryProofUploaded:
        return 'Laundry Proof Uploaded';
      case DriverWorkflowStep.dispatchedToLaundry:
        return 'Dispatched to Laundry';
      case DriverWorkflowStep.deliveryStarted:
        return 'Delivery Started';
      case DriverWorkflowStep.orderScannedForDelivery:
        return 'Order Scanned for Delivery';
      case DriverWorkflowStep.loadedInVan:
        return 'Loaded in Van';
      case DriverWorkflowStep.deliveryStartedForOrder:
        return 'Delivery Started for Order';
      case DriverWorkflowStep.deliveryProofUploaded:
        return 'Delivery Proof Uploaded';
      case DriverWorkflowStep.deliveryLocationSelected:
        return 'Delivery Location Selected';
      case DriverWorkflowStep.delivered:
        return 'Order Delivered';
      case DriverWorkflowStep.cancelled:
        return 'Order Cancelled';
    }
  }

  int get orderProgressIndex {
    switch (this) {
      case DriverWorkflowStep.assigned:
        return 0;
      case DriverWorkflowStep.collectionStarted:
        return 1;
      case DriverWorkflowStep.collectionQrScanned:
        return 2;
      case DriverWorkflowStep.collectionProofUploaded:
        return 3;
      case DriverWorkflowStep.collectionCompleted:
        return 4;
      case DriverWorkflowStep.receivedAtLaundry:
        return 5;
      case DriverWorkflowStep.laundryQrScanCompleted:
        return 6;
      case DriverWorkflowStep.laundryProofUploaded:
        return 7;
      case DriverWorkflowStep.dispatchedToLaundry:
        return 8;
      case DriverWorkflowStep.deliveryStarted:
        return 9;
      case DriverWorkflowStep.orderScannedForDelivery:
        return 10;
      case DriverWorkflowStep.loadedInVan:
        return 11;
      case DriverWorkflowStep.deliveryStartedForOrder:
        return 12;
      case DriverWorkflowStep.deliveryProofUploaded:
        return 13;
      case DriverWorkflowStep.deliveryLocationSelected:
        return 14;
      case DriverWorkflowStep.delivered:
        return 15;
      case DriverWorkflowStep.cancelled:
        return -1;
    }
  }
}

class OrderCancellationRecord {
  final String orderId;
  final String driverId;
  final String driverName;
  final String reasonCategory; // 'Customer-Related', 'Driver/Company-Related', 'Customer Service Action'
  final String reason;
  final String? customDescription;
  final String locationPhoto;
  final String callLogPhoto;
  final List<String> additionalPhotos;
  final DateTime cancelledAt;
  final String? cancelledBy;

  const OrderCancellationRecord({
    required this.orderId,
    this.driverId = 'CS-DISPATCH',
    this.driverName = 'Customer Service Agent',
    this.reasonCategory = 'Customer Service Action',
    required this.reason,
    this.customDescription,
    this.locationPhoto = '',
    this.callLogPhoto = '',
    this.additionalPhotos = const [],
    required this.cancelledAt,
    this.cancelledBy,
  });
}
