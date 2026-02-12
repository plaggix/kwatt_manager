import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_appliance_page.dart';
import 'history_page.dart';
import 'package:kwatt_manager/auth_wrapper.dart';

class ApplianceListPage extends StatefulWidget {
  const ApplianceListPage({super.key});

  @override
  State<ApplianceListPage> createState() => _ApplianceListPageState();
}

class _ApplianceListPageState extends State<ApplianceListPage> {
  late Stream<List<Map<String, dynamic>>> _applianceStream;
  bool isEneoCut = false;
  DateTime? _lastAlertTime;

  // Couleurs du thème
  final Color primaryGreen = const Color(0xFF2ECC71);
  final Color secondaryOrange = const Color(0xFFF39C12);
  final Color dangerRed = const Color(0xFFE74C3C);
  final Color bgGrey = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _applianceStream = Supabase.instance.client
        .from('appliances')
        .stream(primaryKey: ['id'])
        .order('priority', ascending: true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: _buildAppBar(context),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _applianceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final appliances = snapshot.data!;
          double totalWatts = 0;
          for (var item in appliances) {
            if (item['is_on'] == true) totalWatts += item['power_watts'];
          }

          double limitWatts = isEneoCut ? 500 : 3300;
          double chargePercent = (totalWatts / limitWatts).clamp(0.0, 1.0);

          _handleOverloadLogic(totalWatts, limitWatts, appliances);

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildConsumptionDashboard(totalWatts, limitWatts, chargePercent),
                      if (totalWatts > limitWatts) _buildAlertCard(appliances, limitWatts, totalWatts),
                      const SizedBox(height: 25),
                      _buildSectionTitle("Mes Équipements", appliances.length),
                      const SizedBox(height: 15),
                      _buildResponsiveGrid(constraints, appliances),
                      const SizedBox(height: 100), // Espace pour le FAB
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        elevation: 4,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddAppliancePage()),
        ),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("APPAREIL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- WIDGETS DE STRUCTURE ---

 PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true, // Centré pour un look plus moderne avec le logo
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      // REMPLACEMENT DU TEXTE PAR LE LOGO
      title: Image.asset(
        'assets/logo_app.png', 
        height: 60, 
        fit: BoxFit.contain,
      ),
      actions: [
        // AJOUT DU BOUTON ACTUALISER
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2ECC71)),
          tooltip: "Actualiser la liste",
          onPressed: () {
            setState(() {
              // On ré-initialise le stream pour forcer la reconnexion à Supabase
              _initStream();
            });
            // Petit message de confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mise à jour des équipements...'),
                duration: Duration(milliseconds: 800),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.history_rounded), 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()))
        ),
        IconButton(
          icon: const Icon(Icons.account_circle_outlined), 
          onPressed: () => _showAccountDialog(context)
        ),
      ],
    );
  }

  Widget _buildConsumptionDashboard(double current, double limit, double percent) {
    bool isOver = current > limit;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isEneoCut ? "Mode Onduleur" : "Mode Secteur", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(isEneoCut ? Icons.battery_charging_full_rounded : Icons.bolt_rounded, color: isEneoCut ? secondaryOrange : primaryGreen, size: 20),
                      const SizedBox(width: 5),
                      Text(isEneoCut ? "Batterie Active" : "Eneo Disponible", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              Switch.adaptive(
                value: isEneoCut,
                activeColor: secondaryOrange,
                onChanged: (v) => setState(() => isEneoCut = v),
              )
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("CHARGE TOTALE", style: TextStyle(letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.w900),
                      children: [
                        TextSpan(text: "${current.toInt()}"),
                        TextSpan(text: " / ${limit.toInt()} W", style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[100],
                      color: percent > 0.8 ? dangerRed : primaryGreen,
                    ),
                  ),
                  Text("${(percent * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(BoxConstraints constraints, List<Map<String, dynamic>> appliances) {
    int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
    double childAspectRatio = constraints.maxWidth > 600 ? 2.5 : 4.5;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: appliances.length,
      itemBuilder: (context, index) => _buildApplianceCard(appliances[index]),
    );
  }

  Widget _buildApplianceCard(Map<String, dynamic> item) {
    bool isOn = item['is_on'] ?? false;
    Color priorityColor = _getPriorityColor(item['priority']);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isOn ? Colors.white : Colors.grey[100]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOn ? primaryGreen.withOpacity(0.1) : Colors.transparent),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: (isOn ? priorityColor : Colors.grey).withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.power_settings_new_rounded, color: isOn ? priorityColor : Colors.grey),
        ),
        title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold, color: isOn ? Colors.black87 : Colors.grey, decoration: isOn ? null : TextDecoration.lineThrough)),
        subtitle: Text("${item['power_watts']} Watts", style: TextStyle(color: isOn ? primaryGreen : Colors.grey, fontWeight: FontWeight.w500)),
        trailing: Switch.adaptive(
          value: isOn,
          activeColor: primaryGreen,
          onChanged: (val) async {
            await Supabase.instance.client.from('appliances').update({'is_on': val}).eq('id', item['id']);
          },
        ),
      ),
    );
  }

  Widget _buildAlertCard(List<Map<String, dynamic>> appliances, double limit, double current) {
    final toTurnOff = appliances.where((a) => a['priority'] != 'critical' && a['is_on'] == true).toList()
      ..sort((a, b) => a['priority'] == 'secondary' ? -1 : 1);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dangerRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dangerRed.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: dangerRed),
              const SizedBox(width: 10),
              const Text("SURCHARGE DÉTECTÉE !", style: TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Veuillez éteindre en priorité :", style: TextStyle(color: Colors.red[900], fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: turnOffSuggestions(toTurnOff),
          )
        ],
      ),
    );
  }

  // --- LOGIQUE MÉTIER ---

  void _handleOverloadLogic(double current, double limit, List<Map<String, dynamic>> appliances) {
    if (current > limit) {
      final now = DateTime.now();
      if (_lastAlertTime == null || now.difference(_lastAlertTime!).inMinutes >= 1) {
        _lastAlertTime = now;
        Supabase.instance.client.from('overload_history').insert({
          'total_watts': current,
          'limit_watts': limit,
          'appliance_count': appliances.where((a) => a['is_on'] == true).length,
        }).then((_) => debugPrint("🚨 Surcharge enregistrée !"));
      }
    }
  }

  // --- HELPER METHODS ---

  List<Widget> turnOffSuggestions(List<Map<String, dynamic>> list) {
    return list.take(2).map((a) => Chip(
      backgroundColor: Colors.white,
      side: BorderSide(color: dangerRed),
      label: Text("${a['name']} (${a['power_watts']}W)", style: TextStyle(color: dangerRed, fontSize: 11, fontWeight: FontWeight.bold)),
    )).toList();
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: Colors.blueGrey[50], borderRadius: BorderRadius.circular(20)),
          child: Text("$count appareils", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucun appareil enregistré", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const Text("Appuyez sur + pour commencer", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'critical': return dangerRed;
      case 'important': return secondaryOrange;
      default: return Colors.blueGrey;
    }
  }

  void _showAccountDialog(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Mon Compte"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 30, backgroundColor: Color(0xFF2ECC71), child: Icon(Icons.person, color: Colors.white, size: 30)),
            const SizedBox(height: 15),
            Text("${user?.email}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Partagez ce compte pour synchroniser la maison.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red, elevation: 0),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthWrapper()), (route) => false);
              }
            },
            child: const Text("DECONNEXION"),
          ),
        ],
      ),
    );
  }
}