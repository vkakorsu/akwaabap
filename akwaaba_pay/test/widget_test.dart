import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:akwaaba_pay/app/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AkwabaPayApp()),
    );

    // Verify the app renders
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
