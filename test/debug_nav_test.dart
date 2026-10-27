import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:data_naija/core/app_state.dart';
import 'package:data_naija/main.dart';

Widget _app({AppState? state}) {
  return ChangeNotifierProvider<AppState>(
    create: (_) => state ?? AppState(),
    child: const DataNaijaApp(),
  );
}

Future<void> _pumpAppAndDrainSplash(WidgetTester tester, {AppState? state}) async {
  await tester.pumpWidget(_app(state: state));
  await tester.pump(const Duration(milliseconds: 2500));
}

void main() {
  testWidgets('debug: granular pumps after skip', (tester) async {
    await _pumpAppAndDrainSplash(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    debugPrint('T0 onboarding=${find.text('Buy Data, Airtime and More').evaluate().length}');
    await tester.pump(const Duration(milliseconds: 100));
    debugPrint('P100 onboarding=${find.text('Buy Data, Airtime and More').evaluate().length}');
    await tester.pump(const Duration(milliseconds: 200));
    debugPrint('P300 onboarding=${find.text('Buy Data, Airtime and More').evaluate().length}');
    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('P800 onboarding=${find.text('Buy Data, Airtime and More').evaluate().length} signin=${find.text('Sign In').evaluate().length}');
    await tester.pumpAndSettle();
    debugPrint('SETTLED onboarding=${find.text('Buy Data, Airtime and More').evaluate().length} signin=${find.text('Sign In').evaluate().length}');
  });
}
