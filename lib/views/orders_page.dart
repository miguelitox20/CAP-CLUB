import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/order_controller.dart';
import '../models/pedido.dart';
import '../theme/app_theme.dart';
import 'tracking_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}
class _OrdersPageState extends State<OrdersPage> {
  final c = Get.find<OrderController>();
  final auth = Get.find<AuthController>();
  int filter = 0;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('CLUB / ORDERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 2)), actions: [IconButton(tooltip: 'Actualizar pedidos', onPressed: c.reload, icon: const Icon(Icons.refresh))]), body: SafeArea(child: Obx(() {
    final all = c.visibles; final admin = auth.isAdmin;
    if (c.loading.value) return const Center(child: CircularProgressIndicator());
    if (c.error.value != null) return Center(child: TextButton(onPressed: c.reload, child: const Text('No se pudieron cargar los pedidos. Reintentar')));
    final active = all.where((p) => p.status != 'entregado').length;
    final list = all.where((p) => filter == 0 || (filter == 1 ? p.status != 'entregado' : p.status == 'entregado')).toList();
    return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 28), children: [
      Text(admin ? 'CONTROL LOGÍSTICO' : 'TU HISTORIAL', style: const TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)), const SizedBox(height: 6),
      Text(admin ? 'Pedidos recibidos.' : 'Mis pedidos.', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)), const SizedBox(height: 15),
      Row(children: [Expanded(child: _metric(Icons.local_shipping_outlined, '$active', 'En proceso')), const SizedBox(width: 10), Expanded(child: _metric(Icons.check_circle_outline, '${all.length-active}', 'Entregados'))]), const SizedBox(height: 14),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [for (var i=0;i<3;i++) Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(['Todos','En proceso','Entregados'][i]), selected: filter == i, onSelected: (_) => setState(() => filter=i)))])), const SizedBox(height: 12),
      if (list.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 50), child: Column(children: [Icon(Icons.receipt_long_outlined, color: AppColors.muted, size: 52), SizedBox(height: 12), Text('No hay pedidos en esta sección.', textAlign: TextAlign.center)])),
      for (final p in list) _order(p, admin),
    ])));
  })));
  Widget _metric(IconData icon, String value, String label) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.red, size: 20), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900)), Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12))]));
  Widget _order(Pedido p, bool admin) => Container(margin: const EdgeInsets.only(bottom: 14), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)), child: Icon(p.stage < 0 ? Icons.receipt_long_outlined : stageIcons[p.stage], color: AppColors.red)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('#${orderCode(p.id)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), Text(orderDate(p.date), style: const TextStyle(color: AppColors.muted, fontSize: 11))]))]),
    if (admin) Padding(padding: const EdgeInsets.only(top: 8), child: Text(p.userEmail, style: const TextStyle(color: AppColors.muted))), const SizedBox(height: 12),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(9)), child: Text(statusTitle(p.status).toUpperCase(), style: const TextStyle(color: AppColors.red, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .5))), const SizedBox(height: 12),
    Row(children: [for(var i=0;i<6;i++) Expanded(child: Container(height: 4, margin: EdgeInsets.only(right: i==5?0:4), decoration: BoxDecoration(color: i<=p.stage?AppColors.red:AppColors.line, borderRadius: BorderRadius.circular(4))))]), const SizedBox(height: 14),
    for (final it in p.items) Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [Expanded(child: Text('${it.qty} × ${it.name}')), const SizedBox(width: 6), Text(cop(it.subtotal), style: const TextStyle(color: AppColors.muted))])), const Divider(height: 24), Row(children: [const Expanded(child: Text('Total', style: TextStyle(color: AppColors.muted))), Text(cop(p.total), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900))]), const SizedBox(height: 14),
    SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: () => Get.to(() => TrackingPage(orderId: p.id)), icon: const Icon(Icons.route_outlined), label: Text(admin ? 'Ver seguimiento' : 'Rastrear mi pedido'))),
    if (admin) ...[const SizedBox(height: 8), Obx(() => SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: c.updating.contains(p.id) ? null : () => _change(p), icon: const Icon(Icons.edit_location_alt_outlined), label: Text(c.updating.contains(p.id) ? 'Actualizando...' : 'Actualizar estado'))))],
  ]));
  Future<void> _change(Pedido p) async {
    final status = await showModalBottomSheet<String>(context: context, isScrollControlled: true, builder: (ctx) => SafeArea(child: FractionallySizedBox(heightFactor: .86, child: Column(children: [const Padding(padding: EdgeInsets.all(18), child: Text('Actualizar logística', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))), const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Text('El cambio se guarda en Firebase. Omite aduana si el envío es nacional.', style: TextStyle(color: AppColors.muted))), Expanded(child: ListView(children: [for(var i=0;i<Pedido.estados.length;i++) ListTile(leading: Icon(stageIcons[i], color: AppColors.red), title: Text(stageTitles[i]), trailing: p.stage==i?const Icon(Icons.check_circle,color: AppColors.red):const Icon(Icons.chevron_right), onTap: () => Navigator.pop(ctx,Pedido.estados[i]))]))]))));
    if (status != null && status != p.status) await c.cambiarEstado(p.id, status);
  }
}
