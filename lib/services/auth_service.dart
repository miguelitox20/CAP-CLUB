import 'package:firebase_auth/firebase_auth.dart';
import 'storage_service.dart';

class AuthService {
  // Solo este correo es administrador (en minúsculas).
  static const String adminEmail = 'luissarmiento@gmail.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Correo del usuario con sesión (null si no hay).
  String? get currentEmail => _auth.currentUser?.email?.toLowerCase();

  bool get isVerifiedAdmin => currentEmail == adminEmail && (_auth.currentUser?.emailVerified ?? false);
  Future<void> sendVerification() async { await _auth.currentUser?.sendEmailVerification(); }
  Future<void> refreshVerification() async { await _auth.currentUser?.reload(); await _auth.currentUser?.getIdToken(true); }

  // Todos devuelven null si salió bien, o el mensaje de error.
  Future<String?> register(String email, String pass) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: pass);
      await StorageService().saveLastEmail(email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensaje(e.code);
    } catch (_) {
      return 'No se pudo conectar. Revisa tu internet';
    }
  }

  Future<String?> login(String email, String pass) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: pass);
      await StorageService().saveLastEmail(email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensaje(e.code);
    } catch (_) {
      return 'No se pudo conectar. Revisa tu internet';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mensaje(e.code);
    } catch (_) {
      return 'No se pudo conectar. Revisa tu internet';
    }
  }

  Future<void> logout() => _auth.signOut();

  String _mensaje(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo no es válido';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Ese correo ya está registrado';
      case 'weak-password':
        return 'La contraseña debe tener mínimo 6 caracteres';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento';
      default:
        return 'Error: $code';
    }
  }
}
