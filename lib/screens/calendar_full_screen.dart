import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import '../utils/app_colors.dart';
import '../widgets/islamic_calendar_widget.dart';

/// Hicri ay/yıl bazında gezinilebilen tam takvim ekranı.
class CalendarFullScreen extends StatefulWidget {
  const CalendarFullScreen({super.key});

  @override
  State<CalendarFullScreen> createState() => _CalendarFullScreenState();
}

class _CalendarFullScreenState extends State<CalendarFullScreen> {
  late int _hYear;
  late int _hMonth;
  int? _selectedDay;
  List<IslamicCalendarEvent> _events = [];
  bool _isLoading = true;

  static const List<String> _weekdayShort = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  void initState() {
    super.initState();
    HijriCalendar.setLocal('tr');
    final today = HijriCalendar.now();
    _hYear = today.hYear;
    _hMonth = today.hMonth;
    _selectedDay = today.hDay;
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

  void _changeMonth(int delta) {
    setState(() {
      int newMonth = _hMonth + delta;
      int newYear = _hYear;
      if (newMonth > 12) {
        newMonth = 1;
        newYear++;
      } else if (newMonth < 1) {
        newMonth = 12;
        newYear--;
      }
      _hMonth = newMonth;
      _hYear = newYear;
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthNames = HijriCalendar().getMonths();
    final monthName = monthNames[_hMonth] ?? '';
    final daysInMonth = HijriCalendar().getDaysInMonth(_hYear, _hMonth);
    final firstDayGregorian = HijriCalendar().hijriToGregorian(_hYear, _hMonth, 1);
    final leadingBlanks = (firstDayGregorian.weekday - 1) % 7; // Pazartesi = 1

    final selectedGregorian = _selectedDay != null ? HijriCalendar().hijriToGregorian(_hYear, _hMonth, _selectedDay!) : null;
    final selectedEvents = selectedGregorian != null ? _eventsOn(selectedGregorian) : <IslamicCalendarEvent>[];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('İslami Takvim'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMonthNavigator(monthName),
                  const SizedBox(height: 16),
                  _buildWeekdayHeader(),
                  const SizedBox(height: 8),
                  _buildDayGrid(daysInMonth, leadingBlanks),
                  const SizedBox(height: 16),
                  if (_selectedDay != null && selectedGregorian != null)
                    _buildSelectedDayCard(selectedGregorian, selectedEvents),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthNavigator(String monthName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.primary(context),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            '$monthName $_hYear H',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary(context)),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.primary(context),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _weekdayShort
          .map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary(context)),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDayGrid(int daysInMonth, int leadingBlanks) {
    final totalCells = leadingBlanks + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rowCount * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final dayNumber = index - leadingBlanks + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }

        final gregorian = HijriCalendar().hijriToGregorian(_hYear, _hMonth, dayNumber);
        final events = _eventsOn(gregorian);
        final isSelected = _selectedDay == dayNumber;
        final today = HijriCalendar.now();
        final isToday = today.hYear == _hYear && today.hMonth == _hMonth && today.hDay == dayNumber;

        return InkWell(
          onTap: () => setState(() => _selectedDay = dayNumber),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary(context)
                  : isToday
                      ? AppColors.accent(context).withValues(alpha: 0.4)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isToday && !isSelected ? Border.all(color: AppColors.primary(context), width: 1) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.onPrimary : AppColors.text(context),
                  ),
                ),
                Text(
                  '${gregorian.day}/${gregorian.month}',
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected ? AppColors.onPrimarySecondary : AppColors.textSecondary(context),
                  ),
                ),
                if (events.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 1),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: events.first.color, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayCard(DateTime gregorian, List<IslamicCalendarEvent> events) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Miladi: ${gregorian.day}.${gregorian.month}.${gregorian.year}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text(context)),
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            Text(
              'Bu gün için özel bir hadise bulunmuyor.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
            )
          else
            ...events.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.emoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: e.color)),
                          Text(e.description, style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
