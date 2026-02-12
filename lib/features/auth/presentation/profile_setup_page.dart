import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'appliance_list_page.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  String? _selectedType;
  String _selectedPower = '5A';
  bool _isLoading = false;

  final Color _brandGreen = const Color(0xFF2ECC71);
  final Color _darkGrey = const Color(0xFF1A1A1A);


 Future<void> _fetchExistingProfile() async {
  setState(() => _isLoading = true);
  final user = Supabase.instance.client.auth.currentUser;

  try {
    
    final data = await Supabase.instance.client
        .from('profiles')
        .select() 
        .eq('id', user!.id)
        .maybeSingle();

    if (data != null && mounted) {
      setState(() {
        _selectedType = data['user_type'];
        // Si tu as une liste d'appareils stockée, mets-la à jour ici
      });
    }
  } catch (e) {
    debugPrint('Erreur lors de l\'actualisation : $e');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  Future<void> _saveProfile() async {
    if (_selectedType == null) return;
    
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;

    try {
      await Supabase.instance.client.from('profiles').upsert({
        'id': user!.id,
        'user_type': _selectedType,
        'full_name': 'Utilisateur Kwatt', 
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const ApplianceListPage()),
          (route) => false, 
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          )
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: _darkGrey), 
        title: Image.asset(
         'assets/logo_app.png', 
         height: 60, 
         fit: BoxFit.contain
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Physics ajouté pour éviter les rebonds bizarres sur petits écrans
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: ConstrainedBox(
                  // On force la taille minimum à la taille de l'écran
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Remplace le Spacer
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Groupe du haut
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Votre structure",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _darkGrey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Cela nous aide à adapter les calculs de consommation.",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              _buildTypeCard('household', 'Ménage', Icons.home_rounded),
                              const SizedBox(width: 16),
                              _buildTypeCard('sme', 'Commerce', Icons.storefront_rounded),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Text(
                            "Abonnement Eneo",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _darkGrey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Calibre de votre disjoncteur (Ampères).",
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(), // Séparé pour plus de clarté
                        ],
                      ),

                      // Groupe du bas (Bouton)
                      Padding(
                        padding: const EdgeInsets.only(top: 40, bottom: 10),
                        child: _buildSubmitButton(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS DE COMPOSANTS ---

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPower,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _brandGreen),
          items: ['5A', '10A', '15A', '30A', '60A'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedPower = val!),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        onPressed: (_selectedType != null && !_isLoading) ? _saveProfile : null,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Finaliser mon profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildTypeCard(String type, String label, IconData icon) {
    bool isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? _brandGreen.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? _brandGreen : Colors.grey[200]!,
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: _brandGreen.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  icon, 
                  key: ValueKey(isSelected),
                  size: 44, 
                  color: isSelected ? _brandGreen : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label, 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? _brandGreen : _darkGrey, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}