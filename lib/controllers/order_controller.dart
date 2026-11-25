import 'dart:async';
import 'package:get/get.dart';
import '../models/pedido.dart';
import '../services/order_service.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  final OrderService _service = Get.find<OrderService>();
  final AuthController _auth = Get.find<AuthController>();

  final pedidos = <Pedido>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final updating = <String>[].obs;
  StreamSubscription<List<Pedido>>? _sub;

  @override
  void onInit() {
    super.onInit();
    // Cada vez que cambia el usuario (login o logout), se vuelve a escuchar.
    ever(_auth.email, (_) => _escuchar());
    _escuchar();
  }

  void _escuchar() {
    _sub?.cancel();
    pedidos.clear();

    final email = _auth.email.value;
    error.value = null;
    loading.value = email != null;
    if (email == null) return;

    _sub = _service.watch(email: email, isAdmin: _auth.isAdmin).listen(
          (lista) { pedidos.assignAll(lista); loading.value = false; error.value = null; },
          onError: (Object e) { loading.value = false; error.value = 'No se pudieron cargar los pedidos'; },
        );
  }

  void reload() => _escuchar();

  // La lista ya viene filtrada desde Firestore.
  List<Pedido> get visibles => pedidos.toList();

  int get pendientes => pedidos.where((p) => p.status == 'pendiente').length;

  Future<void> cambiarEstado(String id, String estado) async {
    if (!_auth.isAdmin || !Pedido.estados.contains(estado) || updating.contains(id)) return;
    updating.add(id);
    try {
      await _service.updateStatus(id, estado);
      Get.snackbar('Logística actualizada', 'El cliente verá el nuevo estado.');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cambiar el estado. Revisa la conexión y las reglas de Firestore.');
    } finally { updating.remove(id); }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
