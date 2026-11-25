import 'package:get/get.dart';
import '../services/storage_service.dart';
import 'auth_controller.dart';

class FavoritesController extends GetxController {
  final _auth = Get.find<AuthController>();
  final ids = <String>[].obs;
  late final Worker _worker;
  @override
  void onInit() {
    super.onInit();
    _worker = ever(_auth.email, (_) => _load());
    _load();
  }
  void _load() {
    final email = _auth.email.value;
    ids.assignAll(email == null ? <String>[] : StorageService().favorites(email));
  }
  bool contains(String id) => ids.contains(id);
  Future<void> toggle(String id) async {
    final email = _auth.email.value;
    if (email == null) return;
    if (ids.contains(id)) { ids.remove(id); } else { ids.add(id); }
    try { await StorageService().saveFavorites(email, ids.toList()); }
    catch (_) { Get.snackbar('Favoritos', 'No se pudo guardar en este dispositivo.'); }
  }
  @override
  void onClose() { _worker.dispose(); super.onClose(); }
}
