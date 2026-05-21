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
import 'order_status.dart' as _i2;
import 'package:shopwave_backend_client/src/protocol/protocol.dart' as _i3;

abstract class Order implements _i1.SerializableModel {
  Order._({
    this.id,
    required this.status,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.userId,
  });

  factory Order({
    int? id,
    required _i2.OrderStatus status,
    required List<int> items,
    required double total,
    required DateTime createdAt,
    required int userId,
  }) = _OrderImpl;

  factory Order.fromJson(Map<String, dynamic> jsonSerialization) {
    return Order(
      id: jsonSerialization['id'] as int?,
      status: _i2.OrderStatus.fromJson((jsonSerialization['status'] as String)),
      items: _i3.Protocol().deserialize<List<int>>(jsonSerialization['items']),
      total: (jsonSerialization['total'] as num).toDouble(),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      userId: jsonSerialization['userId'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i2.OrderStatus status;

  List<int> items;

  double total;

  DateTime createdAt;

  int userId;

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Order copyWith({
    int? id,
    _i2.OrderStatus? status,
    List<int>? items,
    double? total,
    DateTime? createdAt,
    int? userId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Order',
      if (id != null) 'id': id,
      'status': status.toJson(),
      'items': items.toJson(),
      'total': total,
      'createdAt': createdAt.toJson(),
      'userId': userId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderImpl extends Order {
  _OrderImpl({
    int? id,
    required _i2.OrderStatus status,
    required List<int> items,
    required double total,
    required DateTime createdAt,
    required int userId,
  }) : super._(
         id: id,
         status: status,
         items: items,
         total: total,
         createdAt: createdAt,
         userId: userId,
       );

  /// Returns a shallow copy of this [Order]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Order copyWith({
    Object? id = _Undefined,
    _i2.OrderStatus? status,
    List<int>? items,
    double? total,
    DateTime? createdAt,
    int? userId,
  }) {
    return Order(
      id: id is int? ? id : this.id,
      status: status ?? this.status,
      items: items ?? this.items.map((e0) => e0).toList(),
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }
}
