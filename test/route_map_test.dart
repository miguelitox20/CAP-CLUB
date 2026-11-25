import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manejogetx/views/tracking_page.dart';

void main() {
  testWidgets('Mapa ilustrativo se adapta a un ancho de 280 px', (tester) async {
    for (final stage in [-1,0,1,2,3,4,5]) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 280, child: RouteMap(stage: stage))))));
      await tester.pumpAndSettle();
      expect(find.text('RUTA DEMO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
