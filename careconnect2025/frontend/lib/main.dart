import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'config/router/app_router.dart';
import 'services/auth_migration_helper.dart';
import 'services/messaging_service.dart';
import 'services/video_call_service.dart';
import 'config/theme/app_theme.dart';
import 'config/utils/responsive_utils.dart';
import 'config/utils/web_utils.dart';

// Background message handler for Firebase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only do critical initialization synchronously
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Performance optimization: Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Configure URL strategy for web to remove hash from URLs
  usePathUrlStrategy();

  // Load environment quickly
  await dotenv.load();

  // Create providers (don't initialize them yet)
  final userProvider = UserProvider();
  final themeProvider = ThemeProvider();

  // Start the app immediately, initialize services in background
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const CareConnectApp(),
    ),
  );

  // Initialize heavy services in background after app starts
  _initializeServicesInBackground(userProvider);
}

// Background initialization to not block app startup
Future<void> _initializeServicesInBackground(UserProvider userProvider) async {
  try {
    // Run these in parallel for faster initialization
    await Future.wait([
      _bootstrap(),
      MessagingService.initialize(),
      VideoCallService.initializeService(),
      userProvider.initializeUser(),
      _handleAuthMigration(),
    ], eagerError: false); // Don't stop if one fails

    print('✅ Background services initialized');
  } catch (e) {
    print('⚠️ Some background services failed to initialize: $e');
  }
}

Future<void> _handleAuthMigration() async {
  try {
    final migrationResult = await AuthMigrationHelper.migrateAuthData();
    if (!migrationResult.isSuccess && migrationResult.errorMessage != null) {
      debugPrint('Auth migration warning: ${migrationResult.errorMessage}');
    }
  } catch (e) {
    debugPrint('Auth migration error: $e');
  }
}

Future<void> _bootstrap() async {
  // Performance optimization: Warm up system caches
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize web-specific optimizations
  if (kIsWeb) {
    WebUtils.initializeWebOptimizations();
  }
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: 'CareConnect',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme.copyWith(
        // Additional theme customizations
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: AppTheme.lightTheme.textTheme.apply(fontFamily: 'Roboto'),
        // Platform-specific theme adjustments
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
          },
        ),
        // Adjust card elevation for iOS vs Android
        cardTheme: CardThemeData(
          elevation: kIsWeb ? 2 : (ResponsiveUtils.isIOS ? 1 : 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.isIOS ? 12 : 8),
          ),
        ),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        // Additional dark theme customizations
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: AppTheme.darkTheme.textTheme.apply(fontFamily: 'Roboto'),
        // Platform-specific theme adjustments
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.linux: ZoomPageTransitionsBuilder(),
            TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
          },
        ),
        // Adjust card elevation for iOS vs Android
        cardTheme: CardThemeData(
          elevation: kIsWeb ? 3 : (ResponsiveUtils.isIOS ? 2 : 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.isIOS ? 12 : 8),
          ),
        ),
      ),
      routerConfig: appRouter,
      // Performance optimization and responsive behavior
      builder: (context, child) {
        // Handle text scaling for accessibility
        final mediaQuery = MediaQuery.of(context);
        final textScaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.2);

        // Apply platform-specific adjustments
        Widget updatedChild = child!;

        // Apply safe area with platform awareness
        updatedChild = SafeArea(
          bottom: !ResponsiveUtils.isWeb, // Web doesn't need bottom padding
          child: updatedChild,
        );

        // Apply the adjusted MediaQuery
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
            // Ensure proper viewport settings across devices
            devicePixelRatio: ResponsiveUtils.isWeb
                ? mediaQuery.devicePixelRatio
                : mediaQuery.devicePixelRatio.clamp(1.0, 3.0),
          ),
          child: updatedChild,
        );
      },
    );
  }
}
