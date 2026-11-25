import 'package:flutter_test/flutter_test.dart';

import 'package:cliente/main.dart';

void main() {
  testWidgets('Muestra la pantalla de autenticación', (WidgetTester tester) async {
    await tester.pumpWidget(const Aplicacion());

    expect(find.text('Estadía'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
  });
}
