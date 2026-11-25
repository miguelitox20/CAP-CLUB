import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';
import 'orders_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CartController>();
    return Scaffold(appBar: AppBar(title: const Text('Mi carrito', style: TextStyle(fontWeight: FontWeight.w900))), body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 760), child: Obx(() {
      if (c.items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.red), const SizedBox(height: 18), const Text('Tu bolsa está vacía', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const Text('Encuentra tu próxima gorra en el catálogo.', style: TextStyle(color: AppColors.muted)), const SizedBox(height: 20), FilledButton(onPressed: () => Get.back(), child: const Text('Explorar colección'))]));
      final busy = c.submitting.value;
      final lines = c.items.toList();
      return ListView(padding: EdgeInsets.zero, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Align(alignment: Alignment.centerLeft, child: Text('${c.count} artículos seleccionados', style: const TextStyle(color: AppColors.muted)))),
        ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.all(16), itemCount: lines.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, i) {
          final it = lines[i];
          return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 62, height: 82, child: ProductImage(url: it.product.imageUrl, capSize: 42))), const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.product.brand.toUpperCase(), style: const TextStyle(color: AppColors.muted, fontSize: 10, letterSpacing: 1)), Text(it.product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), Text(cop(it.subtotal), style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [IconButton(visualDensity: VisualDensity.compact, onPressed: busy ? null : () => c.decrease(i), icon: const Icon(Icons.remove_circle_outline)), Text('${it.qty}', style: const TextStyle(fontWeight: FontWeight.w800)), IconButton(visualDensity: VisualDensity.compact, onPressed: busy ? null : () => c.increase(i), icon: const Icon(Icons.add_circle_outline))])])),
            IconButton(tooltip: 'Quitar producto', visualDensity: VisualDensity.compact, onPressed: busy ? null : () => c.remove(i), icon: const Icon(Icons.close, size: 20)),
          ]));
        }),
        Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.vertical(top: Radius.circular(24))), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Resumen del pedido', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 14), Row(children: [const Expanded(child: Text('Subtotal de productos', style: TextStyle(color: AppColors.muted))), Text(cop(c.total))]), const Divider(height: 24), Row(children: [const Expanded(child: Text('Total COP', style: TextStyle(fontWeight: FontWeight.bold))), Text(cop(c.total), style: const TextStyle(fontSize: 24, color: AppColors.red, fontWeight: FontWeight.w900))]), const SizedBox(height: 8), const Text('El pedido queda registrado como pendiente. No se procesa un pago en línea.', style: TextStyle(color: AppColors.muted, fontSize: 12)), const SizedBox(height: 14),
          FilledButton.icon(onPressed: busy ? null : () async { final ok = await c.hacerPedido(); if (ok && context.mounted) { Get.off(() => const OrdersPage()); Get.snackbar('Pedido registrado', 'Consulta el estado en Mis pedidos.'); } }, icon: const Icon(Icons.arrow_forward), label: Text(busy ? 'Enviando...' : 'Confirmar pedido')),
        ])),
      ]);
    })))));
  }
}
