import 'package:flutter_test/flutter_test.dart';
import 'package:data_naija/core/models.dart';
import 'package:data_naija/core/sample_data.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // IntFormat extension
  // ─────────────────────────────────────────────────────────────────────────
  group('IntFormat.toLocaleString', () {
    test('zero', () => expect(0.toLocaleString(), '0'));
    test('single digit', () => expect(7.toLocaleString(), '7'));
    test('three digits', () => expect(999.toLocaleString(), '999'));
    test('exactly 1000', () => expect(1000.toLocaleString(), '1,000'));
    test('ten-thousands', () => expect(10000.toLocaleString(), '10,000'));
    test('hundred-thousands', () => expect(100000.toLocaleString(), '100,000'));
    test('millions', () => expect(1000000.toLocaleString(), '1,000,000'));
    test('negative abs (used in formattedAmount)', () {
      expect((-5000).toLocaleString(), '5,000');
    });
    test('1999 formats correctly', () => expect(1999.toLocaleString(), '1,999'));
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Transaction — computed properties
  // ─────────────────────────────────────────────────────────────────────────
  group('Transaction', () {
    const debit = Transaction(
      id: 1,
      title: 'Data Purchase',
      sub: 'MTN 1GB',
      date: 'Apr 25, 2025 · 02:15 PM',
      amount: -300,
      status: TxStatus.successful,
      phone: '08012345678',
      ref: 'DN001',
      kind: TxKind.data,
    );

    const credit = Transaction(
      id: 2,
      title: 'Wallet Funding',
      sub: 'Bank Transfer',
      date: 'Apr 23, 2025 · 09:45 AM',
      amount: 5000,
      status: TxStatus.successful,
      phone: '-',
      ref: 'DN002',
      kind: TxKind.wallet,
    );

    const pending = Transaction(
      id: 3,
      title: 'Data Purchase',
      sub: '9mobile 1GB',
      date: 'Apr 20, 2025',
      amount: -1000,
      status: TxStatus.pending,
      phone: '09012345678',
      ref: 'DN003',
      kind: TxKind.data,
    );

    const failed = Transaction(
      id: 4,
      title: 'Data Purchase',
      sub: 'Glo 2GB',
      date: 'Apr 21, 2025',
      amount: -2000,
      status: TxStatus.failed,
      phone: '07012345678',
      ref: 'DN004',
      kind: TxKind.data,
    );

    const airtime = Transaction(
      id: 5,
      title: 'Airtime Purchase',
      sub: 'Airtel ₦500',
      date: 'Apr 24, 2025',
      amount: -500,
      status: TxStatus.successful,
      phone: '08098765432',
      ref: 'DN005',
      kind: TxKind.airtime,
    );

    const referral = Transaction(
      id: 6,
      title: 'Referral Bonus',
      sub: 'Moved to wallet',
      date: 'Today',
      amount: 450,
      status: TxStatus.successful,
      phone: '-',
      ref: 'DN006',
      kind: TxKind.referral,
    );

    // isCredit
    test('debit isCredit is false', () => expect(debit.isCredit, false));
    test('credit isCredit is true', () => expect(credit.isCredit, true));

    // formattedAmount
    test('debit formattedAmount has minus sign', () {
      expect(debit.formattedAmount, '-₦300');
    });
    test('credit formattedAmount has plus sign', () {
      expect(credit.formattedAmount, '+₦5,000');
    });
    test('large debit formats correctly', () {
      expect(failed.formattedAmount, '-₦2,000');
    });

    // statusLabel
    test('successful statusLabel', () {
      expect(debit.statusLabel, 'Successful');
    });
    test('pending statusLabel', () {
      expect(pending.statusLabel, 'Pending');
    });
    test('failed statusLabel', () {
      expect(failed.statusLabel, 'Failed');
    });

    // iconLetter
    test('data iconLetter is D', () => expect(debit.iconLetter, 'D'));
    test('wallet iconLetter is W', () => expect(credit.iconLetter, 'W'));
    test('airtime iconLetter is A', () => expect(airtime.iconLetter, 'A'));
    test('referral iconLetter is W', () => expect(referral.iconLetter, 'W'));

    // iconBgColor / iconFgColor differ for airtime vs others
    test('airtime uses debit icon colours', () {
      expect(airtime.iconBgColor, isNot(equals(debit.iconBgColor)));
    });
    test('data uses credit icon colours', () {
      expect(debit.iconBgColor, equals(credit.iconBgColor));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // DataPlan
  // ─────────────────────────────────────────────────────────────────────────
  group('DataPlan', () {
    const plan = DataPlan(gb: '2GB', days: '30 Days', price: 600);
    const hotPlan = DataPlan(gb: '1.5GB', days: '2 Days', price: 250, isHot: true);

    test('priceFormatted includes naira sign', () {
      expect(plan.priceFormatted, '₦600');
    });
    test('priceFormatted for large price', () {
      const big = DataPlan(gb: '10GB', days: '30 Days', price: 3000);
      expect(big.priceFormatted, '₦3,000');
    });
    test('isHot defaults to false', () {
      expect(plan.isHot, false);
    });
    test('isHot can be set to true', () {
      expect(hotPlan.isHot, true);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // ReferralFriend
  // ─────────────────────────────────────────────────────────────────────────
  group('ReferralFriend', () {
    const active = ReferralFriend(name: 'Amina B.', status: 'Active', earned: 320);
    const pending = ReferralFriend(name: 'Funke A.', status: 'Pending', earned: 0);

    test('abbr is first two characters uppercased', () {
      expect(active.abbr, 'AM');
    });
    test('isActive true for Active status', () {
      expect(active.isActive, true);
    });
    test('isActive false for Pending status', () {
      expect(pending.isActive, false);
    });
    test('abbr works for short names', () {
      const r = ReferralFriend(name: 'Al', status: 'Active', earned: 0);
      expect(r.abbr, 'AL');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SampleData integrity
  // ─────────────────────────────────────────────────────────────────────────
  group('SampleData — networks', () {
    test('has exactly 4 networks', () {
      expect(SampleData.networks.length, 4);
    });
    test('network names are correct', () {
      final names = SampleData.networks.map((n) => n.name).toList();
      expect(names, containsAll(['MTN', 'Airtel', 'Glo', '9mobile']));
    });
    test('networkByName returns correct network', () {
      expect(SampleData.networkByName('Glo').abbr, 'glo');
      expect(SampleData.networkByName('MTN').abbr, 'MTN');
    });
    test('networkByName returns first network for unknown name', () {
      expect(SampleData.networkByName('Unknown').name, 'MTN');
    });
    test('all networks have non-empty abbr', () {
      for (final n in SampleData.networks) {
        expect(n.abbr.isNotEmpty, true);
      }
    });
  });

  group('SampleData — bundleTypes', () {
    test('has 5 bundle types', () {
      expect(SampleData.bundleTypes.length, 5);
    });
    test('all expected types present', () {
      expect(
        SampleData.bundleTypes.keys.toSet(),
        containsAll(['SME', 'SME2', 'Gifting', 'Corporate Gifting', 'Awoof']),
      );
    });
    test('every type has at least one plan', () {
      for (final bt in SampleData.bundleTypes.values) {
        expect(bt.plans.isNotEmpty, true);
      }
    });
    test('SME has 5 plans', () {
      expect(SampleData.bundleTypes['SME']!.plans.length, 5);
    });
    test('Awoof plans are all marked isHot', () {
      for (final p in SampleData.bundleTypes['Awoof']!.plans) {
        expect(p.isHot, true);
      }
    });
    test('all plan prices are positive', () {
      for (final bt in SampleData.bundleTypes.values) {
        for (final p in bt.plans) {
          expect(p.price, greaterThan(0));
        }
      }
    });
    test('all plan gb strings are non-empty', () {
      for (final bt in SampleData.bundleTypes.values) {
        for (final p in bt.plans) {
          expect(p.gb.isNotEmpty, true);
        }
      }
    });
  });

  group('SampleData — popularBundles', () {
    test('has 4 popular bundles', () {
      expect(SampleData.popularBundles.length, 4);
    });
    test('every popular bundle network exists in networks list', () {
      final names = SampleData.networks.map((n) => n.name).toSet();
      for (final b in SampleData.popularBundles) {
        expect(names, contains(b.net));
      }
    });
    test('all popular bundle prices are positive', () {
      for (final b in SampleData.popularBundles) {
        expect(b.price, greaterThan(0));
      }
    });
  });

  group('SampleData — seedTransactions', () {
    test('produces 5 transactions', () {
      expect(SampleData.seedTransactions().length, 5);
    });
    test('includes all three status types', () {
      final txs = SampleData.seedTransactions();
      final statuses = txs.map((t) => t.status).toSet();
      expect(statuses, containsAll([
        TxStatus.successful,
        TxStatus.pending,
        TxStatus.failed,
      ]));
    });
    test('ids are unique', () {
      final txs = SampleData.seedTransactions();
      final ids = txs.map((t) => t.id).toSet();
      expect(ids.length, txs.length);
    });
    test('all refs start with DN', () {
      for (final tx in SampleData.seedTransactions()) {
        expect(tx.ref, startsWith('DN'));
      }
    });
    test('each call returns a fresh list', () {
      final a = SampleData.seedTransactions();
      final b = SampleData.seedTransactions();
      expect(identical(a, b), false);
    });
  });

  group('SampleData — notifications', () {
    test('has 4 notifications', () {
      expect(SampleData.notifications.length, 4);
    });
    test('includes both read and unread', () {
      final read = SampleData.notifications.where((n) => n.isRead).length;
      final unread = SampleData.notifications.where((n) => !n.isRead).length;
      expect(read, greaterThan(0));
      expect(unread, greaterThan(0));
    });
    test('all titles are non-empty', () {
      for (final n in SampleData.notifications) {
        expect(n.title.isNotEmpty, true);
      }
    });
  });

  group('SampleData — FAQs', () {
    test('has 5 FAQs', () {
      expect(SampleData.faqs.length, 5);
    });
    test('all questions are non-empty', () {
      for (final f in SampleData.faqs) {
        expect(f.question.isNotEmpty, true);
      }
    });
    test('all answers are non-empty', () {
      for (final f in SampleData.faqs) {
        expect(f.answer.isNotEmpty, true);
      }
    });
  });

  group('SampleData — referralFriends', () {
    test('has 3 referral friends', () {
      expect(SampleData.referralFriends.length, 3);
    });
    test('at least one active friend', () {
      expect(
        SampleData.referralFriends.any((f) => f.isActive),
        true,
      );
    });
  });
}
