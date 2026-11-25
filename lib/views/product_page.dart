import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/favorites_controller.dart';
import 'product_detail_page.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import '../services/push_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../theme/cap_icon.dart';
import 'cart_page.dart';
import 'orders_page.dart';
import 'product_image.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final c = Get.find<ProductController>();
  final auth = Get.find<AuthController>();
  final cart = Get.find<CartController>();
  final orders = Get.find<OrderController>();
  final favorites = Get.find<FavoritesController>();
  bool onlyFavorites = false;
  String query = '', brand = '', sort = 'Nombre';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Row(children: [CapIcon(size: 32), SizedBox(width: 5), Text('CAP / CLUB', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 1))]), actions: [
      IconButton(tooltip: 'Notificaciones push', onPressed: () { final email = auth.email.value; if (email != null) Get.find<PushService>().activar(email: email, isAdmin: auth.isAdmin); }, icon: const Icon(Icons.notifications_none)),
      IconButton(tooltip: 'Mi cuenta', onPressed: _account, icon: const Icon(Icons.account_circle_outlined)), const SizedBox(width: 6),
    ]),
    bottomNavigationBar: Obx(() => NavigationBar(selectedIndex: 0, destinations: [
      const NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Catálogo'),
      if (!auth.isAdmin) NavigationDestination(icon: Badge(isLabelVisible: cart.count > 0, label: Text('${cart.count}'), child: const Icon(Icons.shopping_bag_outlined)), label: 'Carrito'),
      NavigationDestination(icon: Badge(isLabelVisible: auth.isAdmin && orders.pendientes > 0, label: Text('${orders.pendientes}'), child: const Icon(Icons.receipt_long_outlined)), label: 'Pedidos'),
      const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Cuenta'),
    ], onDestinationSelected: (i) { if (i == 0) return; if (!auth.isAdmin && i == 1) { Get.to(() => const CartPage()); } else if (i == (auth.isAdmin ? 1 : 2)) { Get.to(() => const OrdersPage()); } else { _account(); } })),
    floatingActionButton: Obx(() => auth.isAdmin ? FloatingActionButton.extended(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Nuevo producto')) : const SizedBox.shrink()),
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1200), child: Obx(() {
      final all = c.products.toList();
      final brands = all.map((p) => p.brand).where((b) => b.isNotEmpty).toSet().toList()..sort();
      final selected = brands.contains(brand) ? brand : '';
      final favoriteIds = favorites.ids.toList();
      final visible = all.where((p) => (!onlyFavorites || favoriteIds.contains(p.id)) && (selected.isEmpty || p.brand == selected) && '${p.name} ${p.brand}'.toLowerCase().contains(query.toLowerCase())).toList();
      if (sort == 'Nombre') visible.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (sort == 'Menor precio') visible.sort((a,b) => a.price.compareTo(b.price));
      if (sort == 'Mayor precio') visible.sort((a,b) => b.price.compareTo(a.price));
      return CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(auth.isAdmin ? 'PANEL DE ADMINISTRACIÓN' : 'STREETWEAR / HEADWEAR', style: const TextStyle(color: AppColors.muted, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (auth.isAdmin) ...[
            const Text('Tu tienda, en control.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 14), Row(children: [Expanded(child: _metric('Productos', '${all.length}', Icons.inventory_2_outlined)), const SizedBox(width: 10), Expanded(child: _metric('Pendientes', '${orders.pendientes}', Icons.schedule))]),
          ] else _campaign(all),
          const SizedBox(height: 22),
          Row(children: [Expanded(child: Text(auth.isAdmin ? 'Inventario' : 'Explora el catálogo', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900))), PopupMenuButton<String>(tooltip: 'Ordenar productos', initialValue: sort, onSelected: (s) => setState(() => sort = s), itemBuilder: (_) => ['Nombre','Menor precio','Mayor precio'].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(), icon: const Icon(Icons.sort))]),
          const SizedBox(height: 10), TextField(onChanged: (s) => setState(() => query = s.trim()), decoration: const InputDecoration(hintText: 'Busca por nombre o marca', prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 12), SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (final b in ['', ...brands]) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(b.isEmpty ? 'Todas' : b), selected: selected == b, onSelected: (_) => setState(() => brand = b))) ])),
          const SizedBox(height: 12), Row(children: [Expanded(child: Text('${visible.length} productos', style: const TextStyle(color: AppColors.muted))), if (!auth.isAdmin) FilterChip(label: const Text('Favoritos'), avatar: Icon(onlyFavorites ? Icons.favorite : Icons.favorite_border, size: 16), selected: onlyFavorites, onSelected: (v) => setState(() => onlyFavorites = v))]),
        ]))),
        if (c.loading.value) const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator())))
        else if (c.error.value != null) SliverToBoxAdapter(child: _empty(Icons.cloud_off, c.error.value!, action: TextButton(onPressed: c.reload, child: const Text('Reintentar'))))
        else if (visible.isEmpty) SliverToBoxAdapter(child: _empty(Icons.inventory_2_outlined, all.isEmpty ? 'Todavía no hay productos disponibles.' : 'No encontramos coincidencias.', action: all.isEmpty && auth.isAdmin ? TextButton(onPressed: () => _edit(), child: const Text('Agregar producto')) : null))
        else SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), sliver: SliverGrid(delegate: SliverChildBuilderDelegate((_, i) => _card(visible[i]), childCount: visible.length), gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 260, mainAxisExtent: 290, crossAxisSpacing: 12, mainAxisSpacing: 12))),
      ]);
    })))),
  );
  Widget _metric(String label, String value, IconData icon) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.red), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: AppColors.muted))]));
  Widget _empty(IconData icon, String text, {Widget? action}) => Padding(padding: const EdgeInsets.all(25), child: Column(children: [Icon(icon, size: 42, color: AppColors.muted), const SizedBox(height: 12), Text(text, textAlign: TextAlign.center), if (action != null) action]));
  Widget _card(Product p) => Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Expanded(child: InkWell(onTap: () => _details(p), child: Stack(fit: StackFit.expand, children: [Hero(tag: 'cap-${p.id}', child: ProductImage(url: p.imageUrl)), if (!auth.isAdmin) Positioned(right: 5, top: 5, child: Obx(() => IconButton.filled(tooltip: 'Favorito', style: IconButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: AppColors.red), onPressed: () => favorites.toggle(p.id), icon: Icon(favorites.contains(p.id) ? Icons.favorite : Icons.favorite_border, size: 19)))), if (auth.isAdmin) Positioned(right: 5, top: 5, child: PopupMenuButton<String>(color: AppColors.card, icon: const Icon(Icons.more_vert), onSelected: (s) { if (s == 'edit') { _edit(product: p); } else { _delete(p); } }, itemBuilder: (_) => const [PopupMenuItem(value:'edit', child: Text('Editar')), PopupMenuItem(value:'delete', child: Text('Eliminar'))]))]))),
    Padding(padding: const EdgeInsets.all(11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.brand.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1)), const SizedBox(height: 3), Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(cop(p.price), style: const TextStyle(color: AppColors.red, fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 8), SizedBox(width: double.infinity, child: FilledButton(onPressed: auth.isAdmin ? () => _edit(product: p) : () => cart.add(p), style: FilledButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 5)), child: Text(auth.isAdmin ? 'Editar' : 'Agregar +')))])),
  ]));
  void _account() => Get.bottomSheet(SafeArea(child: SingleChildScrollView(child: Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [const Text('Mi cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 12), Text(auth.email.value ?? ''), Text(auth.isAdmin ? 'Administrador' : 'Cliente', style: const TextStyle(color: AppColors.red)), if (auth.needsVerification) TextButton(onPressed: auth.verifyAdmin, child: const Text('Verificar correo de administrador')), const SizedBox(height: 12), Text(StorageService().sessionEmail == auth.email.value ? 'Sesión local sincronizada con Firebase' : 'Sesión local pendiente', style: const TextStyle(color: AppColors.muted)), const SizedBox(height: 16), Obx(() => FilledButton(onPressed: auth.busy.value ? null : auth.logout, child: const Text('Cerrar sesión')))])))));
  void _details(Product p) => Get.to(() => ProductDetailPage(product: p, isAdmin: auth.isAdmin, onEdit: () => _edit(product: p)));
  Widget _campaign(List<Product> all) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), color: AppColors.red),
    child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _CampaignPainter())),
      Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('CAP / CLUB     •     THE DROP', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)),
        const SizedBox(height: 14), const Text('NOT JUST\nA CAP.', style: TextStyle(color: AppColors.black, fontSize: 34, fontWeight: FontWeight.w900, height: .95, letterSpacing: -2)),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Tu estilo.\nTus reglas.', style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700)), const SizedBox(height: 10), if (all.isNotEmpty) FilledButton(onPressed: () => _details(all.first), style: FilledButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: AppColors.red, padding: const EdgeInsets.symmetric(horizontal: 10)), child: const Text('Ver drop'))])), const SizedBox(width: 8), Expanded(child: AspectRatio(aspectRatio: 1.2, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: all.isEmpty ? const CapIcon(size: 100, crownColor: AppColors.black) : ProductImage(url: all.first.imageUrl, fit: BoxFit.cover))))]),
      ])),
    ]));
  Future<void> _delete(Product p) async {
    final yes = await Get.dialog<bool>(AlertDialog(title: const Text('Eliminar producto'), content: Text('¿Quieres eliminar ${p.name} del catálogo?'), actions: [TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar')), FilledButton(onPressed: () => Get.back(result: true), child: const Text('Eliminar'))]));
    if (yes == true && await c.deleteProduct(p.id)) Get.snackbar('Producto eliminado', p.name);
  }
  void _edit({Product? product}) => Get.dialog(_ProductForm(controller: c, product: product), barrierDismissible: false);
}

class _ProductForm extends StatefulWidget {
  final ProductController controller;
  final Product? product;
  const _ProductForm({required this.controller, this.product});
  @override
  State<_ProductForm> createState() => _ProductFormState();
}
class _ProductFormState extends State<_ProductForm> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, brand, price, link;
  String photo = '';
  bool saving = false;
  @override
  void initState() { super.initState(); final p = widget.product; name = TextEditingController(text: p?.name ?? ''); brand = TextEditingController(text: p?.brand ?? ''); price = TextEditingController(text: p?.price.toString() ?? ''); photo = p?.imageUrl ?? ''; link = TextEditingController(text: photo.startsWith('base64:') ? '' : photo); }
  @override
  void dispose() { name.dispose(); brand.dispose(); price.dispose(); link.dispose(); super.dispose(); }
  Future<void> pick() async {
    try { final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600, maxHeight: 600, imageQuality: 65); if (file == null || !mounted) return; final bytes = await file.readAsBytes(); if (!mounted) return; if (bytes.length > 650000) { Get.snackbar('Imagen demasiado grande', 'Elige una imagen menor de 650 KB.'); return; } setState(() { photo = 'base64:${base64Encode(bytes)}'; link.clear(); }); } catch (_) { Get.snackbar('Imagen', 'No se pudo abrir la galería.'); }
  }
  Future<void> save() async {
    if (saving || !form.currentState!.validate()) return;
    setState(() => saving = true);
    final p = widget.product; final value = double.parse(price.text.trim().replaceAll(',', '.'));
    final ok = p == null ? await widget.controller.addProduct(name.text.trim(), brand.text.trim(), value, photo) : await widget.controller.updateProduct(p.id, name.text.trim(), brand.text.trim(), value, photo);
    if (!mounted) return;
    if (ok) { Get.back(); Get.snackbar('Catálogo actualizado', p == null ? 'Producto creado' : 'Cambios guardados'); } else { setState(() => saving = false); }
  }
  @override
  Widget build(BuildContext context) => AlertDialog(title: Text(widget.product == null ? 'Nuevo producto' : 'Editar producto'), content: SizedBox(width: 440, child: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
    ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(height: 120, width: double.infinity, child: ProductImage(url: photo, capSize: 65))),
    TextButton.icon(onPressed: saving ? null : pick, icon: const Icon(Icons.photo_library_outlined), label: const Text('Elegir fotografía')),
    TextFormField(controller: name, enabled: !saving, maxLength: 80, validator: (v) => (v ?? '').trim().isEmpty ? 'Nombre requerido' : null, decoration: const InputDecoration(labelText: 'Nombre')),
    TextFormField(controller: brand, enabled: !saving, maxLength: 50, validator: (v) => (v ?? '').trim().isEmpty ? 'Marca requerida' : null, decoration: const InputDecoration(labelText: 'Marca')),
    TextFormField(controller: price, enabled: !saving, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) { final n = double.tryParse((v ?? '').trim().replaceAll(',', '.')); return n == null || !n.isFinite || n <= 0 ? 'Precio mayor a cero' : null; }, decoration: const InputDecoration(labelText: 'Precio COP', prefixText: '\$ ')),
    const SizedBox(height: 12), TextFormField(controller: link, enabled: !saving, onChanged: (v) => setState(() => photo = v.trim()), validator: (v) { final s = (v ?? '').trim(); if (s.isEmpty || s.startsWith('assets/')) return null; final uri = Uri.tryParse(s); return uri != null && ['https','http'].contains(uri.scheme) && uri.host.isNotEmpty ? null : 'Usa una URL http o https'; }, decoration: const InputDecoration(labelText: 'URL de imagen (opcional)')),
  ])))), actions: [TextButton(onPressed: saving ? null : () => Get.back(), child: const Text('Cancelar')), FilledButton(onPressed: saving ? null : save, child: Text(saving ? 'Guardando...' : 'Guardar'))]);
}

class _CampaignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x22111312)..style = PaintingStyle.stroke..strokeWidth = 1.2;
    for (var i = 0; i < 8; i++) { canvas.drawCircle(Offset(size.width * .96, size.height * .22), 24.0 + i * 17, p); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
