import 'package:flutter/material.dart';
import 'auth_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _data = [
    {
      "title": "Maîtrisez votre énergie",
      "desc": "Anticipez les coupures et optimisez la consommation de vos appareils au Cameroun.",
      "icon": "⚡"
    },
    {
      "title": "Stratégie Intelligente",
      "desc": "Kwatt-Manager calcule pour vous quels appareils garder allumés selon vos priorités.",
      "icon": "🧠"
    },
    {
      "title": "Économisez gros",
      "desc": "Réduisez vos factures Eneo en gérant mieux vos plages horaires d'utilisation.",
      "icon": "💰"
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond avec un léger dégradé pour la modernité
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2ECC71).withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Bouton Passer (Skip) en haut à droite
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => _navigateToAuth(),
                    child: Text(
                      "Passer",
                      style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (v) => setState(() => _currentPage = v),
                    itemCount: _data.length,
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icône stylisée
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2ECC71).withOpacity(0.2),
                                    blurRadius: 25,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Text(
                                _data[i]['icon']!,
                                style: const TextStyle(fontSize: 60),
                              ),
                            ),
                            SizedBox(height: size.height * 0.08),
                            // Titre
                            Text(
                              _data[i]['title']!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Description
                            Text(
                              _data[i]['desc']!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicateurs de page & Bouton
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    children: [
                      // Indicateurs animés
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _data.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF2ECC71)
                                  : const Color(0xFFD1D1D1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Bouton d'action principal
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2ECC71),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            if (_currentPage < _data.length - 1) {
                              _controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOutQuart,
                              );
                            } else {
                              _navigateToAuth();
                            }
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _currentPage == _data.length - 1
                                  ? "C'est parti !"
                                  : "Suivant",
                              key: ValueKey<int>(_currentPage),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
  }
}