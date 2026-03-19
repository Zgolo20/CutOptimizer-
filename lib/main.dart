import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.loadSavedSettings();
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const CutOptimizerApp(),
    ),
  );
}

class CutOptimizerApp extends StatelessWidget {
  const CutOptimizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CutOptimizer Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF111111),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF888888)),
        ),
        fontFamily: 'monospace',
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF111111),
          contentTextStyle: TextStyle(
            fontFamily: 'monospace',
            color: Colors.white,
            fontSize: 13,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
