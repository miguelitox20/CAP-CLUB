import 'package:shared_preferences/shared_preferences.dart';

// Singleton: todos los componentes comparten la misma instancia.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();
  late SharedPreferences _prefs;
  Future<void> init() async { _prefs = await SharedPreferences.getInstance(); }
  String? get lastEmail => _prefs.getString('last_email');
  Future<void> saveLastEmail(String email) async { await _prefs.setString('last_email', email); }
  String? get fcmToken => _prefs.getString('fcm_token');
  Future<void> saveFcmToken(String token) async { await _prefs.setString('fcm_token', token); }
  Future<void> clearFcmToken() async { await _prefs.remove('fcm_token'); }
  String? get sessionEmail => _prefs.getString('session_email');
  Future<void> saveSession(String email) async { await _prefs.setString('session_email', email); }
  Future<void> clearSession() async { await _prefs.remove('session_email'); }
  List<String> favorites(String email) => _prefs.getStringList('favorites_$email') ?? <String>[];
  Future<void> saveFavorites(String email, List<String> ids) async { await _prefs.setStringList('favorites_$email', ids); }
  // Firebase es la autoridad: el dato local nunca concede acceso.
  Future<void> reconcileSession(String? verifiedEmail) async {
    if (verifiedEmail == null) { await clearSession(); }
    else if (sessionEmail != verifiedEmail) { await saveSession(verifiedEmail); }
  }
}
