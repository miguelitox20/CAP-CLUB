import 'dart:async';
import 'package:get/get.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'auth_controller.dart';

class ProductController extends GetxController {
  final ProductService _service = Get.find<ProductService>();
  final AuthController _auth = Get.find<AuthController>();
  final products = <Product>[].obs;
  final loading = false.obs;
  final error = RxnString();
  StreamSubscription<List<Product>>? _sub;
  Worker? _worker;
  @override
  void onInit() { super.onInit(); _worker = ever(_auth.email, (_) => reload()); reload(); }
  void reload() {
    _sub?.cancel(); products.clear(); error.value = null;
    if (_auth.email.value == null) { loading.value = false; return; }
    loading.value = true;
    _sub = _service.watchAll().listen((list) { products.assignAll(list); loading.value = false; error.value = null; }, onError: (Object e) { loading.value = false; error.value = 'No se pudo cargar el catálogo. Revisa tu conexión y permisos.'; });
  }
  Future<bool> _write(Future<void> Function() action) async {
    if (!_auth.isAdmin) return false;
    try { await action(); return true; } catch (e) { Get.snackbar('No se pudo guardar', '$e'); return false; }
  }
  bool _valid(String name, String brand, double price) => name.trim().isNotEmpty && brand.trim().isNotEmpty && price.isFinite && price > 0;
  Future<bool> addProduct(String name, String brand, double price, String imageUrl) async => _valid(name, brand, price) && await _write(() => _service.create(name, brand, price, imageUrl));
  Future<bool> updateProduct(String id, String name, String brand, double price, String imageUrl) async => _valid(name, brand, price) && await _write(() => _service.update(id, name, brand, price, imageUrl));
  Future<bool> deleteProduct(String id) => _write(() => _service.delete(id));
  @override
  void onClose() { _sub?.cancel(); _worker?.dispose(); super.onClose(); }
}
