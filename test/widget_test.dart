import 'package:flutter_test/flutter_test.dart';
import 'package:vivant/main.dart';
import 'package:vivant/screens/home_screen.dart';

void main() {
  testWidgets('App smoke test - verifies home screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: initializeFirebase() is called in main(), which might cause issues in a plain widget test
    // but Vivant() widget itself can be tested.
    await tester.pumpWidget(const Vivant());

    // Verify that the HomeScreen is present.
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
