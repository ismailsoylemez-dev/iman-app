import 'package:flutter/material.dart';
import '../services/zikir_storage_service.dart';
import '../services/hive_storage_service.dart';
import '../services/dua_service.dart';
import '../models/dua_model.dart';
import '../models/zikir_stats_model.dart';
import '../utils/app_colors.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final DuaService _duaService = DuaService();

  ZikirStats? _zikirStats;
  int _favoriteDuaCount = 0;
  int _streak = 0;
  List<int> _last7Days = const [];
  List<({DuaModel dua, int count})> _topDuas = const [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ZikirStorageService.getZikirStats();
    final favorites = HiveStorageService.getFavoriteIds();
    final streak = await ZikirStorageService.getCurrentStreak();
    final weekCounts = await ZikirStorageService.getLast7DaysCounts();

    final topRecords = HiveStorageService.getTopReadDuas(limit: 5);
    List<({DuaModel dua, int count})> topDuas = [];
    if (topRecords.isNotEmpty) {
      final allDuas = await _duaService.getAllDuas();
      for (final record in topRecords) {
        final match = allDuas.where((d) => d.id == record.id);
        if (match.isNotEmpty) {
          topDuas.add((dua: match.first, count: record.readCount));
        }
      }
    }

    if (mounted) {
      setState(() {
        _zikirStats = stats;
        _favoriteDuaCount = favorites.length;
        _streak = streak;
        _last7Days = weekCounts;
        _topDuas = topDuas;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _zikirStats;

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: stats == null
          ? Center(child: CircularProgressIndicator(color: AppColors.primary(context)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStreakCard(),
                const SizedBox(height: 20),
                Text('Zikir İstatistikleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary(context))),
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
                const SizedBox(height: 20),
                Text('Haftalık Zikir Grafiği', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary(context))),
                const SizedBox(height: 10),
                _buildWeeklyBarChart(),
                const SizedBox(height: 24),
                Text('Dua Geçmişi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary(context))),
                const SizedBox(height: 10),
                _buildStatCard('Favori Dualar', _favoriteDuaCount),
                const SizedBox(height: 20),
                Text('En Çok Okunan 5 Dua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary(context))),
                const SizedBox(height: 10),
                _buildTopDuasList(),
              ],
            ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.streakOrange.withValues(alpha: 0.85), AppColors.streakOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department_rounded, color: AppColors.onPrimary, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_streak günlük seri',
                  style: const TextStyle(color: AppColors.onPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Zikir çekmeye her gün devam et!',
                  style: TextStyle(color: AppColors.onPrimarySecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart() {
    if (_last7Days.isEmpty) return const SizedBox.shrink();
    final maxVal = _last7Days.reduce((a, b) => a > b ? a : b);
    final now = DateTime.now();
    const dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final date = now.subtract(Duration(days: 6 - index));
          final value = _last7Days[index];
          final heightRatio = maxVal > 0 ? value / maxVal : 0.0;
          final isToday = index == 6;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$value', style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context))),
              const SizedBox(height: 4),
              Container(
                width: 18,
                height: 6 + (heightRatio * 80),
                decoration: BoxDecoration(
                  color: isToday ? AppColors.accent(context) : AppColors.primary(context).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dayLabels[date.weekday - 1],
                style: TextStyle(
                  fontSize: 11,
                  color: isToday ? AppColors.primary(context) : AppColors.textSecondary(context),
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTopDuasList() {
    if (_topDuas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Text(
          'Henüz okuma verisi yok. Dua okudukça burada listelenecek.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary(context)),
        ),
      );
    }

    return Column(
      children: _topDuas.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final item = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: rank <= 3 ? AppColors.accent(context) : AppColors.primary(context).withValues(alpha: 0.15),
                foregroundColor: rank <= 3 ? AppColors.primary(context) : AppColors.primary(context),
                child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.dua.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.text(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('${item.count}×', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary(context))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.accent(context))),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
