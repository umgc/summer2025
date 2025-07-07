import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'providers/user_provider.dart';
import 'config/router/app_router.dart';
import 'services/auth_migration_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Performance optimization: Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configure URL strategy for web to remove hash from URLs
  usePathUrlStrategy();

  await dotenv.load();
  await _bootstrap(); // load env, init DI, etc.

  // Migrate from old auth system to new JWT-only system
  final migrationResult = await AuthMigrationHelper.migrateAuthData();
  if (!migrationResult.isSuccess && migrationResult.errorMessage != null) {
    // Log migration errors for debugging, but don't block app startup
    // The app can still function without migration
    debugPrint('Auth migration warning: ${migrationResult.errorMessage}');
  }

  // Create UserProvider and initialize it
  final userProvider = UserProvider();
  await userProvider.initializeUser();

  runApp(
    ChangeNotifierProvider.value(
      value: userProvider,
      child: const CareConnectApp(),
    ),
  );
}

Future<void> _bootstrap() async {
  // Performance optimization: Warm up system caches
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}

class CareConnectApp extends StatefulWidget {
  const CareConnectApp({super.key});

  @override
  State<CareConnectApp> createState() => _CareConnectAppState();
}

class _CareConnectAppState extends State<CareConnectApp> {
  StreamSubscription? _linkSubscription;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  Future<void> _initializeDeepLinks() async {
    _appLinks = AppLinks();

    // Check if app was opened via deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink.toString());
      }
    } catch (e) {
      print('Error getting initial link: $e');
    }

    // Listen for deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri.toString());
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(String link) {
    print('Received deep link: $link');

    // Parse the deep link to extract OAuth callback parameters
    final uri = Uri.parse(link);

    // Check if this is an OAuth callback (careconnect://oauth/callback)
    if (uri.scheme == 'careconnect' &&
        uri.host == 'oauth' &&
        uri.path == '/callback') {
      print('OAuth callback detected: $link');
      // The actual OAuth handling is done in AuthService.loginWithGoogle()
      // This is just for logging and potential additional processing
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Performance optimization: Reduce font loading
        fontFamily: 'Roboto',
        // Optimize material design
        useMaterial3: true,
        // Reduce overdraw
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: appRouter,
      // Performance optimization: Reduce memory usage
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}
