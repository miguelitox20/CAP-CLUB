import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manejogetx/models/product.dart';
import 'package:manejogetx/models/pedido.dart';
import 'package:manejogetx/services/storage_service.dart';
import 'package:manejogetx/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Product conserva datos al serializar', () {
    final p = Product(id: '1', name: 'Classic', brand: 'Club', price: 45000);
    final copy = Product.fromMap(p.id, p.toMap());
    expect(copy.name, p.name); expect(copy.price, 45000);
  });
  test('Subtotal y formato COP', () {
    final item = PedidoItem(name: 'Classic', brand: 'Club', price: 45000, qty: 2);
    expect(item.subtotal, 90000); expect(cop(item.subtotal), '\$ 90.000');
  });
  test('Estados de logística mantienen compatibilidad con pedidos anteriores', () {
    final p = Pedido.fromMap('abc', {'status':'enviado'});
    expect(p.stage, 2); expect(p.updatedAt, isNull);
    expect(Pedido.fromMap('abc', {'status':'aduana'}).stage, 3);
    expect(Pedido.fromMap('abc', {'status':'entregado'}).stage, 5);
    expect(Pedido.fromMap('abc', {'status':'otro'}).stage, -1);
  });
  test('Favoritos separados por cuenta', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService(); await storage.init();
    await storage.saveFavorites('a@club.com', ['gorra1']);
    await storage.init();
    expect(storage.favorites('a@club.com'), ['gorra1']);
    expect(storage.favorites('b@club.com'), isEmpty);
  });
  test('Singleton y reconciliación de sesión', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService(); await storage.init();
    expect(identical(storage, StorageService()), isTrue);
    await storage.reconcileSession('cliente@example.com');
    expect(storage.sessionEmail, 'cliente@example.com');
    await storage.init(); expect(storage.sessionEmail, 'cliente@example.com');
    await storage.reconcileSession(null); expect(storage.sessionEmail, isNull);
  });
}
