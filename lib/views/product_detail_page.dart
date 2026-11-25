import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../controllers/favorites_controller.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final bool isAdmin;
  final VoidCallback? onEdit;
  const ProductDetailPage({super.key, required this.product, required this.isAdmin, this.onEdit});
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}
class _ProductDetailPageState extends State<ProductDetailPage> {
  int qty = 1;
  final cart = Get.find<CartController>();
  final favorites = Get.find<FavoritesController>();
  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      appBar: AppBar(title: const Text('THE COLLECTION', style: TextStyle(fontSize: 13, letterSpacing: 2, fontWeight: FontWeight.w900)), actions: [
        if (!widget.isAdmin) ...[
          Obx(() => IconButton(tooltip: 'Favorito', onPressed: () => favorites.toggle(p.id), icon: Icon(favorites.contains(p.id) ? Icons.favorite : Icons.favorite_border, color: AppColors.red))),
          Obx(() => IconButton(tooltip: 'Mi bolsa', onPressed: () => Get.to(() => const CartPage()), icon: Badge(isLabelVisible: cart.count > 0, label: Text('${cart.count}'), child: const Icon(Icons.shopping_bag_outlined)))),
        ],
      ]),
      body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
        ClipRRect(borderRadius: BorderRadius.circular(24), child: AspectRatio(aspectRatio: 1.15, child: Stack(fit: StackFit.expand, children: [
          const ColoredBox(color: Color(0xFFF1F0ED)),
          Hero(tag: 'cap-${p.id}', child: ProductImage(url: p.imageUrl, fit: BoxFit.contain)),
          Positioned(left: 12, top: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(8)), child: const Text('CAP / CLUB', style: TextStyle(color: AppColors.red, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)))),
          Positioned(right: 10, bottom: 10, child: IconButton.filled(tooltip: 'Ampliar foto', onPressed: () => showDialog<void>(context: context, builder: (ctx) => Dialog(child: Stack(children: [AspectRatio(aspectRatio: 1, child: InteractiveViewer(minScale: 1, maxScale: 4, child: ColoredBox(color: const Color(0xFFF1F0ED), child: ProductImage(url: p.imageUrl, fit: BoxFit.contain)))), Positioned(top: 4, right: 4, child: IconButton.filled(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)))]))), icon: const Icon(Icons.zoom_in))),
        ]))),
        const SizedBox(height: 20), Text(p.brand.toUpperCase(), style: const TextStyle(color: AppColors.red, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 5), Text(p.name, style: const TextStyle(fontSize: 30, height: 1.1, letterSpacing: -1, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10), Text(cop(p.price), style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 18), const Divider(), const SizedBox(height: 12),
        const Text('El toque final de tu outfit.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7), Text('Gorra ${p.brand} de la colección CAP / CLUB. Consulta tu pedido y sus novedades desde la app.', style: const TextStyle(color: AppColors.muted, height: 1.5)),
        if (!widget.isAdmin) ...[
          const SizedBox(height: 22), Row(children: [const Expanded(child: Text('Cantidad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))), IconButton.outlined(onPressed: qty > 1 ? () => setState(() => qty--) : null, icon: const Icon(Icons.remove)), Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), IconButton.outlined(onPressed: qty < 99 ? () => setState(() => qty++) : null, icon: const Icon(Icons.add))]),
          const SizedBox(height: 18), _info(Icons.local_shipping_outlined, 'Sigue tu pedido', 'Consulta el estado desde Mis pedidos.'), _info(Icons.receipt_long_outlined, 'Compra con cuenta', 'Tu pedido se guarda en el historial.'),
        ],
      ])))),
      bottomNavigationBar: SafeArea(top: false, child: Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), decoration: const BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.line))), child: Center(heightFactor: 1, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: widget.isAdmin ? SizedBox(width: double.infinity, child: FilledButton(onPressed: widget.onEdit, child: const Text('Editar producto'))) : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Row(children: [const Expanded(child: Text('Subtotal', style: TextStyle(color: AppColors.muted))), Text(cop(p.price * qty), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]), const SizedBox(height: 8), FilledButton.icon(onPressed: p.price > 0 && p.price.isFinite ? () => cart.add(p, quantity: qty) : null, icon: const Icon(Icons.shopping_bag_outlined), label: const Text('Agregar a mi bolsa'))]))))),
    );
  }
  Widget _info(IconData icon, String title, String text) => ListTile(contentPadding: EdgeInsets.zero, leading: Icon(icon, color: AppColors.red), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(text));
}
