import 'package:flutter/material.dart';
import 'diagnostics/route_trace.dart';
import 'screens/welcome_screen.dart';

void main() => runApp(const HauntedMansionApp());

class HauntedMansionApp extends StatelessWidget {
  const HauntedMansionApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Campus Crew: After Dark',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D39B4)),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        navigatorObservers: [routeTrace],
        home: const WelcomeScreen(),
      );
}
