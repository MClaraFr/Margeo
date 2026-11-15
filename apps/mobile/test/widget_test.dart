import 'package:flutter_test/flutter_test.dart';
import 'package:margeo_mobile/app.dart';

void main() {
  testWidgets('Margeo inicia corretamente', (WidgetTester tester) async {
    await tester.pumpWidget(const MargeoApp());

    expect(find.text('Margeo'), findsOneWidget);
  });
}
