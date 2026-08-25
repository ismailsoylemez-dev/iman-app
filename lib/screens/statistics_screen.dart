import 'package:flutter/material.dart';
import '../services/zikir_storage_service.dart';
import '../services/hive_storage_service.dart';
import '../models/zikir_stats_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFD4AF37);

  ZikirStats? _zikirStats;
  int _favoriteDuaCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ZikirStorageService.getZikirStats();
    final favorites = HiveStorageService.getFavoriteIds();
    if (mounted) {
      setState(() {
        _zikirStats = stats;
        _favoriteDuaCount = favorites.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _zikirStats;

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: stats == null
          ? const Center(child: CircularProgressIndicator(color: emeraldGreen))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Zikir İstatistikleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: emeraldGreen)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Bu Hafta', stats.thisWeek)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Bu Ay', stats.thisMonth)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Toplam', stats.allTime)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Dua Geçmişi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: emeraldGreen)),
                const SizedBox(height: 10),
                _buildStatCard('Favori Dualar', _favoriteDuaCount),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: accentGold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
