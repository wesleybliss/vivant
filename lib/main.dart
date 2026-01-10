import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:vivant/domain/constants/constants.dart';
import 'package:vivant/providers/auth_provider.dart';
import 'package:vivant/providers/lists_provider.dart';
import 'package:vivant/providers/settings_provider.dart';
import 'package:vivant/screens/auth/login_screen.dart';
import 'package:vivant/screens/main_navigation_screen.dart';
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
  
  runApp(Vivant(
    authService: authService,
    convexService: convexService,
  ));
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
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Vivant',
            themeMode: settings.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6495ED), // Cornflower blue
                brightness: Brightness.light,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              chipTheme: ChipThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6495ED),
                brightness: Brightness.dark,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              chipTheme: ChipThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: const AuthGate(),
            debugShowCheckedModeBanner: false,
          );
        },
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
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthState.authenticated:
        return const MainNavigationScreen();
      case AuthState.unauthenticated:
      case AuthState.error:
        return const LoginScreen();
    }
  }
}
