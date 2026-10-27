import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data_naija/core/app_state.dart';
import 'package:data_naija/core/auto_buy_state.dart';
import 'package:data_naija/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (tester) async {
    // Mock SharedPreferences so AutoBuyState.init() succeeds in tests.
    SharedPreferences.setMockInitialValues({});

    final appState = AppState();
    final autoBuyState = AutoBuyState(appState: appState);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppState>.value(value: appState),
          ChangeNotifierProvider<AutoBuyState>.value(value: autoBuyState),
        ],
        child: const DataNaijaApp(),
      ),
    );

    // Splash renders immediately with the DataNaija title.
    expect(find.text('DataNaija'), findsOneWidget);

    // Drain the 2.2s splash timer so no pending timers remain at teardown.
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
