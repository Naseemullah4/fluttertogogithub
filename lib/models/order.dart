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
        return 'Order Placed';
      case OrderStatus.driverAssigned:
        return 'Driver En-Route for Pickup';
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
  final CustomerAddress address;
  final List<OrderItem> items;
  OrderStatus status;
  final double deliveryFee;
  final String paymentMethod; // 'cash', 'pos_card', 'online'
  String paymentStatus; // 'pending', 'paid'
  final String specialInstructions;
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
    this.assignedDriverName = 'Tariq Al-Mansoor',
    this.assignedDriverPhone = '+974 5512 8900',
    this.laundryName = 'UniWash Pearl Branch',
    this.laundryId = 'laundry-doha-01',
    this.isCountVerifiedByLaundry = false,
    this.isAcceptedByLaundry = true,
    this.isDriverRideStarted = false,
    this.driverRideStartedAt,
    this.driverPingCount = 0,
    this.lastDriverPingAt,
    List<OrderAttachment>? attachments,
    this.laundryRating,
    this.driverRating,
    this.laundryReview,
    this.driverReview,
  }) : attachments = attachments ?? [];

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.effectiveTotal);
  double get totalAmount => subtotal + deliveryFee;
  int get totalItemCount => items.fold(0, (sum, item) => sum + (item.verifiedQuantity ?? item.quantity));

  String get qrCodePayload => 'UNIWASH-ORD-$orderNumber-$customerPhone';
}
