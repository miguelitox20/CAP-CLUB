import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/order_controller.dart';
import '../models/pedido.dart';
import '../theme/app_theme.dart';

const stageTitles = ['Pedido recibido', 'Preparando tu gorra', 'En tránsito', 'En aduana', 'En reparto', 'Entregado'];
const stageDescriptions = ['Tu pedido está registrado.', 'El equipo está preparando el paquete.', 'El pedido salió del centro de distribución.', 'Revisión de importación (si aplica).', 'El envío está en la última etapa del trayecto.', 'El pedido figura como entregado.'];
const stageIcons = [Icons.receipt_long_outlined, Icons.inventory_2_outlined, Icons.flight_takeoff, Icons.fact_check_outlined, Icons.local_shipping_outlined, Icons.check_circle_outline];
String statusTitle(String status) { final i = Pedido.estados.indexOf(status); return i < 0 ? status : stageTitles[i]; }
String orderCode(String id) => id.substring(0, id.length < 7 ? id.length : 7).toUpperCase();
String orderDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year} · ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

class TrackingPage extends StatelessWidget {
  final String orderId;
  const TrackingPage({super.key, required this.orderId});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrderController>();
    return Scaffold(appBar: AppBar(title: const Text('CLUB TRACK', style: TextStyle(fontSize: 15, letterSpacing: 2, fontWeight: FontWeight.w900))), body: SafeArea(child: Obx(() {
      final list = c.pedidos.where((p) => p.id == orderId).toList();
      if (c.error.value != null) return Center(child: TextButton(onPressed: c.reload, child: const Text('Sin conexión a pedidos. Reintentar')));
      if (list.isEmpty) return Center(child: c.loading.value ? const CircularProgressIndicator() : const Text('Pedido no disponible'));
      final p = list.first; final stage = p.stage;
      return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 30), children: [
        Text('ENVÍO / ${orderCode(p.id)}', style: const TextStyle(color: AppColors.muted, letterSpacing: 2, fontWeight: FontWeight.w800, fontSize: 11)),
        const SizedBox(height: 8), Text(statusTitle(p.status), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 30, height: 1.05, letterSpacing: -1)),
        const SizedBox(height: 8), Text(stage < 0 ? 'Estado aún no reconocido.' : stageDescriptions[stage], style: const TextStyle(color: AppColors.muted)),
        const SizedBox(height: 18), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.sync, color: AppColors.red, size: 18), const SizedBox(width: 8), const Expanded(child: Text('Estado del pedido · Firestore', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))), Text(stage < 0 ? '—' : '${stage+1}/6', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w900))]),
          const SizedBox(height: 12), Row(children: [for (var i=0; i<6; i++) Expanded(child: Container(height: 5, margin: EdgeInsets.only(right: i == 5 ? 0 : 4), decoration: BoxDecoration(color: i <= stage ? AppColors.red : AppColors.line, borderRadius: BorderRadius.circular(5))))]),
          const SizedBox(height: 9), Text(p.updatedAt == null ? 'Registrado: ${orderDate(p.date)}' : 'Actualizado: ${orderDate(p.updatedAt!.toLocal())}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ])),
        const SizedBox(height: 22), const Text('Ruta del envío', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
        RouteMap(stage: stage), const SizedBox(height: 10), const Text('Mapa ilustrativo • No representa GPS ni una transportadora real. La aduana es opcional.', style: TextStyle(color: AppColors.muted, fontSize: 11, height: 1.4)),
        const SizedBox(height: 24), const Text('Etapas del pedido', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 12),
        for (var i=0; i<stageTitles.length; i++) _step(i, stage),
        const SizedBox(height: 12), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.shopping_bag_outlined, color: AppColors.red), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${p.items.fold<int>(0,(n,it)=>n+it.qty)} artículos', style: const TextStyle(fontWeight: FontWeight.bold)), const Text('Total del pedido', style: TextStyle(color: AppColors.muted, fontSize: 12))])), Text(cop(p.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18))])),
      ])));
    })));
  }
  Widget _step(int i, int stage) {
    final current = i == stage; final passed = i < stage;
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: current ? AppColors.red : AppColors.card, shape: BoxShape.circle, border: Border.all(color: passed ? AppColors.red : AppColors.line)), child: Icon(stageIcons[i], size: 21, color: current ? AppColors.black : passed ? AppColors.red : AppColors.muted)), if (i < 5) Container(width: 2, height: 32, color: passed ? AppColors.red : AppColors.line)]),
      const SizedBox(width: 12), Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: current ? AppColors.card : Colors.transparent, border: Border.all(color: current ? AppColors.red : Colors.transparent), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(stageTitles[i], style: TextStyle(fontWeight: FontWeight.w800, color: current ? AppColors.red : Colors.white)), const SizedBox(height: 4), Text(current ? 'ESTADO ACTUAL' : i == 3 ? 'ETAPA OPCIONAL'  : passed ? 'ETAPA ANTERIOR' : 'PRÓXIMA ETAPA', style: const TextStyle(fontSize: 10, color: AppColors.muted, letterSpacing: .8)), if (current) ...[const SizedBox(height: 5), Text(stageDescriptions[i], style: const TextStyle(fontSize: 12, color: AppColors.muted))]]))),
    ]));
  }
}

class RouteMap extends StatelessWidget {
  final int stage;
  const RouteMap({super.key, required this.stage});
  @override
  Widget build(BuildContext context) => Container(clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: const Color(0xFF202F2B), borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.line)), child: AspectRatio(aspectRatio: 1.2, child: Stack(fit: StackFit.expand, children: [
    TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: stage < 0 ? 0.0 : stage / 5), duration: const Duration(milliseconds: 750), curve: Curves.easeOutCubic, builder: (_, value, __) => CustomPaint(painter: _RoutePainter(value))),
    const Positioned(top: 12, left: 12, child: _MapTag('RUTA DEMO', Icons.map_outlined)), const Positioned(bottom: 12, right: 12, child: _MapTag('N  ↑', Icons.explore_outlined)),
    const Positioned(left: 12, bottom: 12, child: Text('Centro logístico', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold))), const Positioned(right: 12, top: 55, child: Text('Destino', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold))),
  ])));
}
class _MapTag extends StatelessWidget {
  final String text; final IconData icon;
  const _MapTag(this.text, this.icon);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(7)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: AppColors.red), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .7))]));
}
class _RoutePainter extends CustomPainter {
  final double progress;
  _RoutePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    Offset at(double x,double y) => Offset(w*x,h*y);
    final block = Paint()..color=const Color(0xFF283B33);
    for (var y=0;y<5;y++) { for (var x=0;x<7;x++) { canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w*(x*.15+.015),h*(y*.20+.02),w*.12,h*.15),const Radius.circular(5)),block); } }
    final river = Path()..moveTo(w*.48,0)..cubicTo(w*.12,h*.35,w*.85,h*.63,w*.5,h);
    canvas.drawPath(river,Paint()..color=const Color(0xFF162F39)..style=PaintingStyle.stroke..strokeWidth=w*.14);
    final roads=Paint()..color=const Color(0xFF52615A)..strokeWidth=2;
    for(var i=1;i<7;i++) { canvas.drawLine(at(i*.15,0),at(i*.15,1),roads); }
    for(var i=1;i<5;i++) { canvas.drawLine(at(0,i*.20),at(1,i*.20),roads); }
    final pts=[at(.16,.76),at(.28,.64),at(.28,.40),at(.60,.40),at(.72,.20),at(.86,.30)];
    final route=Path()..moveTo(pts.first.dx,pts.first.dy); for(final p in pts.skip(1)) {route.lineTo(p.dx,p.dy);}
    canvas.drawPath(route,Paint()..color=const Color(0xFF83948B)..style=PaintingStyle.stroke..strokeWidth=5..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
    final metric=route.computeMetrics().first;
    final step=(progress*5).floor().clamp(0,5).toInt();
    final partial=Path()..moveTo(pts.first.dx,pts.first.dy); for(var i=1;i<=step;i++){partial.lineTo(pts[i].dx,pts[i].dy);}
    final next=step<5 ? Offset.lerp(pts[step],pts[step+1],progress*5-step)! : pts.last;
    partial.lineTo(next.dx,next.dy);
    if(metric.length>0) canvas.drawPath(partial,Paint()..color=AppColors.red..style=PaintingStyle.stroke..strokeWidth=5..strokeCap=StrokeCap.round..strokeJoin=StrokeJoin.round);
    for(var i=0;i<pts.length;i++){canvas.drawCircle(pts[i],6,Paint()..color=AppColors.black);canvas.drawCircle(pts[i],3,Paint()..color=i<=step?AppColors.red:Colors.white54);}
    canvas.drawCircle(next,17,Paint()..color=const Color(0x55D3F36A));canvas.drawCircle(next,10,Paint()..color=AppColors.red);canvas.drawCircle(next,4,Paint()..color=AppColors.black);
  }
  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate)=>oldDelegate.progress!=progress;
}
