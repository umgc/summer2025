import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'providers/user_provider.dart';
import 'config/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure URL strategy for web to remove hash from URLs
  usePathUrlStrategy();

  await dotenv.load();
  await _bootstrap(); // load env, init DI, etc.
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const CareConnectApp(),
    ),
  );
}

Future<void> _bootstrap() async {
  // Here you could read .env, set up logging, Firebase, Sentry, …
}

class CareConnectApp extends StatelessWidget {
  const CareConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CareConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: appRouter,
    );
  }
}
