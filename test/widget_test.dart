import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meteo_pocket/main.dart';

void main() {
  testWidgets('Météo Pocket démarre correctement', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MeteoPocketApp()));
    expect(find.text('Météo Pocket'), findsOneWidget);
    expect(find.text('Villes populaires'), findsOneWidget);
  });
}
