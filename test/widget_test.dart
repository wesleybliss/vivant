import 'package:flutter_test/flutter_test.dart';
import 'package:vivant/main.dart';
import 'package:vivant/services/auth_service.dart';
import 'package:vivant/services/convex_service.dart';
import 'package:vivant/screens/auth/login_screen.dart';

void main() {
  testWidgets('App smoke test - verifies auth gate loads', (WidgetTester tester) async {
    // Create mock services
    final authService = AuthService();
    final convexService = ConvexService(baseUrl: 'https://test.convex.cloud');

    // Build our app and trigger a frame.
    await tester.pumpWidget(Vivant(
      authService: authService,
      convexService: convexService,
    ));

    // Allow the auth check to complete
    await tester.pumpAndSettle();

    // Since no auth, should show login screen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
