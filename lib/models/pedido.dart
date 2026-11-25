import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoItem {
  final String name;
  final String brand;
  final double price;
  final int qty;

  PedidoItem({
    required this.name,
    required this.brand,
    required this.price,
    required this.qty,
  });

  double get subtotal => price * qty;

  Map<String, dynamic> toMap() => {
        'name': name,
        'brand': brand,
        'price': price,
        'qty': qty,
      };

  factory PedidoItem.fromMap(Map<String, dynamic> m) => PedidoItem(
        name: '${m['name'] ?? ''}',
        brand: '${m['brand'] ?? ''}',
        price: double.tryParse('${m['price']}') ?? 0,
        qty: (m['qty'] as num?)?.toInt() ?? 1,
      );
}

class Pedido {
  static const List<String> estados = ['pendiente', 'preparando', 'enviado', 'aduana', 'reparto', 'entregado'];

  final String id;
  final String userEmail;
  final List<PedidoItem> items;
  final double total;
  final DateTime date;
  final String status;
  final DateTime? updatedAt;
  int get stage => estados.contains(status) ? estados.indexOf(status) : -1;

  Pedido({
    required this.id,
    required this.userEmail,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'pendiente',
    this.updatedAt,
  });

  // Lee un documento de Firestore.
  factory Pedido.fromMap(String id, Map<String, dynamic> m) => Pedido(
        id: id,
        userEmail: '${m['userEmail'] ?? ''}',
        items: ((m['items'] as List?) ?? [])
            .map((e) => PedidoItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        total: double.tryParse('${m['total']}') ?? 0,
        date: m['date'] is Timestamp
            ? (m['date'] as Timestamp).toDate()
            : DateTime.now(),
        status: '${m['status'] ?? 'pendiente'}',
        updatedAt: m['updatedAt'] is Timestamp ? (m['updatedAt'] as Timestamp).toDate() : null,
      );
}
