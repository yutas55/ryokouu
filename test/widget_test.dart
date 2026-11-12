import 'package:flutter_test/flutter_test.dart';

import 'package:ryokou/main.dart';

void main() {
  testWidgets('Splash tampil lalu pindah ke Beranda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RyokouApp());

    // Splash menampilkan app bar RYOKOU.
    expect(find.text('RYOKOU'), findsOneWidget);

    // Tunggu splash 2 detik selesai.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Sekarang di Beranda.
    expect(find.text('Rekomendasi Motor'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
  });
}
