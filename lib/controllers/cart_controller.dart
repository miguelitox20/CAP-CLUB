import 'package:get/get.dart';
import '../models/pedido.dart';
import '../models/product.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

// Una línea del carrito: una gorra y cuántas lleva.
class CartItem {
  final Product product;
  final int qty;

  CartItem(this.product, this.qty);

  double get subtotal => product.price * qty;
}

class CartController extends GetxController {
  final OrderService _orders = Get.find<OrderService>();
  final AuthController _auth = Get.find<AuthController>();

  final items = <CartItem>[].obs;
  final submitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Si cambia el usuario (login o logout), el carrito se vacía.
    ever(_auth.email, (_) => items.clear());
  }

  int get count => items.fold<int>(0, (suma, i) => suma + i.qty);

  double get total => items.fold<double>(0, (suma, i) => suma + i.subtotal);

  void add(Product p, {int quantity = 1}) {
    if (submitting.value || _auth.isAdmin || _auth.email.value == null || !p.price.isFinite || p.price <= 0 || quantity < 1 || quantity > 99) return;
    final i = items.indexWhere((e) => e.product.id == p.id);
    if (i == -1) {
      items.add(CartItem(p, quantity));
    } else {
      items[i] = CartItem(items[i].product, items[i].qty + quantity);
    }
    Get.snackbar('Carrito', '$quantity × ${p.name} en tu bolsa',
        duration: const Duration(seconds: 1));
  }

  void increase(int index) {
    items[index] = CartItem(items[index].product, items[index].qty + 1);
  }

  void decrease(int index) {
    if (items[index].qty <= 1) {
      items.removeAt(index);
    } else {
      items[index] = CartItem(items[index].product, items[index].qty - 1);
    }
  }

  void remove(int index) => items.removeAt(index);

  // Convierte el carrito en un pedido y lo guarda en Firestore.
  // Devuelve true si salió bien.
  Future<bool> hacerPedido() async {
    final email = _auth.email.value;
    if (items.isEmpty || email == null || _auth.isAdmin || submitting.value) return false;
    submitting.value = true;

    final lineas = items
        .map((i) => PedidoItem(
              name: i.product.name,
              brand: i.product.brand,
              price: i.product.price,
              qty: i.qty,
            ))
        .toList();

    try {
      await _orders.create(email, lineas);
      if (_auth.email.value == email) items.clear();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo enviar el pedido: $e');
      return false;
    } finally {
      submitting.value = false;
    }
  }
}
