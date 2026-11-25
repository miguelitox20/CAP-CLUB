import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  // Colección "gorras" en Firestore.
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('gorras');

  // TIEMPO REAL: emite la lista completa cada vez que algo cambia.
  Stream<List<Product>> watchAll() {
    return _col.snapshots().map((snap) {
      final lista =
          snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
      lista
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return lista;
    });
  }

  // CREATE
  Future<void> create(
      String name, String brand, double price, String imageUrl) async {
    await _col.add({
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE
  Future<void> update(String id, String name, String brand, double price,
      String imageUrl) async {
    await _col.doc(id).update({
      'name': name,
      'brand': brand,
      'price': price,
      'imageUrl': imageUrl,
    });
  }

  // DELETE
  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
