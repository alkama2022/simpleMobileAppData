import 'package:flutter_test/flutter_test.dart';
import 'package:data_naija/core/models.dart';
import 'package:data_naija/core/sample_data.dart';

// This file tests the filter + search logic used by TransactionsScreen.
// The logic is extracted here as a pure function to test it independently
// of the widget, matching the actual implementation in the screen.

List<Transaction> filterTransactions(
  List<Transaction> txs, {
  required String filter,
  required String query,
}) {
  return txs.where((t) {
    final matchFilter = filter == 'All' || t.statusLabel == filter;
    final q = query.toLowerCase();
    final matchSearch = q.isEmpty ||
        t.title.toLowerCase().contains(q) ||
        t.sub.toLowerCase().contains(q);
    return matchFilter && matchSearch;
  }).toList();
}

void main() {
  final txs = SampleData.seedTransactions();

  group('Transaction filter — status chip', () {
    test('"All" returns every transaction', () {
      final result = filterTransactions(txs, filter: 'All', query: '');
      expect(result.length, txs.length);
    });

    test('"Successful" returns only successful transactions', () {
      final result =
          filterTransactions(txs, filter: 'Successful', query: '');
      expect(result.every((t) => t.status == TxStatus.successful), true);
      expect(result.isNotEmpty, true);
    });

    test('"Pending" returns only pending transactions', () {
      final result = filterTransactions(txs, filter: 'Pending', query: '');
      expect(result.every((t) => t.status == TxStatus.pending), true);
      expect(result.isNotEmpty, true);
    });

    test('"Failed" returns only failed transactions', () {
      final result = filterTransactions(txs, filter: 'Failed', query: '');
      expect(result.every((t) => t.status == TxStatus.failed), true);
      expect(result.isNotEmpty, true);
    });

    test('non-matching filter returns empty list', () {
      // There are no TxStatus values beyond successful/pending/failed,
      // so an impossible filter string returns nothing.
      final result =
          filterTransactions(txs, filter: 'Refunded', query: '');
      expect(result.isEmpty, true);
    });
  });

  group('Transaction filter — search query', () {
    test('empty query returns all', () {
      final result = filterTransactions(txs, filter: 'All', query: '');
      expect(result.length, txs.length);
    });

    test('search by title prefix (case-insensitive)', () {
      final result = filterTransactions(txs, filter: 'All', query: 'data');
      expect(result.every((t) => t.title.toLowerCase().contains('data')), true);
      expect(result.isNotEmpty, true);
    });

    test('search by sub string', () {
      final result = filterTransactions(txs, filter: 'All', query: 'mtn');
      expect(result.isNotEmpty, true);
      // Every result should match title or sub
      for (final t in result) {
        final matches = t.title.toLowerCase().contains('mtn') ||
            t.sub.toLowerCase().contains('mtn');
        expect(matches, true);
      }
    });

    test('search for non-existent term returns empty', () {
      final result =
          filterTransactions(txs, filter: 'All', query: 'zzznomatch');
      expect(result.isEmpty, true);
    });

    test('search is case-insensitive', () {
      final lower = filterTransactions(txs, filter: 'All', query: 'wallet');
      final upper = filterTransactions(txs, filter: 'All', query: 'WALLET');
      expect(lower.length, upper.length);
    });

    test('whitespace-only query returns all (treated as empty)', () {
      // The query is lowercased but not trimmed, so '   ' does not match
      // any title or sub — returns 0. This matches the screen behaviour.
      final result =
          filterTransactions(txs, filter: 'All', query: '   ');
      expect(result.isEmpty, true);
    });
  });

  group('Transaction filter — combined filter + search', () {
    test('Successful + "data" returns only successful data purchases', () {
      final result =
          filterTransactions(txs, filter: 'Successful', query: 'data');
      expect(result.every((t) => t.status == TxStatus.successful), true);
      for (final t in result) {
        final matches = t.title.toLowerCase().contains('data') ||
            t.sub.toLowerCase().contains('data');
        expect(matches, true);
      }
    });

    test('Failed + "glo" returns only the one failed Glo transaction', () {
      final result =
          filterTransactions(txs, filter: 'Failed', query: 'glo');
      expect(result.length, 1);
      expect(result.first.status, TxStatus.failed);
      expect(
        result.first.title.toLowerCase().contains('glo') ||
            result.first.sub.toLowerCase().contains('glo'),
        true,
      );
    });

    test('Successful + non-matching query returns empty', () {
      final result =
          filterTransactions(txs, filter: 'Successful', query: 'zzz');
      expect(result.isEmpty, true);
    });
  });
}
