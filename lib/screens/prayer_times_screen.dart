import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/city_model.dart';
import '../services/prayer_time_service.dart';
import '../services/permission_service.dart';
import '../providers/prayer_times_notifier.dart';
import '../services/notification_service.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';
import '../widgets/qibla_compass_widget.dart';
import '../utils/app_colors.dart';

class PrayerTimesScreen extends StatefulWidget {
  final VoidCallback? onOpenTesbihat;

  const PrayerTimesScreen({super.key, this.onOpenTesbihat});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color emeraldDark = AppColors.primaryTealDark;
  static const Color accentGold = AppColors.accentOrange;
  static const Color goldLight = AppColors.secondaryCreamLight;

  Timer? _timer;
  DateTime _now = DateTime.now();
  bool _isGpsLoading = false;
  String? _locationErrorMessage;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<PrayerTimesNotifier>().fetchPrayerTimes();
      context.read<PrayerTimesNotifier>().updateQibla();
      _scheduleAllAdhanNotifications();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
      // Vakit geçişlerini yakalamak için dakika başında verileri tazele
      if (_now.second == 0) {
        context.read<PrayerTimesNotifier>().fetchPrayerTimes();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _scheduleAllAdhanNotifications() async {
    final notifier = context.read<PrayerTimesNotifier>();
    for (var entry in notifier.prayerTimes.entries) {
      try {
        await NotificationService().scheduleAdhanNotification(
          entry.key,
          entry.value,
          notifier.selectedCity.name,
        );
      } on NotificationException catch (_) {
        // Geçmiş vakit için bildirim atlanır (gün içinde geçmiş vakitler beklenen bir durumdur)
      }
    }
  }

  Future<void> _detectGpsLocation() async {
    setState(() {
      _isGpsLoading = true;
      _locationErrorMessage = null;
    });

    try {
      final hasPermission = await PermissionService().requestLocationPermission();
      if (!hasPermission) {
        throw const LocationException(message: 'Konum izni verilmedi. Varsayılan il kullanılıyor.');
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          message: 'Konum servisi kapalı. Lütfen GPS\'i açınız veya listeden il seçiniz.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      final nearest = PrayerTimeService.findNearestCity(position.latitude, position.longitude);

      if (!mounted) return;
      await context.read<PrayerTimesNotifier>().updateCity(nearest);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Konumunuz belirlendi: ${nearest.name}'),
            backgroundColor: emeraldGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationErrorMessage = 'Konum alınamadı. Lütfen listeden şehrinizi seçiniz.';
        });
        await ErrorHandler.showError(context, e is Exception ? e : Exception(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isGpsLoading = false);
      }
    }
  }

  void _showCitySearchBottomSheet() {
    final currentCity = context.read<PrayerTimesNotifier>().selectedCity;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String searchQuery = '';
            List<City> filteredCities = City.turkishCities;

            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return StatefulBuilder(
                  builder: (context, setInnerState) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'İl Seçiniz (81 İl)',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: emeraldGreen,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _detectGpsLocation();
                                },
                                icon: const Icon(Icons.my_location, size: 16, color: accentGold),
                                label: const Text('GPS ile Bul', style: TextStyle(color: accentGold, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Şehir adı veya plaka no ile ara...',
                              hintStyle: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary(context),
                              ),
                              prefixIcon: const Icon(Icons.search, color: emeraldGreen),
                              filled: true,
                              fillColor: AppColors.background(context),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.border(context)),
                              ),
                            ),
                            onChanged: (value) {
                              setInnerState(() {
                                searchQuery = value.trim().toLowerCase();
                                if (searchQuery.isEmpty) {
                                  filteredCities = City.turkishCities;
                                } else {
                                  filteredCities = City.turkishCities.where((c) {
                                    final nameMatch = c.name.toLowerCase().contains(searchQuery);
                                    final plateMatch = c.plateCode.toString() == searchQuery;
                                    return nameMatch || plateMatch;
                                  }).toList();
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = filteredCities[index];
                              final isSelected = city.plateCode == currentCity.plateCode;
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isSelected ? emeraldGreen : AppColors.border(context),
                                  foregroundColor: isSelected ? Colors.white : AppColors.text(context),
                                  child: Text(
                                    city.plateCode.toString().padLeft(2, '0'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  city.name,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? emeraldGreen : AppColors.text(context),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: emeraldGreen)
                                    : null,
                                onTap: () {
                                  context.read<PrayerTimesNotifier>().updateCity(city);
                                  setState(() {
                                    _locationErrorMessage = null;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  /// Kalan süreye göre renk: 1 saatten fazla yeşil, 10-60 dk sarı, 10 dk altı kırmızı.
  Color _countdownColor(Duration remaining) {
    if (remaining.inMinutes >= 60) return AppColors.statusGood;
    if (remaining.inMinutes >= 10) return AppColors.statusWarning;
    return AppColors.statusCritical;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _formatTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(dt.hour)}:${twoDigits(dt.minute)}';
  }

  Widget _buildLiveCompass(double qiblaDirection, String cityName) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          // Sensörsüz veya hata durumunda şık sabit pusula fallback'i
          return _buildStaticQiblaIndicator(qiblaDirection, cityName);
        }

        final double? heading = snapshot.data?.heading;
        if (heading == null) {
          return _buildStaticQiblaIndicator(qiblaDirection, cityName);
        }

        // Cihazın kıbleye olan bağıl açısı
        final double qiblaRelativeAngle = (qiblaDirection - heading) * (math.pi / 180);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Canlı Dönen Pusula Kadranı
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Dış Pusula Halkası
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background(context),
                        border: Border.all(color: accentGold.withValues(alpha: 0.8), width: 2),
                      ),
                    ),
                    // Kıble İbresi
                    Transform.rotate(
                      angle: qiblaRelativeAngle,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.navigation_rounded,
                            size: 32,
                            color: emeraldGreen,
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: accentGold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.explore_rounded, color: emeraldGreen, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Canlı Kıble Pusulası',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: emeraldGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$cityName için Kıble Açısı: ${qiblaDirection.toStringAsFixed(0)}°',
                      style: TextStyle(fontSize: 12.5, color: AppColors.text(context), fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ok işareti Kâbe-i Muazzama yönünü gösterir.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaticQiblaIndicator(double qiblaDirection, String cityName) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: goldLight.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: accentGold),
            ),
            child: Icon(Icons.explore_rounded, color: AppColors.accent(context), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$cityName Kıble Açısı: ${qiblaDirection.toStringAsFixed(0)}° (Güney-Doğu)',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: emeraldGreen,
                  ),
                ),
                Text(
                  'Cihazınızda pusula sensörü desteklenmiyorsa bu açıyı referans alabilirsiniz.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerTimesNotifier>(
      builder: (context, notifier, child) {
        final selectedCity = notifier.selectedCity;
        final prayerTimes = notifier.prayerTimes;
        final nextPrayerEntry = PrayerTimeService.getNextPrayer(prayerTimes, _now);
        final progress = PrayerTimeService.getPrayerProgress(prayerTimes, _now);
        final hijriDateStr = notifier.hijriDate.isNotEmpty ? notifier.hijriDate : PrayerTimeService.getHijriDate(_now);
        final specialDayInfo = PrayerTimeService.getNextSpecialDay();
        final SpecialIslamicDay specialDay = specialDayInfo['day'] as SpecialIslamicDay;
        final int remainingDaysToSpecial = specialDayInfo['remainingDays'] as int;
        final qiblaAngle = notifier.qiblaAngle;

        String nextPrayerName = 'İmsak (Yarın)';
        Duration remainingTime = Duration.zero;

        if (nextPrayerEntry != null) {
          nextPrayerName = nextPrayerEntry.key;
          remainingTime = nextPrayerEntry.value.difference(_now);
        } else {
          final tomorrow = _now.add(const Duration(days: 1));
          final tomorrowTimes = PrayerTimeService.getPrayerTimes(selectedCity, tomorrow);
          remainingTime = tomorrowTimes['İmsak']!.difference(_now);
        }

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            title: const Text('Ezan Vakitleri'),
            actions: [
              IconButton(
                tooltip: 'GPS ile Konum Bul',
                icon: _isGpsLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: accentGold, strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded, color: accentGold),
                onPressed: _isGpsLoading ? null : _detectGpsLocation,
              ),
              IconButton(
                tooltip: 'Şehir Değiştir',
                icon: const Icon(Icons.location_city_rounded),
                onPressed: _showCitySearchBottomSheet,
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // Konum Hatası / Uyarı Banner'ı (Graceful Fallback)
                      if (_locationErrorMessage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, color: Colors.amber.shade900, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _locationErrorMessage!,
                                  style: TextStyle(fontSize: 12.5, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                                ),
                              ),
                              TextButton(
                                onPressed: _showCitySearchBottomSheet,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('İl Seç', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),

                      // Şehir & Hicri Tarih Başlık Çubuğu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: _showCitySearchBottomSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.card(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border(context)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, color: emeraldGreen, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${selectedCity.name} (${selectedCity.plateCode})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: emeraldGreen,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: goldLight.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accentGold.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_month_outlined, color: AppColors.accent(context), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  hijriDateStr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.accent(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Ana Vakit Sayacı Degrade Kartı (Dairesel Geri Sayım Zamanlayıcısı)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [emeraldDark, emeraldGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: accentGold.withValues(alpha: 0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sıradaki Vakit: $nextPrayerName',
                                  style: const TextStyle(
                                    color: goldLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.5,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Kıble: ${qiblaAngle.toStringAsFixed(0)}°',
                                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Dairesel İlerleme ve Dijital Zamanlayıcı
                            SizedBox(
                              width: 170,
                              height: 170,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 170,
                                    height: 170,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                                      valueColor: AlwaysStoppedAnimation<Color>(_countdownColor(remainingTime)),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Kalan Süre',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDuration(remainingTime),
                                        style: TextStyle(
                                          color: _countdownColor(remainingTime),
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${(progress * 100).toInt()}% Tamamlandı',
                                        style: const TextStyle(color: goldLight, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Canlı Kıble Pusulası Bileşeni
                      _buildLiveCompass(qiblaAngle, selectedCity.name),
                      const SizedBox(height: 10),
                      QiblaCompassWidget(qiblaDirection: qiblaAngle),

                      // Yaklaşan Kandil / Dini Gün Rozeti
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.card(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.star_rounded, color: AppColors.accent(context), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    specialDay.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: emeraldGreen),
                                  ),
                                  Text(
                                    specialDay.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 11.5, color: AppColors.text(context)),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: emeraldGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                remainingDaysToSpecial == 0 ? 'Bugün' : '$remainingDaysToSpecial gün kaldı',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 6 Vakit Kartları Listesi
                      Column(
                        children: prayerTimes.entries.map((entry) {
                          final isNext = entry.key == nextPrayerName;
                          IconData iconData = Icons.brightness_5;
                          switch (entry.key) {
                            case 'İmsak':
                              iconData = Icons.nightlight_round;
                              break;
                            case 'Güneş':
                              iconData = Icons.wb_sunny_outlined;
                              break;
                            case 'Öğle':
                              iconData = Icons.wb_sunny;
                              break;
                            case 'İkindi':
                              iconData = Icons.wb_twilight;
                              break;
                            case 'Akşam':
                              iconData = Icons.nights_stay_outlined;
                              break;
                            case 'Yatsı':
                              iconData = Icons.bedtime;
                              break;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isNext ? emeraldGreen.withValues(alpha: 0.08) : AppColors.card(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isNext ? accentGold : AppColors.border(context),
                                width: isNext ? 1.8 : 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              minVerticalPadding: 12,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isNext ? emeraldGreen : AppColors.background(context),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  iconData,
                                  color: isNext ? accentGold : emeraldGreen,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                entry.key,
                                style: TextStyle(
                                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 15,
                                  color: isNext ? emeraldGreen : AppColors.text(context),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isNext)
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: accentGold,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Sıradaki',
                                        style: TextStyle(
                                          color: emeraldDark,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    _formatTime(entry.value),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: isNext ? emeraldGreen : AppColors.text(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
