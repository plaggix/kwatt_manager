import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/appliance_list_page.dart';
import 'features/auth/presentation/onboarding_page.dart'; 

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute l'état de la session Supabase
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      return const ApplianceListPage();
    } else {
      return const OnboardingPage();
    }
  }
}