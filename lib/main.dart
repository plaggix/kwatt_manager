import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kwatt_manager/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://iospvclagkkbeqgyitqp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlvc3B2Y2xhZ2trYmVxZ3lpdHFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2ODcxNDgsImV4cCI6MjA4NTI2MzE0OH0.9QZXv6IMrmt9JmnC7wGGBGEUlkJ2l9eOswvsZoGUoVE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
 Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kwatt Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
         seedColor: const Color(0xFF2ECC71),
         primary: const Color(0xFF2ECC71),
        ),
       appBarTheme: const AppBarTheme(
         centerTitle: true,
         elevation: 2,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}