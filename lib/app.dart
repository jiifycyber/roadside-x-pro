import 'package:flutter/material.dart';
import 'models/entities.dart';
import 'screens/login_screen.dart';
import 'screens/phase4_shell.dart';
import 'screens/technician_portal.dart';
import 'state/app_state.dart';

class RoadsideXApp extends StatefulWidget {
  const RoadsideXApp({super.key});
  @override
  State<RoadsideXApp> createState() => _RoadsideXAppState();
}

class _RoadsideXAppState extends State<RoadsideXApp> {
  late final Future<AppState> _state = AppState.create();
  UserRole? role;
  String displayName = '';

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00D9FF);
    const violet = Color(0xFF7C4DFF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roadside X Pro Interface',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFF03050D),
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: violet,
          surface: Color(0xFF0B1022),
          error: Color(0xFFFF5470),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withValues(alpha: .09),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: cyan.withValues(alpha: .12),
          side: BorderSide(color: cyan.withValues(alpha: .35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: .055),
          labelStyle: const TextStyle(color: Color(0xFFB6C5E2)),
          prefixIconColor: cyan,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cyan.withValues(alpha: .28)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: cyan.withValues(alpha: .22)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: cyan, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB8F6FF),
            side: BorderSide(color: cyan.withValues(alpha: .45)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      home: FutureBuilder<AppState>(
        future: _state,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Scaffold(
              body: Center(
                child: Text('Unable to load app data: ${snapshot.error}'),
              ),
            );
          if (!snapshot.hasData)
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          if (role == null)
            return LoginScreen(
              onLogin: (newRole, name) => setState(() {
                role = newRole;
                displayName = name;
              }),
            );
          if (role == UserRole.technician)
            return TechnicianPortal(
              state: snapshot.data!,
              technicianName: displayName,
              onLogout: () => setState(() => role = null),
            );
          return Phase4Shell(
            state: snapshot.data!,
            role: role!,
            displayName: displayName,
            onLogout: () => setState(() {
              role = null;
              displayName = '';
            }),
          );
        },
      ),
    );
  }
}
