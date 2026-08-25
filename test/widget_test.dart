import 'package:flutter_test/flutter_test.dart';
import 'package:iman_uygulamasi/main.dart';

void main() {
  testWidgets('Uygulama başarıyla başlar ve 4 ana sekme arasında geçiş yapılır', (WidgetTester tester) async {
    // Uygulamayı başlat
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Ezan Vakitleri ekranı
    expect(find.text('Ezan Vakitleri'), findsWidgets);
    expect(find.text('İmsak'), findsWidgets);
    expect(find.text('Öğle'), findsWidgets);

    // 2. Zikirmatik sekmesine geç
    await tester.tap(find.text('Zikirmatik'));
    await tester.pumpAndSettle();
    expect(find.text('Zikirmatik'), findsWidgets);
    expect(find.textContaining('Bugün Toplam'), findsOneWidget);

    // 3. Rehber sekmesine geç
    await tester.tap(find.text('Rehber'));
    await tester.pumpAndSettle();
    expect(find.text('Namaz & Abdest Rehberi'), findsOneWidget);
    expect(find.text('5 Vakit'), findsOneWidget);
    expect(find.text('Özel Namazlar'), findsOneWidget);
    expect(find.text('Abdest'), findsOneWidget);

    // 4. Dualar sekmesine geç
    await tester.tap(find.text('Dualar'));
    await tester.pumpAndSettle();
    expect(find.text('Kur\'an Duaları'), findsWidgets);
    expect(find.text('Günün Kur\'an Duası'), findsWidgets);
  });
}
