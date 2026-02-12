import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final Color _brandRed = const Color(0xFFE74C3C);
  final Color _brandGreen = const Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
        title: const Text(
          "Journal d'activité",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('overload_history')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final logs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final date = DateTime.parse(log['created_at']).toLocal();
              
              // Calcul du dépassement pour le design
              final double total = (log['total_watts'] as num).toDouble();
              final double limit = (log['limit_watts'] as num).toDouble();
              final int excess = (total - limit).toInt();

              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 400 + (index * 100).clamp(0, 400)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _buildHistoryCard(date, total, limit, excess),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(DateTime date, double total, double limit, int excess) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barre latérale d'intensité
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: excess > 500 ? _brandRed : Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                         DateFormat('dd/MM/yyyy').format(date),
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          DateFormat('HH:mm').format(date),
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        _buildStatTile("Consommé", "${total.toInt()}W", _brandRed),
                        const SizedBox(width: 16),
                        _buildStatTile("Limite", "${limit.toInt()}W", Colors.blueGrey),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _brandRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "+$excess W",
                            style: TextStyle(color: _brandRed, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: _brandGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_rounded, size: 80, color: _brandGreen),
          ),
          const SizedBox(height: 24),
          const Text(
            "Aucun incident !",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Votre gestion énergétique est parfaite.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}