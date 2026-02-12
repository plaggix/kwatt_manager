import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAppliancePage extends StatefulWidget {
  const AddAppliancePage({super.key});

  @override
  State<AddAppliancePage> createState() => _AddAppliancePageState();
}

class _AddAppliancePageState extends State<AddAppliancePage> {
  final _nameController = TextEditingController();
  final _powerController = TextEditingController();
  String _priority = 'secondary';
  bool _isLoading = false;

  final Color _brandGreen = const Color(0xFF2ECC71);

  Future<void> _saveAppliance() async {
    if (_nameController.text.trim().isEmpty || _powerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;

    try {
      await Supabase.instance.client.from('appliances').insert({
        'user_id': user!.id,
        'profile_id': user.id,
        'name': _nameController.text.trim(),
        'power_watts': int.parse(_powerController.text.trim()),
        'priority': _priority,
        'is_on': true,
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Nouvel appareil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER VISUEL ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _brandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: _brandGreen, size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Enregistrez vos appareils pour que Kwatt-Manager optimise votre consommation.",
                        style: TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // --- CHAMP NOM ---
              Text("IDENTIFICATION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'appareil',
                  hintText: 'ex: Climatiseur, Frigo...',
                  prefixIcon: const Icon(Icons.label_outline_rounded),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _brandGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 24),

              // --- CHAMP PUISSANCE ---
              Text("PUISSANCE ÉLECTRIQUE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1)),
              const SizedBox(height: 12),
              TextField(
                controller: _powerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Consommation (en Watts)',
                  hintText: 'ex: 1500',
                  prefixIcon: const Icon(Icons.speed_rounded),
                  suffixText: 'W',
                  suffixStyle: TextStyle(fontWeight: FontWeight.bold, color: _brandGreen),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _brandGreen, width: 2)),
                ),
              ),
              const SizedBox(height: 24),

              // --- CHAMP PRIORITÉ ---
              Text("IMPORTANCE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.1)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: [
                  _buildDropdownItem('critical', 'Critique', 'Indispensable', Colors.redAccent),
                  _buildDropdownItem('important', 'Important', 'Prioritaire', Colors.orange),
                  _buildDropdownItem('secondary', 'Secondaire', 'Optionnel', Colors.blueGrey),
                ],
                onChanged: (v) => setState(() => _priority = v!),
              ),

              const SizedBox(height: 48),

              // --- BOUTON DE SAUVEGARDE ---
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _saveAppliance,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_rounded),
                            SizedBox(width: 10),
                            Text('Enregistrer l\'appareil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

DropdownMenuItem<String> _buildDropdownItem(String value, String title, String subtitle, Color color) {
  return DropdownMenuItem(
    value: value,
    // On utilise un Container pour s'assurer que le contenu ne dépasse pas
    child: SizedBox(
      width: 200, // Ajuste selon tes besoins
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          // Le titre et le sous-titre sur la même ligne ou très serrés
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 8),
          Text("($subtitle)", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.normal)),
        ],
      ),
    ),
  );
}
}