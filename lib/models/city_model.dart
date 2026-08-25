class City {
  final int plateCode;
  final String name;
  final double latitude;
  final double longitude;

  const City({
    required this.plateCode,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  static const List<City> turkishCities = [
    City(plateCode: 1, name: 'Adana', latitude: 37.0000, longitude: 35.3213),
    City(plateCode: 2, name: 'Adıyaman', latitude: 37.7648, longitude: 38.2786),
    City(plateCode: 3, name: 'Afyonkarahisar', latitude: 38.7507, longitude: 30.5567),
    City(plateCode: 4, name: 'Ağrı', latitude: 39.7191, longitude: 43.0503),
    City(plateCode: 5, name: 'Amasya', latitude: 40.6499, longitude: 35.8353),
    City(plateCode: 6, name: 'Ankara', latitude: 39.9334, longitude: 32.8597),
    City(plateCode: 7, name: 'Antalya', latitude: 36.8969, longitude: 30.7133),
    City(plateCode: 8, name: 'Artvin', latitude: 41.1828, longitude: 41.8183),
    City(plateCode: 9, name: 'Aydın', latitude: 37.8560, longitude: 27.8416),
    City(plateCode: 10, name: 'Balıkesir', latitude: 39.6484, longitude: 27.8826),
    City(plateCode: 11, name: 'Bilecik', latitude: 40.1451, longitude: 29.9799),
    City(plateCode: 12, name: 'Bingöl', latitude: 38.8853, longitude: 40.4983),
    City(plateCode: 13, name: 'Bitlis', latitude: 38.4006, longitude: 42.1095),
    City(plateCode: 14, name: 'Bolu', latitude: 40.7350, longitude: 31.6061),
    City(plateCode: 15, name: 'Burdur', latitude: 37.7203, longitude: 30.2908),
    City(plateCode: 16, name: 'Bursa', latitude: 40.1885, longitude: 29.0610),
    City(plateCode: 17, name: 'Çanakkale', latitude: 40.1553, longitude: 26.4142),
    City(plateCode: 18, name: 'Çankırı', latitude: 40.6013, longitude: 33.6134),
    City(plateCode: 19, name: 'Çorum', latitude: 40.5506, longitude: 34.9556),
    City(plateCode: 20, name: 'Denizli', latitude: 37.7765, longitude: 29.0864),
    City(plateCode: 21, name: 'Diyarbakır', latitude: 37.9144, longitude: 40.2306),
    City(plateCode: 22, name: 'Edirne', latitude: 41.6771, longitude: 26.5557),
    City(plateCode: 23, name: 'Elazığ', latitude: 38.6810, longitude: 39.2264),
    City(plateCode: 24, name: 'Erzincan', latitude: 39.7500, longitude: 39.5000),
    City(plateCode: 25, name: 'Erzurum', latitude: 39.9043, longitude: 41.2679),
    City(plateCode: 26, name: 'Eskişehir', latitude: 39.7767, longitude: 30.5206),
    City(plateCode: 27, name: 'Gaziantep', latitude: 37.0662, longitude: 37.3833),
    City(plateCode: 28, name: 'Giresun', latitude: 40.9128, longitude: 38.3895),
    City(plateCode: 29, name: 'Gümüşhane', latitude: 40.4600, longitude: 39.4700),
    City(plateCode: 30, name: 'Hakkâri', latitude: 37.5833, longitude: 43.7333),
    City(plateCode: 31, name: 'Hatay', latitude: 36.2023, longitude: 36.1613),
    City(plateCode: 32, name: 'Isparta', latitude: 37.7648, longitude: 30.5566),
    City(plateCode: 33, name: 'Mersin', latitude: 36.8121, longitude: 34.6415),
    City(plateCode: 34, name: 'İstanbul', latitude: 41.0082, longitude: 28.9784),
    City(plateCode: 35, name: 'İzmir', latitude: 38.4237, longitude: 27.1428),
    City(plateCode: 36, name: 'Kars', latitude: 40.6013, longitude: 43.0975),
    City(plateCode: 37, name: 'Kastamonu', latitude: 41.3887, longitude: 33.7827),
    City(plateCode: 38, name: 'Kayseri', latitude: 38.7312, longitude: 35.4787),
    City(plateCode: 39, name: 'Kırklareli', latitude: 41.7333, longitude: 27.2167),
    City(plateCode: 40, name: 'Kırşehir', latitude: 39.1425, longitude: 34.1709),
    City(plateCode: 41, name: 'Kocaeli', latitude: 40.8533, longitude: 29.8815),
    City(plateCode: 42, name: 'Konya', latitude: 37.8746, longitude: 32.4932),
    City(plateCode: 43, name: 'Kütahya', latitude: 39.4167, longitude: 29.9833),
    City(plateCode: 44, name: 'Malatya', latitude: 38.3552, longitude: 38.3095),
    City(plateCode: 45, name: 'Manisa', latitude: 38.6191, longitude: 27.4289),
    City(plateCode: 46, name: 'Kahramanmaraş', latitude: 37.5858, longitude: 36.9371),
    City(plateCode: 47, name: 'Mardin', latitude: 37.3212, longitude: 40.7245),
    City(plateCode: 48, name: 'Muğla', latitude: 37.2153, longitude: 28.3636),
    City(plateCode: 49, name: 'Muş', latitude: 38.7432, longitude: 41.5064),
    City(plateCode: 50, name: 'Nevşehir', latitude: 38.6244, longitude: 34.7144),
    City(plateCode: 51, name: 'Niğde', latitude: 37.9667, longitude: 34.6833),
    City(plateCode: 52, name: 'Ordu', latitude: 40.9839, longitude: 37.8764),
    City(plateCode: 53, name: 'Rize', latitude: 41.0201, longitude: 40.5234),
    City(plateCode: 54, name: 'Sakarya', latitude: 40.7569, longitude: 30.3783),
    City(plateCode: 55, name: 'Samsun', latitude: 41.2867, longitude: 36.3300),
    City(plateCode: 56, name: 'Siirt', latitude: 37.9333, longitude: 41.9500),
    City(plateCode: 57, name: 'Sinop', latitude: 42.0231, longitude: 35.1531),
    City(plateCode: 58, name: 'Sivas', latitude: 39.7477, longitude: 37.0179),
    City(plateCode: 59, name: 'Tekirdağ', latitude: 40.9833, longitude: 27.5167),
    City(plateCode: 60, name: 'Tokat', latitude: 40.3167, longitude: 36.5500),
    City(plateCode: 61, name: 'Trabzon', latitude: 41.0027, longitude: 39.7168),
    City(plateCode: 62, name: 'Tunceli', latitude: 39.1079, longitude: 39.5401),
    City(plateCode: 63, name: 'Şanlıurfa', latitude: 37.1674, longitude: 38.7955),
    City(plateCode: 64, name: 'Uşak', latitude: 38.6823, longitude: 29.4082),
    City(plateCode: 65, name: 'Van', latitude: 38.4891, longitude: 43.4089),
    City(plateCode: 66, name: 'Yozgat', latitude: 39.8181, longitude: 34.8147),
    City(plateCode: 67, name: 'Zonguldak', latitude: 41.4564, longitude: 31.7987),
    City(plateCode: 68, name: 'Aksaray', latitude: 38.3687, longitude: 34.0370),
    City(plateCode: 69, name: 'Bayburt', latitude: 40.2552, longitude: 40.2249),
    City(plateCode: 70, name: 'Karaman', latitude: 37.1759, longitude: 33.2287),
    City(plateCode: 71, name: 'Kırıkkale', latitude: 39.8468, longitude: 33.5153),
    City(plateCode: 72, name: 'Batman', latitude: 37.8812, longitude: 41.1293),
    City(plateCode: 73, name: 'Şırnak', latitude: 37.5164, longitude: 42.4543),
    City(plateCode: 74, name: 'Bartın', latitude: 41.6344, longitude: 32.3375),
    City(plateCode: 75, name: 'Ardahan', latitude: 41.1105, longitude: 42.7022),
    City(plateCode: 76, name: 'Iğdır', latitude: 39.9196, longitude: 44.0450),
    City(plateCode: 77, name: 'Yalova', latitude: 40.6500, longitude: 29.2667),
    City(plateCode: 78, name: 'Karabük', latitude: 41.2061, longitude: 32.6204),
    City(plateCode: 79, name: 'Kilis', latitude: 36.7184, longitude: 37.1212),
    City(plateCode: 80, name: 'Osmaniye', latitude: 37.0742, longitude: 36.2472),
    City(plateCode: 81, name: 'Düzce', latitude: 40.8438, longitude: 31.1565),
  ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          plateCode == other.plateCode;

  @override
  int get hashCode => plateCode.hashCode;
}
