import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_garden_idle/ui/widgets/modular_window_frame.dart';

void main() {
  testWidgets('ModularWindowFrame renders without its optional frame art', (tester) async {
    // Frame images are optional per location; a missing asset must not show an error box.
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: ModularWindowFrame(
          beamImagePath: 'assets/images/frames/missing_beam.png',
          benchImagePath: 'assets/images/frames/missing_bench.png',
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ModularWindowFrame), findsOneWidget);
  });
}
