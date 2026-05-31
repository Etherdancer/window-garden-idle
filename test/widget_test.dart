import 'package:flutter_test/flutter_test.dart';
import 'package:window_garden_idle/main.dart';

void main() {
  testWidgets('App smoke test — WindowGardenApp renders', (WidgetTester tester) async {
    // Smoke test: just verify the app widget can be instantiated
    // Full widget tests require Hive/notification mocks
    await tester.pumpWidget(const WindowGardenApp());
    expect(find.text('Window Garden'), findsOneWidget);
  });
}
