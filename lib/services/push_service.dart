import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:get/get.dart';

import '../theme/app_theme.dart';
import 'storage_service.dart';

class PushService {
  // Clave VAPID de Firebase Console.
  static const String vapidKey =
      'BEblIz2N3K7HCb0SeXTLgVTJHOE4bwUOd3p1Lk6mTrhwDetUKUZDxq_lXtIcpw-ReOtJXHUKGdVzqutMYTyft3M';

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _messages;
  StreamSubscription<String>? _refresh;
  bool _activating = false;

  Future<void> _saveToken(String token, String email, bool isAdmin) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email?.toLowerCase() != email) return;
    final previous = StorageService().fcmToken;
    final col = FirebaseFirestore.instance.collection('tokens');
    if (previous != null && previous != token) await col.doc(previous).delete();
    await col.doc(token).set({'email': email, 'uid': user.uid, 'isAdmin': isAdmin, 'updatedAt': FieldValue.serverTimestamp()});
    await StorageService().saveFcmToken(token);
  }

  Future<void> desactivar() async {
    await _messages?.cancel(); _messages = null;
    await _refresh?.cancel(); _refresh = null;
    final token = StorageService().fcmToken;
    if (token != null) {
      try { await FirebaseFirestore.instance.collection('tokens').doc(token).delete().timeout(const Duration(seconds: 4)); } catch (_) { /* La sesión debe poder cerrarse sin conexión. */ }
      try { await _fcm.deleteToken().timeout(const Duration(seconds: 4)); } catch (_) { /* Revocación no confirmada sin red. */ }
      await StorageService().clearFcmToken();
    }
  }


  Future<void> activar({
    required String email,
    required bool isAdmin,
  }) async {
    if (_activating || email.isEmpty) return;
    _activating = true;
    try {
      // Solicitar permiso para mostrar notificaciones.
      final permiso = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (permiso.authorizationStatus != AuthorizationStatus.authorized &&
          permiso.authorizationStatus != AuthorizationStatus.provisional) {
        Get.snackbar(
          'Notificaciones',
          'Permiso denegado. Actívalo en la configuración del dispositivo.',
        );
        return;
      }

      // Obtener el token de Firebase.
      final token = await _fcm.getToken(
        vapidKey: kIsWeb ? vapidKey : null,
      );

      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Notificaciones',
          'No se pudo obtener el token de Firebase.',
        );
        return;
      }

      if (FirebaseAuth.instance.currentUser?.email?.toLowerCase() != email) return;
      await _saveToken(token, email, isAdmin);
      _messages ??= FirebaseMessaging.onMessage.listen((mensaje) {
        if (FirebaseAuth.instance.currentUser == null) return;
        Get.snackbar(mensaje.notification?.title ?? 'Aviso', mensaje.notification?.body ?? '', duration: const Duration(seconds: 5), snackPosition: SnackPosition.TOP);
      });
      await _refresh?.cancel();
      _refresh = _fcm.onTokenRefresh.listen((newToken) async {
        try { await _saveToken(newToken, email, isAdmin); } catch (_) { debugPrint('No se pudo actualizar token FCM'); }
      });

      // Mostrar el token para realizar pruebas.
      Get.dialog(
        AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Notificaciones activadas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Token de este dispositivo (para pruebas):',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              SelectableText(
                token,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if ('$e'.contains('failed-service-worker-registration')) {
        Get.snackbar(
          'Notificaciones',
          'Este entorno de pruebas no permite el service worker. '
              'Funcionan en Android o con la app publicada en un hosting.',
          duration: const Duration(seconds: 6),
        );
      } else {
        Get.snackbar('Notificaciones', 'No disponible: $e');
      }
    } finally {
      _activating = false;
    }
  }
}
