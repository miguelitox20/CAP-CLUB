import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido.dart';

class OrderService {
  // Colección "pedidos" en Firestore.
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('pedidos');

  // TIEMPO REAL: el admin recibe todos; el cliente solo los suyos.
  Stream<List<Pedido>> watch({required String email, required bool isAdmin}) {
    final Query<Map<String, dynamic>> q =
        isAdmin ? _col : _col.where('userEmail', isEqualTo: email);

    return q.snapshots().map((snap) {
      final lista =
          snap.docs.map((d) => Pedido.fromMap(d.id, d.data())).toList();
      // El más nuevo primero.
      lista.sort((a, b) => b.date.compareTo(a.date));
      return lista;
    });
  }

  // CREATE
  Future<void> create(String email, List<PedidoItem> items) async {
    final total = items.fold<double>(0, (suma, i) => suma + i.subtotal);
    await _col.add({
      'userEmail': email,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'date': Timestamp.now(),
      'status': 'pendiente',
    });
  }

  // UPDATE (cambiar estado)
  Future<void> updateStatus(String id, String status) {
    return _col.doc(id).update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }
}
