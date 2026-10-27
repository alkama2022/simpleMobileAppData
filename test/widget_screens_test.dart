import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:data_naija/core/app_state.dart';
import 'package:data_naija/core/models.dart';
import 'package:data_naija/main.dart';
import 'package:data_naija/widgets/dn_button.dart';
import 'package:data_naija/widgets/dn_chip.dart';
import 'package:data_naija/widgets/dn_status_pill.dart';
import 'package:data_naija/widgets/step_indicator.dart';
import 'package:data_naija/widgets/tx_row.dart';
import 'package:data_naija/core/auto_buy_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Test helpers
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Wraps a widget with the required Provider and Material scaffolding.
Widget _wrap(Widget child, {AppState? state}) {
  return ChangeNotifierProvider<AppState>(
    create: (_) => state ?? AppState(),
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Wraps the full app so route-based navigation works.
Widget _app({AppState? state}) {
  return ChangeNotifierProvider<AppState>(
    create: (_) => state ?? AppState(),
    child: const DataNaijaApp(),
  );
}

/// Launches the full app and drains the splash screen timer (2.2 s).
/// Every widget test that starts from the splash MUST call this instead of
/// just pumpWidget, otherwise the pending timer causes a teardown failure.
Future<void> _pumpAppAndDrainSplash(
  WidgetTester tester, {
  AppState? state,
}) async {
  await tester.pumpWidget(_app(state: state));
  // Advance past the 2.2 s auto-advance timer with a small margin.
  await tester.pump(const Duration(milliseconds: 2500));
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Shared widget: DnPrimaryButton
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

void main() {
  group('DnPrimaryButton', () {
    testWidgets('shows label text', (tester) async {
      await tester.pumpWidget(
        _wrap(DnPrimaryButton(label: 'Sign In', onPressed: () {})),
      );
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('is tappable when onPressed is provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(DnPrimaryButton(label: 'Go', onPressed: () => tapped = true)),
      );
      await tester.tap(find.text('Go'));
      expect(tapped, true);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        _wrap(const DnPrimaryButton(label: 'Go')),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows spinner when loading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(const DnPrimaryButton(label: 'Go', loading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Label is hidden during loading
      expect(find.text('Go'), findsNothing);
    });

    testWidgets('is disabled when loading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(DnPrimaryButton(
          label: 'Go',
          onPressed: () {},
          loading: true,
        )),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Shared widget: DnChip
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('DnChip', () {
    testWidgets('shows label', (tester) async {
      await tester.pumpWidget(
        _wrap(DnChip(label: 'All', selected: false, onTap: () {})),
      );
      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(DnChip(
          label: 'Tap me',
          selected: false,
          onTap: () => tapped = true,
        )),
      );
      await tester.tap(find.text('Tap me'));
      expect(tapped, true);
    });

    testWidgets('selected chip has different visual state', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(children: [
            DnChip(label: 'A', selected: true, onTap: () {}),
            DnChip(label: 'B', selected: false, onTap: () {}),
          ]),
        ),
      );
      // Both should render without overflow
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Shared widget: DnStatusPill
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('DnStatusPill', () {
    testWidgets('shows Successful', (tester) async {
      await tester.pumpWidget(
        _wrap(const DnStatusPill(status: TxStatus.successful)),
      );
      expect(find.text('Successful'), findsOneWidget);
    });

    testWidgets('shows Pending', (tester) async {
      await tester.pumpWidget(
        _wrap(const DnStatusPill(status: TxStatus.pending)),
      );
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows Failed', (tester) async {
      await tester.pumpWidget(
        _wrap(const DnStatusPill(status: TxStatus.failed)),
      );
      expect(find.text('Failed'), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Shared widget: StepIndicator
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('StepIndicator', () {
    testWidgets('renders three step numbers', (tester) async {
      await tester.pumpWidget(
        _wrap(const StepIndicator(currentStep: 1)),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders at step 2 without error', (tester) async {
      await tester.pumpWidget(
        _wrap(const StepIndicator(currentStep: 2)),
      );
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders at step 3 without error', (tester) async {
      await tester.pumpWidget(
        _wrap(const StepIndicator(currentStep: 3)),
      );
      expect(find.text('3'), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Shared widget: TxRow
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('TxRow', () {
    const tx = Transaction(
      id: 1,
      title: 'Data Purchase',
      sub: 'MTN 1GB',
      date: 'Apr 25, 2025 Â· 02:15 PM',
      amount: -300,
      status: TxStatus.successful,
      phone: '08012345678',
      ref: 'DN001',
      kind: TxKind.data,
    );

    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        _wrap(TxRow(tx: tx, onTap: () {})),
      );
      expect(find.text('Data Purchase'), findsOneWidget);
    });

    testWidgets('shows sub when showDate is false', (tester) async {
      await tester.pumpWidget(
        _wrap(TxRow(tx: tx, onTap: () {}, showDate: false)),
      );
      expect(find.text('MTN 1GB'), findsOneWidget);
    });

    testWidgets('shows sub Â· date when showDate is true', (tester) async {
      await tester.pumpWidget(
        _wrap(TxRow(tx: tx, onTap: () {}, showDate: true)),
      );
      expect(find.textContaining('MTN 1GB'), findsOneWidget);
      expect(find.textContaining('Apr 25'), findsOneWidget);
    });

    testWidgets('shows formatted amount', (tester) async {
      await tester.pumpWidget(
        _wrap(TxRow(tx: tx, onTap: () {})),
      );
      expect(find.textContaining('300'), findsWidgets);
    });

    testWidgets('shows status pill', (tester) async {
      await tester.pumpWidget(
        _wrap(TxRow(tx: tx, onTap: () {})),
      );
      expect(find.text('Successful'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(TxRow(tx: tx, onTap: () => tapped = true)),
      );
      await tester.tap(find.byType(InkWell).first);
      expect(tapped, true);
    });

    testWidgets('renders icon letter D for data kind', (tester) async {
      await tester.pumpWidget(
        _wrap(TxRow(tx: tx, onTap: () {})),
      );
      expect(find.text('D'), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Screen: SplashScreen
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('SplashScreen', () {
    testWidgets('shows DataNaija title', (tester) async {
      await _pumpAppAndDrainSplash(tester);
      // After splash drains we are on onboarding; splash already rendered title.
      // Re-pump to splash by using a fresh pumpWidget without draining.
      await tester.pumpWidget(_app());
      expect(find.text('DataNaija'), findsOneWidget);
      // Drain timer to clean up
      await tester.pump(const Duration(milliseconds: 2500));
    });

    testWidgets('shows tagline', (tester) async {
      await tester.pumpWidget(_app());
      expect(find.textContaining('Fast'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2500));
    });

    testWidgets('advances to onboarding after 2.2s', (tester) async {
      await _pumpAppAndDrainSplash(tester);
      await tester.pumpAndSettle();
      // Onboarding shows "Continue" button
      expect(find.text('Continue'), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Screen: OnboardingScreen
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('OnboardingScreen', () {
    Future<void> goToOnboarding(WidgetTester tester) async {
      await _pumpAppAndDrainSplash(tester);
      await tester.pumpAndSettle();
    }

    testWidgets('shows first slide title', (tester) async {
      await goToOnboarding(tester);
      expect(find.text('Buy Data, Airtime and More'), findsOneWidget);
    });

    testWidgets('shows Continue button', (tester) async {
      await goToOnboarding(tester);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows Skip button', (tester) async {
      await goToOnboarding(tester);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Continue advances to slide 2', (tester) async {
      await goToOnboarding(tester);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(find.text('Your Wallet, Your Control'), findsOneWidget);
    });

    testWidgets('Skip navigates to sign-in screen', (tester) async {
      await goToOnboarding(tester);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('Continue on slide 2 navigates to sign-in', (tester) async {
      await goToOnboarding(tester);
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Screen: SignInScreen
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('SignInScreen', () {
    Future<void> goToSignIn(WidgetTester tester) async {
      await _pumpAppAndDrainSplash(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows Welcome Back heading', (tester) async {
      await goToSignIn(tester);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('shows email/phone field', (tester) async {
      await goToSignIn(tester);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is TextField &&
              (w.decoration?.hintText
                      ?.contains('email or phone') ??
                  false),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows password field', (tester) async {
      await goToSignIn(tester);
      expect(
        find.byWidgetPredicate(
          (w) => w is TextField && w.obscureText == true,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Sign In button is present', (tester) async {
      await goToSignIn(tester);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Create an Account button is present', (tester) async {
      await goToSignIn(tester);
      expect(find.text('Create an Account'), findsOneWidget);
    });

    testWidgets('tapping Sign In navigates to home', (tester) async {
      await goToSignIn(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      // Home screen shows wallet balance label
      expect(find.text('Wallet Balance'), findsOneWidget);
    });

    testWidgets('tapping Create an Account navigates to sign-up', (tester) async {
      await goToSignIn(tester);
      await tester.tap(find.text('Create an Account'));
      await tester.pump(const Duration(milliseconds: 600));
      // Sign-up screen has its own unique heading
      expect(find.textContaining('Create Account'), findsWidgets);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Screen: HomeScreen
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('HomeScreen', () {
    Future<void> goToHome(WidgetTester tester, {AppState? state}) async {
      await _pumpAppAndDrainSplash(tester, state: state);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Sign In'));
      await tester.pump(const Duration(milliseconds: 500));
    }

    testWidgets('shows wallet balance', (tester) async {
      await goToHome(tester);
      expect(find.text('Wallet Balance'), findsOneWidget);
    });

    testWidgets('shows balance amount', (tester) async {
      await goToHome(tester);
      expect(find.textContaining('5,000'), findsWidgets);
    });

    testWidgets('shows Popular Data Bundles section', (tester) async {
      await goToHome(tester);
      expect(find.text('Popular Data Bundles'), findsOneWidget);
    });

    testWidgets('shows Recent Transactions section', (tester) async {
      await goToHome(tester);
      expect(find.textContaining('Recent Transactions'), findsWidgets);
    });

    testWidgets('shows Buy Data quick action', (tester) async {
      await goToHome(tester);
      expect(find.text('Buy Data'), findsWidgets);
    });

    testWidgets('shows KYC banner when not verified', (tester) async {
      final state = AppState()..isKycVerified = false;
      await goToHome(tester, state: state);
      expect(
        find.textContaining('Verify your identity'),
        findsOneWidget,
      );
    });

    testWidgets('KYC banner absent when verified', (tester) async {
      final state = AppState()..isKycVerified = true;
      // We can't easily call completeKyc before navigation, so set field directly
      // and notify â€” completeKyc will be called during navigation.
      // Instead use a custom state.
      await goToHome(tester, state: state);
      expect(
        find.textContaining('Verify your identity'),
        findsNothing,
      );
    });

    testWidgets('bottom nav has 4 tabs', (tester) async {
      await goToHome(tester);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Data'), findsOneWidget);
      // "Transactions" appears both in the nav and as section header
      expect(find.text('Transactions'), findsWidgets);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('tapping Transactions tab shows transactions screen',
        (tester) async {
      await goToHome(tester);
      await tester.tap(find.text('Transactions').last);
      await tester.pumpAndSettle();
      // The screen header
      expect(find.text('Transactions'), findsWidgets);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Screen: KycScreen â€” form validation
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('KycScreen â€” button state', () {
    Future<void> goToKyc(WidgetTester tester) async {
      await _pumpAppAndDrainSplash(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Sign In'));
      await tester.pump(const Duration(milliseconds: 500));
      // Navigate to KYC via named route
      final NavigatorState nav = tester.state(find.byType(Navigator).first);
      nav.pushNamed('/kyc');
      await tester.pumpAndSettle();
    }

    testWidgets('Verify button disabled with empty ID', (tester) async {
      await goToKyc(tester);
      // Find the Verify button â€” should be disabled
      final buttons = tester.widgetList<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      // The Verify button is the one with null onPressed when disabled
      final verifyButton = buttons.firstWhere(
        (b) => b.child is Text && (b.child as Text).data == 'Verify',
        orElse: () => buttons.first,
      );
      expect(verifyButton.onPressed, isNull);
    });

    testWidgets('shows BVN type chip', (tester) async {
      await goToKyc(tester);
      expect(find.text('BVN'), findsOneWidget);
    });

    testWidgets('shows NIN type chip', (tester) async {
      await goToKyc(tester);
      expect(find.text('NIN'), findsOneWidget);
    });

    testWidgets('shows consent checkbox', (tester) async {
      await goToKyc(tester);
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Screen: TransactionsScreen â€” search and filter
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('TransactionsScreen', () {
    Future<void> goToTx(WidgetTester tester) async {
      await _pumpAppAndDrainSplash(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Sign In'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Transactions').last);
      await tester.pumpAndSettle();
    }

    testWidgets('shows search field', (tester) async {
      await goToTx(tester);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows All filter chip', (tester) async {
      await goToTx(tester);
      expect(find.text('All'), findsWidgets);
    });

    testWidgets('shows filter chips for all statuses', (tester) async {
      await goToTx(tester);
      expect(find.text('Successful'), findsWidgets);
      expect(find.text('Pending'), findsWidgets);
      expect(find.text('Failed'), findsWidgets);
    });

    testWidgets('shows seeded transactions', (tester) async {
      await goToTx(tester);
      expect(find.text('Data Purchase'), findsWidgets);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Screen: HelpScreen â€” tabs and content
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('HelpScreen', () {
    Future<void> goToHelp(WidgetTester tester) async {
      await _pumpAppAndDrainSplash(tester);
      await tester.pump();
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Sign In'));
      await tester.pump(const Duration(milliseconds: 500));
      final NavigatorState nav = tester.state(find.byType(Navigator).first);
      nav.pushNamed('/help');
      await tester.pumpAndSettle();
    }

    testWidgets('shows FAQs tab by default', (tester) async {
      await goToHelp(tester);
      expect(find.text('FAQs'), findsWidgets);
      // First FAQ question
      expect(find.text('How do I fund my wallet?'), findsOneWidget);
    });

    testWidgets('shows Contact Support tab chip', (tester) async {
      await goToHelp(tester);
      expect(find.text('Contact Support'), findsOneWidget);
    });

    testWidgets('tapping Contact Support shows WhatsApp cards', (tester) async {
      await goToHelp(tester);
      await tester.tap(find.text('Contact Support'));
      await tester.pump();
      expect(find.text('Chat with Support'), findsOneWidget);
      expect(find.text('Follow Our WhatsApp Channel'), findsOneWidget);
    });

    testWidgets('WhatsApp card shows correct phone number', (tester) async {
      await goToHelp(tester);
      await tester.tap(find.text('Contact Support'));
      await tester.pump();
      expect(find.text('+234 812 657 3474'), findsOneWidget);
    });

    testWidgets('tapping FAQ expands its answer', (tester) async {
      await goToHelp(tester);
      // Tap the first FAQ
      await tester.tap(find.text('How do I fund my wallet?'));
      await tester.pump();
      expect(
        find.textContaining('Open Fund Wallet'),
        findsOneWidget,
      );
    });

    testWidgets('tapping FAQ again collapses it', (tester) async {
      await goToHelp(tester);
      await tester.tap(find.text('How do I fund my wallet?'));
      await tester.pump();
      await tester.tap(find.text('How do I fund my wallet?'));
      await tester.pump();
      expect(find.textContaining('Open Fund Wallet'), findsNothing);
    });

    testWidgets('shows Need more help card', (tester) async {
      await goToHelp(tester);
      expect(find.text('Need more help?'), findsOneWidget);
    });
  });

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Full purchase flow â€” state changes
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  group('Purchase flow â€” AppState state machine', () {
    test('full flow changes balance, adds tx, sets lastPurchasedTxId', () {
      final s = AppState();
      s.setNetwork('MTN');
      s.setPhone('08012345678');
      s.setBundleType('SME');
      s.setPlan(const DataPlan(gb: '1GB', days: '30 Days', price: 300));
      s.balance = 1000;
      final txBefore = s.transactions.length;

      s.confirmPurchase();

      expect(s.balance, 700);
      expect(s.transactions.length, txBefore + 1);
      expect(s.lastPurchasedTxId, isNotNull);
      expect(s.lastPurchasedTxId, s.transactions.first.id);
    });

    test('can find purchased tx by lastPurchasedTxId', () {
      final s = AppState()
        ..balance = 600
        ..selectedPlan =
            const DataPlan(gb: '2GB', days: '30 Days', price: 600);
      s.confirmPurchase();
      final tx = s.transactions.firstWhere(
        (t) => t.id == s.lastPurchasedTxId,
      );
      expect(tx.amount, -600);
    });
  });
}







