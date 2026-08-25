import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class IslamicCalendarEvent {
  final String id;
  final DateTime date;
  final String type; // kandil | bayram | resmi_tatil | ozel
  final String name;
  final String description;

  const IslamicCalendarEvent({
    required this.id,
    required this.date,
    required this.type,
    required this.name,
    required this.description,
  });

  factory IslamicCalendarEvent.fromJson(Map<String, dynamic> json) {
    return IslamicCalendarEvent(
      id: json['id'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      type: json['type'] as String? ?? 'ozel',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Color get color {
    switch (type) {
      case 'kandil':
        return const Color(0xFFE53935); // Kırmızı
      case 'bayram':
        return const Color(0xFF2E7D32); // Yeşil
      case 'resmi_tatil':
        return const Color(0xFF1E88E5); // Mavi
      default:
        return const Color(0xFFFBC02D); // Sarı (Özel Gün)
    }
  }

  String get emoji {
    switch (type) {
      case 'kandil':
        return '🕌';
      case 'bayram':
        return '🌙';
      case 'resmi_tatil':
        return '🏛️';
      default:
        return '⭐';
    }
  }
}

/// Önümüzdeki 7 günü gösteren, kandil/bayram/resmi tatil/özel gün
/// işaretleyicileri içeren yatay İslami takvim widget'ı.
class IslamicCalendarWidget extends StatefulWidget {
  const IslamicCalendarWidget({super.key});

  @override
  State<IslamicCalendarWidget> createState() => _IslamicCalendarWidgetState();
}

class _IslamicCalendarWidgetState extends State<IslamicCalendarWidget> {
  List<IslamicCalendarEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/islamic_calendar.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final events = jsonList.map((e) => IslamicCalendarEvent.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) {
        setState(() {
          _events = events;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<IslamicCalendarEvent> _eventsOn(DateTime day) {
    return _events.where((e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day).toList();
  }

  void _showDayDetail(DateTime day, List<IslamicCalendarEvent> events) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.day}.${day.month}.${day.year}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.text(context)),
              ),
              const SizedBox(height: 12),
              if (events.isEmpty)
                Text('Bu gün için özel bir işaret bulunmuyor.', style: TextStyle(color: AppColors.textSecondary(context)))
              else
                ...events.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name, style: TextStyle(fontWeight: FontWeight.bold, color: e.color)),
                                Text(e.description, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary(context))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i)));
    const weekdayShort = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    if (_isLoading) {
      return const SizedBox(height: 84, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.textSecondary(context)),
              const SizedBox(width: 6),
              Text('İslami Takvim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text(context))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: days.map((day) {
              final events = _eventsOn(day);
              final isToday = day.day == today.day && day.month == today.month && day.year == today.year;
              return Expanded(
                child: InkWell(
                  onTap: () => _showDayDetail(day, events),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        Text(
                          weekdayShort[day.weekday - 1],
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary(context)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.emeraldGreen : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                              color: isToday ? Colors.white : AppColors.text(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        SizedBox(
                          height: 6,
                          child: events.isEmpty
                              ? null
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: events
                                      .take(3)
                                      .map((e) => Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
                                          ))
                                      .toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
