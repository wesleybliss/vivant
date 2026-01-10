import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:vivant/domain/constants/constants.dart';
import 'package:vivant/providers/auth_provider.dart';
import 'package:vivant/providers/lists_provider.dart';
import 'package:vivant/screens/auth/login_screen.dart';
import 'package:vivant/screens/lists/lists_screen.dart';
import 'package:vivant/screens/app_shell.dart';
import 'package:vivant/services/auth_service.dart';
import 'package:vivant/services/convex_service.dart';
import 'package:vivant/utils/firebase.dart';
import 'package:vivant/utils/logger.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Adjust logging output as needed while developing
  Logger.globalLevel = LogLevel.verbose;
  Logger.globalPrefix = Constants.strings.appSlug;
  Logger.globalUsePrint = true;

  // Load environment variables
  await dotenv.load(fileName: '.env');

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(600, 800),
      minimumSize: Size(300, 400),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
    });
  }

  // Initialize Firebase, crash logging, etc.
  await initializeFirebase();

  // Initialize services
  final convexUrl = dotenv.env['CONVEX_URL'] ?? '';

  final authService = AuthService();
  final convexService = ConvexService(baseUrl: convexUrl);

  runApp(Vivant(authService: authService, convexService: convexService));
}

class Vivant extends StatelessWidget {
  final AuthService authService;
  final ConvexService convexService;

  const Vivant({
    super.key,
    required this.authService,
    required this.convexService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            convexService: convexService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ListsProvider(convexService: convexService),
        ),
      ],
      child: MaterialApp(
        title: 'Vivant',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF8F7F5),
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            background: const Color(0xFFF8F7F5),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8F7F5),
            elevation: 0,
            foregroundColor: Colors.black,
            centerTitle: false,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey,
            elevation: 8,
          ),
        ),
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.state) {
      case AuthState.initial:
      case AuthState.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthState.authenticated:
        return const AppShell();
      case AuthState.unauthenticated:
      case AuthState.error:
        return const LoginScreen();
    }
  }
}
