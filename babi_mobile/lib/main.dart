// lib/main.dart (debug helper - updated)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import your real providers/screens but do NOT instantiate anything heavy in top-level constructors.
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/supplier_provider.dart';
import 'providers/inventory_provider.dart';

import 'services/auth_service.dart';
import 'screens/babi_welcome_screen.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/products_list_screen.dart';
import 'screens/add_product_screen.dart';   // ✅ import AddProductScreen
import 'screens/product_form_screen.dart';
import 'screens/suppliers_list_screen.dart';
import 'screens/supplier_form_screen.dart';
import 'screens/inventory_list_screen.dart';
import 'screens/inventory_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.empty);
  };

  runZonedGuarded<Future<void>>(() async {
    final authService = AuthService();

    runApp(
      MyDebugApp(authService: authService),
    );
  }, (error, stack) {
    debugPrint('UNCAUGHT ZONED ERROR: $error');
    debugPrint('$stack');
  });
}

class MyDebugApp extends StatefulWidget {
  final AuthService authService;
  const MyDebugApp({required this.authService, super.key});

  @override
  State<MyDebugApp> createState() => _MyDebugAppState();
}

class _MyDebugAppState extends State<MyDebugApp> {
  Object? _startupError;
  StackTrace? _startupStack;

  @override
  void initState() {
    super.initState();
    _safeInit();
  }

  Future<void> _safeInit() async {
    try {
      // Put any synchronous startup checks here if needed.
    } catch (e, st) {
      setState(() {
        _startupError = e;
        _startupStack = st;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_startupError != null) {
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Startup error')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              'Startup exception:\n\n${_startupError.toString()}\n\nStack:\n${_startupStack.toString()}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(widget.authService)),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: MaterialApp(
        title: 'Babi Supply Chain',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: BabiWelcomeScreen.routeName,
        routes: {
          BabiWelcomeScreen.routeName: (_) => const BabiWelcomeScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),

          // products
          '/products': (_) => const ProductsListScreen(),
          AddProductScreen.routeName: (_) => const AddProductScreen(), // ✅ fixed
          ProductFormScreen.routeName: (_) => const ProductFormScreen(),

          // suppliers
          '/suppliers': (_) => SuppliersListScreen(),
          SupplierFormScreen.routeName: (_) => SupplierFormScreen(),

          // inventories
          '/inventories': (_) => InventoryListScreen(),
          InventoryFormScreen.routeName: (_) => InventoryFormScreen(),
        },
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails details) {
            final exception = details.exception;
            final stack = details.stack;
            return Scaffold(
              appBar: AppBar(title: const Text('Widget error')),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  'Widget exception:\n\n${exception.toString()}\n\nStack:\n${stack.toString()}',
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            );
          };
          return child!;
        },
      ),
    );
  }
}
