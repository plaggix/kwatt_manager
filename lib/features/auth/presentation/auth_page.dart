import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_setup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscureText = true;

  // Logique métier conservée strictement à l'identique
  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vérifiez votre boîte mail !'), backgroundColor: Colors.green),
          );
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. IMAGE DE FOND AVEC DÉGRADÉ (En bas)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/image_connexion.png',
                  fit: BoxFit.cover,
                ),
                // Le dégradé pour fondre l'image dans le blanc du haut
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.4],
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. CONTENU SCROLLABLE
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // LOGO PLUS GROS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo_app.png', height: 45), // Taille augmentée
                    const SizedBox(width: 12),
                    const Text(
                      'Kwatt-Manager',
                      style: TextStyle(
                        fontSize: 26, // Taille augmentée
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D2939),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  _isSignUp ? 'Créer un compte' : 'Connexion',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2939),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isSignUp ? 'Inscrivez-vous pour commencer' : 'Accédez à votre espace énergétique',
                  style: const TextStyle(fontSize: 16, color: Color(0xFF667085)),
                ),
                const SizedBox(height: 30),

                // 3. LE FORMULAIRE (BIEN VISIBLE SUR LE FOND)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Email"),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("Entrez votre email", Icons.email_outlined),
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Mot de passe"),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscureText,
                          decoration: _inputDecoration("Entrez votre mot de passe", Icons.lock_outline).copyWith(
                            suffixIcon: TextButton(
                              onPressed: () => setState(() => _obscureText = !_obscureText),
                              child: Text(_obscureText ? "Afficher" : "Masquer", 
                                style: const TextStyle(color: Color(0xFF667085), fontSize: 13)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        _isLoading
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFF28A745)))
                            : SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _handleAuth,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF28A745),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _isSignUp ? "S'inscrire" : "Se connecter",
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 25),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(_isSignUp ? "Déjà un compte ? " : "Nouveau ? ", 
                                style: const TextStyle(color: Color(0xFF667085), fontSize: 15)),
                              GestureDetector(
                                onTap: () => setState(() => _isSignUp = !_isSignUp),
                                child: Text(
                                  _isSignUp ? "Se connecter" : "Créer un compte",
                                  style: const TextStyle(
                                    color: Color(0xFF28A745), 
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100), // Espace pour laisser voir l'image en dessous
              ],
            ),
          ),
          
          // Bouton retour si Inscription (comme sur l'image 2)
          if (_isSignUp)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D2939), size: 20),
                  onPressed: () => setState(() => _isSignUp = false),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF344054)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 22, color: const Color(0xFF667085)),
      hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF28A745), width: 2),
      ),
    );
  }
}