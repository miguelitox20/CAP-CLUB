import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/cap_icon.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final auth = Get.find<AuthController>();
  final form = GlobalKey<FormState>();
  final email = TextEditingController(text: StorageService().lastEmail ?? '');
  final pass = TextEditingController();
  bool register = false, hidden = true;
  @override
  void dispose() { email.dispose(); pass.dispose(); super.dispose(); }
  String? emailError(String? value) => GetUtils.isEmail((value ?? '').trim()) ? null : 'Escribe un correo válido';
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 460), child: Form(key: form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Row(children: [CapIcon(size: 44), SizedBox(width: 8), Text('CAP / CLUB', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: 2))]),
        const SizedBox(height: 24),
        Container(height: 172, decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(24)), child: const Stack(children: [Positioned(right: 4, bottom: 0, child: CapIcon(size: 158, crownColor: AppColors.black)), Positioned(left: 20, top: 22, child: Text('TU ESTILO.\nTUS REGLAS.', style: TextStyle(color: AppColors.black, fontSize: 27, height: 1.03, fontWeight: FontWeight.w900))), Positioned(left: 20, bottom: 18, child: Text('HEADWEAR / EST. 2026', style: TextStyle(color: AppColors.black, fontSize: 10, fontWeight: FontWeight.w700)))])),
        const SizedBox(height: 30),
        Text(register ? 'Únete al club.' : 'Qué bueno verte.', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
        const SizedBox(height: 6), Text(register ? 'Crea tu cuenta y descubre el catálogo.' : 'Inicia sesión para explorar la colección.', style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 24),
        TextFormField(controller: email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.email], validator: emailError, decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.alternate_email))),
        const SizedBox(height: 12),
        TextFormField(controller: pass, obscureText: hidden, autofillHints: [register ? AutofillHints.newPassword : AutofillHints.password], validator: (v) => (v ?? '').length < 6 ? 'Mínimo 6 caracteres' : null, decoration: InputDecoration(labelText: 'Contraseña', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => hidden = !hidden), icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
        if (!register) Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () { if (emailError(email.text) == null) { auth.resetPassword(email.text); } else { Get.snackbar('Correo requerido', 'Escribe un correo válido para recuperar tu contraseña.'); } }, child: const Text('¿Olvidaste tu contraseña?'))),
        const SizedBox(height: 14),
        Obx(() => FilledButton(onPressed: auth.busy.value ? null : () { if (form.currentState!.validate()) { if (register) { auth.register(email.text, pass.text); } else { auth.login(email.text, pass.text); } } }, child: auth.busy.value ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(register ? 'Crear mi cuenta' : 'Iniciar sesión'))),
        const SizedBox(height: 12),
        Obx(() => OutlinedButton(onPressed: auth.busy.value ? null : () => setState(() { register = !register; pass.clear(); }), child: Text(register ? 'Ya tengo cuenta' : 'Crear una cuenta'))),
        const SizedBox(height: 24), const Text('CAP / CLUB   •   Acceso seguro con Firebase', textAlign: TextAlign.center, style: TextStyle(color: AppColors.muted, fontSize: 11)),
      ])))))),
  );
}
