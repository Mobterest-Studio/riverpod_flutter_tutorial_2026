import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.processing => 'Processing',
    OrderStatus.shipped => 'Shipped',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  Color get chipColor => switch (this) {
    OrderStatus.pending => Colors.orange,
    OrderStatus.processing => Colors.blue,
    OrderStatus.shipped => Colors.purple,
    OrderStatus.delivered => Colors.green,
    OrderStatus.cancelled => Colors.red,
  };

  Color get chipBgColor => switch (this) {
    OrderStatus.pending => Colors.orange.shade100,
    OrderStatus.processing => Colors.blue.shade100,
    OrderStatus.shipped => Colors.purple.shade100,
    OrderStatus.delivered => Colors.green.shade100,
    OrderStatus.cancelled => Colors.red.shade100,
  };
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double priceAtPurchase;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  double get subtotal => quantity * priceAtPurchase;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productIdId'].toString(),
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
    };
  }
}

class Order {
  final String id;
  final OrderStatus status;
  final List<OrderItem> items;
  final double total;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      status: OrderStatus.fromString(json['status'] as String),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Order && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Order(id: $id, status: $status, total: $total';
}
