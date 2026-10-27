// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:data_naija/core/app_state.dart';
import 'package:data_naija/core/models.dart';
import 'package:data_naija/core/sample_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

AppState _freshState() => AppState();

const _plan300 = DataPlan(gb: '1GB', days: '30 Days', price: 300);
const _plan160 = DataPlan(gb: '500MB', days: '30 Days', price: 160);

// ─────────────────────────────────────────────────────────────────────────────
// Wallet
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('AppState — initial defaults', () {
    test('starts with correct seed balance', () {
      expect(_freshState().balance, 5000);
    });
    test('starts unverified', () {
      expect(_freshState().isKycVerified, false);
    });
    test('starts with 5 seeded transactions', () {
      expect(_freshState().transactions.length, 5);
    });
    test('starts with balance visible', () {
      final s = _freshState();
      expect(s.balanceHidden, false);
      expect(s.isBalanceVisible, true);
    });
    test('starts with biometric disabled', () {
      expect(_freshState().isBiometricEnabled, false);
    });
    test('default selected network is MTN', () {
      expect(_freshState().selectedNetwork, 'MTN');
    });
    test('default selected phone is empty', () {
      expect(_freshState().selectedPhone, '');
    });
    test('default bundle type is SME', () {
      expect(_freshState().selectedBundleType, 'SME');
    });
    test('default referral bonus is 450', () {
      expect(_freshState().referralBonus, 450);
    });
    test('lastPurchasedTxId is null initially', () {
      expect(_freshState().lastPurchasedTxId, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Balance text formatting
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — balanceText', () {
    test('shows formatted amount when visible', () {
      final s = _freshState()..balance = 5000;
      expect(s.balanceText, '₦5,000.00');
    });
    test('shows bullets when hidden', () {
      final s = _freshState()..balanceHidden = true;
      expect(s.balanceText, '₦ ••••••');
    });
    test('shows zero correctly', () {
      final s = _freshState()..balance = 0;
      expect(s.balanceText, '₦0.00');
    });
    test('shows large balance correctly', () {
      final s = _freshState()..balance = 1000000;
      expect(s.balanceText, '₦1,000,000.00');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Balance visibility toggles
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — balance visibility', () {
    test('toggleBalanceHidden hides then shows', () {
      final s = _freshState();
      s.toggleBalanceHidden();
      expect(s.balanceHidden, true);
      expect(s.isBalanceVisible, false);
      s.toggleBalanceHidden();
      expect(s.balanceHidden, false);
      expect(s.isBalanceVisible, true);
    });

    test('toggleBalanceVisibility keeps flags in sync', () {
      final s = _freshState();
      s.toggleBalanceVisibility();
      expect(s.isBalanceVisible, false);
      expect(s.balanceHidden, true);
      s.toggleBalanceVisibility();
      expect(s.isBalanceVisible, true);
      expect(s.balanceHidden, false);
    });

    test('eye button and security toggle agree after eye press', () {
      // Eye button calls toggleBalanceHidden; Security toggle calls
      // toggleBalanceVisibility. After one eye press both should agree.
      final s = _freshState();
      s.toggleBalanceHidden();
      expect(s.balanceHidden, s.isBalanceVisible == false);
    });

    test('notifyListeners is called on toggleBalanceHidden', () {
      final s = _freshState();
      var notified = false;
      s.addListener(() => notified = true);
      s.toggleBalanceHidden();
      expect(notified, true);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Fund wallet
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — fundWallet', () {
    test('increases balance by exact amount', () {
      final s = _freshState();
      final before = s.balance;
      s.fundWallet(3000, 'Card Payment');
      expect(s.balance, before + 3000);
    });

    test('adds transaction to the front of the list', () {
      final s = _freshState();
      final before = s.transactions.length;
      s.fundWallet(1000, 'USSD');
      expect(s.transactions.length, before + 1);
      expect(s.transactions.first.kind, TxKind.wallet);
    });

    test('records correct method in sub field', () {
      final s = _freshState();
      s.fundWallet(500, 'USSD');
      expect(s.transactions.first.sub, 'USSD');
    });

    test('records correct title', () {
      final s = _freshState();
      s.fundWallet(500, 'Card Payment');
      expect(s.transactions.first.title, 'Wallet Funding');
    });

    test('records positive amount', () {
      final s = _freshState();
      s.fundWallet(2000, 'Bank Transfer');
      expect(s.transactions.first.amount, 2000);
      expect(s.transactions.first.isCredit, true);
    });

    test('records phone as hyphen', () {
      final s = _freshState();
      s.fundWallet(500, 'Card Payment');
      expect(s.transactions.first.phone, '-');
    });

    test('simulateBankTransfer credits exactly 2000', () {
      final s = _freshState();
      final before = s.balance;
      s.simulateBankTransfer();
      expect(s.balance, before + 2000);
      expect(s.transactions.first.sub, 'Bank Transfer');
    });

    test('ref starts with DN', () {
      final s = _freshState();
      s.fundWallet(100, 'Card Payment');
      expect(s.transactions.first.ref, startsWith('DN'));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Buy-data flow — selection state
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — buy-data selection', () {
    test('setNetwork updates selectedNetwork', () {
      final s = _freshState();
      s.setNetwork('Glo');
      expect(s.selectedNetwork, 'Glo');
    });

    test('setNetwork notifies listeners', () {
      final s = _freshState();
      var notified = false;
      s.addListener(() => notified = true);
      s.setNetwork('Airtel');
      expect(notified, true);
    });

    test('setPhone updates selectedPhone', () {
      final s = _freshState();
      s.setPhone('08012345678');
      expect(s.selectedPhone, '08012345678');
    });

    test('setPlan updates selectedPlan', () {
      final s = _freshState();
      s.setPlan(_plan160);
      expect(s.selectedPlan.price, 160);
      expect(s.selectedPlan.gb, '500MB');
    });

    test('setBundleType updates type and resets plan to first', () {
      final s = _freshState();
      s.setBundleType('Awoof');
      expect(s.selectedBundleType, 'Awoof');
      expect(
        s.selectedPlan.gb,
        SampleData.bundleTypes['Awoof']!.plans.first.gb,
      );
    });

    test('setBundleType for unknown type defaults to empty plan list gracefully', () {
      final s = _freshState();
      // Should not throw; plan remains unchanged when type has no plans.
      expect(() => s.setBundleType('NonExistent'), returnsNormally);
    });

    test('all five bundle types can be selected without error', () {
      final s = _freshState();
      for (final type in SampleData.bundleTypes.keys) {
        expect(() => s.setBundleType(type), returnsNormally);
        expect(s.selectedBundleType, type);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // confirmPurchase
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — confirmPurchase', () {
    test('deducts correct amount from balance', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      expect(s.balance, 700);
    });

    test('prepends transaction to list', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      final before = s.transactions.length;
      s.confirmPurchase();
      expect(s.transactions.length, before + 1);
      expect(s.transactions.first.kind, TxKind.data);
    });

    test('records negative amount', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      expect(s.transactions.first.amount, -300);
      expect(s.transactions.first.isCredit, false);
    });

    test('records correct phone', () {
      final s = _freshState()
        ..balance = 500
        ..selectedPhone = '09012345678'
        ..selectedPlan = _plan160;
      s.confirmPurchase();
      expect(s.transactions.first.phone, '09012345678');
    });

    test('sets lastPurchasedTxId to the new transaction id', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      expect(s.lastPurchasedTxId, s.transactions.first.id);
    });

    test('sub includes network, bundle type, and gb', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedNetwork = 'Airtel'
        ..selectedBundleType = 'SME'
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      final sub = s.transactions.first.sub;
      expect(sub, contains('Airtel'));
      expect(sub, contains('SME'));
      expect(sub, contains('1GB'));
    });

    test('status is always successful', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      expect(s.transactions.first.status, TxStatus.successful);
    });

    test('ref starts with DN', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      expect(s.transactions.first.ref, startsWith('DN'));
    });

    test('multiple purchases accumulate at the front', () {
      final s = _freshState()
        ..balance = 2000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      s.selectedPlan = _plan160;
      s.confirmPurchase();
      // Most recent is at index 0
      expect(s.transactions.first.amount, -160);
    });

    test('balance never dips below zero in normal usage', () {
      // This validates that balance arithmetic is correct; the UI
      // prevents confirming when balance < price, so this tests the math.
      final s = _freshState()
        ..balance = 300
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      expect(s.balance, 0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // addTransaction ordering
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — addTransaction', () {
    test('new transaction is at index 0 (newest first)', () {
      final s = _freshState();
      const tx = Transaction(
        id: 999,
        title: 'Test',
        sub: 'test sub',
        date: 'Today',
        amount: 100,
        status: TxStatus.successful,
        phone: '-',
        ref: 'DN999',
        kind: TxKind.wallet,
      );
      s.addTransaction(tx);
      expect(s.transactions.first.id, 999);
    });

    test('notifyListeners is called on addTransaction', () {
      final s = _freshState();
      var count = 0;
      s.addListener(() => count++);
      const tx = Transaction(
        id: 888,
        title: 'T',
        sub: 's',
        date: 'd',
        amount: 1,
        status: TxStatus.successful,
        phone: '-',
        ref: 'DN888',
        kind: TxKind.wallet,
      );
      s.addTransaction(tx);
      expect(count, greaterThan(0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // KYC
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — KYC', () {
    test('starts unverified', () {
      expect(_freshState().isKycVerified, false);
    });
    test('completeKyc sets verified', () {
      final s = _freshState();
      s.completeKyc();
      expect(s.isKycVerified, true);
    });
    test('completeKyc notifies listeners', () {
      final s = _freshState();
      var notified = false;
      s.addListener(() => notified = true);
      s.completeKyc();
      expect(notified, true);
    });
    test('completeKyc is idempotent', () {
      final s = _freshState();
      s.completeKyc();
      s.completeKyc();
      expect(s.isKycVerified, true);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Security settings
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — security settings', () {
    test('toggleBiometric enables then disables', () {
      final s = _freshState();
      s.toggleBiometric();
      expect(s.isBiometricEnabled, true);
      s.toggleBiometric();
      expect(s.isBiometricEnabled, false);
    });

    test('toggleBiometric notifies listeners', () {
      final s = _freshState();
      var notified = false;
      s.addListener(() => notified = true);
      s.toggleBiometric();
      expect(notified, true);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Referral
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — referral', () {
    test('moveReferralBonus transfers full bonus to wallet', () {
      final s = _freshState();
      final bonus = s.referralBonus;
      final before = s.balance;
      s.moveReferralBonus();
      expect(s.balance, before + bonus);
      expect(s.referralBonus, 0);
    });

    test('moved transaction has referral kind', () {
      final s = _freshState();
      s.moveReferralBonus();
      expect(s.transactions.first.kind, TxKind.referral);
    });

    test('moved transaction amount equals original bonus', () {
      final s = _freshState();
      final bonus = s.referralBonus;
      s.moveReferralBonus();
      expect(s.transactions.first.amount, bonus);
    });

    test('does nothing when bonus below minimum (50)', () {
      final s = _freshState()..referralBonus = 50;
      final before = s.balance;
      final txBefore = s.transactions.length;
      s.moveReferralBonus();
      expect(s.balance, before);
      expect(s.referralBonus, 50);
      expect(s.transactions.length, txBefore);
    });

    test('does nothing when bonus is exactly 0', () {
      final s = _freshState()..referralBonus = 0;
      final before = s.balance;
      s.moveReferralBonus();
      expect(s.balance, before);
    });

    test('works when bonus equals minimum (100)', () {
      final s = _freshState()..referralBonus = 100;
      final before = s.balance;
      s.moveReferralBonus();
      expect(s.balance, before + 100);
      expect(s.referralBonus, 0);
    });

    test('referralMinMove constant is 100', () {
      expect(AppState.referralMinMove, 100);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Private helpers via observable side effects
  // ─────────────────────────────────────────────────────────────────────────
  group('AppState — date/time helpers', () {
    test('transaction date string contains year', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      final date = s.transactions.first.date;
      expect(date, contains(DateTime.now().year.toString()));
    });

    test('transaction date string contains AM or PM', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      final date = s.transactions.first.date;
      expect(date.contains('AM') || date.contains('PM'), true);
    });

    test('transaction date string contains a month abbreviation', () {
      final s = _freshState()
        ..balance = 1000
        ..selectedPlan = _plan300;
      s.confirmPurchase();
      final date = s.transactions.first.date;
      final months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec',
      ];
      expect(months.any(date.contains), true);
    });
  });
}
