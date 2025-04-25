// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chinese_odysee/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ChineseOdyseeApp()));

    // Verify that the app title is displayed.
    expect(find.text('Chinese Odyssey'), findsOneWidget);

    // Verify that the welcome message is displayed.
    expect(find.text('Welcome to Chinese Odyssey'), findsOneWidget);

    // Verify that the start button is displayed.
    expect(find.text('Start Learning'), findsOneWidget);
  });
}
