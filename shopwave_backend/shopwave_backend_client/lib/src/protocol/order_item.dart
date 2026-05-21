/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'product.dart' as _i2;
import 'package:shopwave_backend_client/src/protocol/protocol.dart' as _i3;

abstract class OrderItem implements _i1.SerializableModel {
  OrderItem._({
    this.id,
    required this.productIdId,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItem({
    int? id,
    required int productIdId,
    _i2.Product? productId,
    required String productName,
    required int quantity,
    required double priceAtPurchase,
  }) = _OrderItemImpl;

  factory OrderItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderItem(
      id: jsonSerialization['id'] as int?,
      productIdId: jsonSerialization['productIdId'] as int,
      productId: jsonSerialization['productId'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.Product>(
              jsonSerialization['productId'],
            ),
      productName: jsonSerialization['productName'] as String,
      quantity: jsonSerialization['quantity'] as int,
      priceAtPurchase: (jsonSerialization['priceAtPurchase'] as num).toDouble(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int productIdId;

  _i2.Product? productId;

  String productName;

  int quantity;

  double priceAtPurchase;

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderItem copyWith({
    int? id,
    int? productIdId,
    _i2.Product? productId,
    String? productName,
    int? quantity,
    double? priceAtPurchase,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OrderItem',
      if (id != null) 'id': id,
      'productIdId': productIdId,
      if (productId != null) 'productId': productId?.toJson(),
      'productName': productName,
      'quantity': quantity,
      'priceAtPurchase': priceAtPurchase,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderItemImpl extends OrderItem {
  _OrderItemImpl({
    int? id,
    required int productIdId,
    _i2.Product? productId,
    required String productName,
    required int quantity,
    required double priceAtPurchase,
  }) : super._(
         id: id,
         productIdId: productIdId,
         productId: productId,
         productName: productName,
         quantity: quantity,
         priceAtPurchase: priceAtPurchase,
       );

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderItem copyWith({
    Object? id = _Undefined,
    int? productIdId,
    Object? productId = _Undefined,
    String? productName,
    int? quantity,
    double? priceAtPurchase,
  }) {
    return OrderItem(
      id: id is int? ? id : this.id,
      productIdId: productIdId ?? this.productIdId,
      productId: productId is _i2.Product?
          ? productId
          : this.productId?.copyWith(),
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      priceAtPurchase: priceAtPurchase ?? this.priceAtPurchase,
    );
  }
}
