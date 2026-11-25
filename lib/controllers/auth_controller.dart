import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/push_service.dart';
import '../views/login_page.dart';
import '../views/product_page.dart';

class AuthController extends GetxController {
  final AuthService _service = Get.find<AuthService>();
  final email = RxnString();
  final busy = false.obs;
  bool get isAdmin { final current = email.value; return current == AuthService.adminEmail && _service.isVerifiedAdmin; }
  bool get needsVerification => email.value == AuthService.adminEmail && !_service.isVerifiedAdmin;
  Future<void> verifyAdmin() async {
    try { await _service.sendVerification(); Get.snackbar('Verifica tu correo', 'Abre el enlace recibido y vuelve a iniciar sesión.'); }
    catch (_) { Get.snackbar('Error', 'No se pudo enviar el correo de verificación.'); }
  }
  @override
  void onInit() { super.onInit(); email.value = _service.currentEmail; }
  Future<void> _authenticate(String correo, String pass, bool create) async {
    if (busy.value) return;
    final e = correo.trim().toLowerCase();
    if (!GetUtils.isEmail(e) || pass.length < 6) { Get.snackbar('Datos inválidos', 'Revisa el correo y la contraseña.'); return; }
    busy.value = true;
    try {
      final error = await (create ? _service.register(e, pass) : _service.login(e, pass));
      if (error != null) { Get.snackbar('No pudimos iniciar sesión', error); return; }
      final verified = _service.currentEmail;
      await StorageService().reconcileSession(verified);
      email.value = verified;
      if (verified != null) Get.offAll(() => const ProductPage());
    } catch (_) { Get.snackbar('Error', 'No se pudo completar la sesión.'); }
    finally { busy.value = false; }
  }
  Future<void> login(String correo, String pass) => _authenticate(correo, pass, false);
  Future<void> register(String correo, String pass) => _authenticate(correo, pass, true);
  Future<void> resetPassword(String correo) async {
    if (busy.value) return;
    final e = correo.trim().toLowerCase();
    if (!GetUtils.isEmail(e)) { Get.snackbar('Error', 'Escribe un correo válido'); return; }
    busy.value = true;
    try { final error = await _service.resetPassword(e); Get.snackbar(error == null ? 'Revisa tu correo' : 'Error', error ?? 'Enviamos un enlace de recuperación.'); }
    finally { busy.value = false; }
  }
  Future<void> logout() async {
    if (busy.value) return;
    busy.value = true;
    try {
      await Get.find<PushService>().desactivar();
      await _service.logout();
      await StorageService().clearSession();
      email.value = null;
      Get.offAll(() => const LoginPage());
    } catch (_) { Get.snackbar('Error', 'No se pudo cerrar sesión. Intenta de nuevo.'); }
    finally { busy.value = false; }
  }
}
