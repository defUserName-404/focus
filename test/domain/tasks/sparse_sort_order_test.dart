import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/tasks/domain/services/sparse_sort_order.dart';

void main() {
  group('SparseSortOrder.append', () {
    test('returns gap when column is empty', () {
      expect(SparseSortOrder.append(), SparseSortOrder.gap);
      expect(SparseSortOrder.append(null), SparseSortOrder.gap);
    });

    test('adds gap after last order', () {
      expect(SparseSortOrder.append(2000), 3000);
    });
  });

  group('SparseSortOrder.prepend', () {
    test('subtracts gap from first order', () {
      expect(SparseSortOrder.prepend(1000), 0);
    });
  });

  group('SparseSortOrder.between', () {
    test('returns midpoint when gap is healthy', () {
      expect(SparseSortOrder.between(before: 1000, after: 3000), 2000);
    });

    test('returns null when gap collapses', () {
      expect(SparseSortOrder.between(before: 1.0, after: 1.0 + SparseSortOrder.minGap), isNull);
    });
  });

  group('SparseSortOrder.forInsert', () {
    test('empty neighbours yields gap', () {
      expect(SparseSortOrder.forInsert(neighborOrders: const [], insertIndex: 0), SparseSortOrder.gap);
    });

    test('insert at start prepends', () {
      expect(SparseSortOrder.forInsert(neighborOrders: const [1000, 2000], insertIndex: 0), 0);
    });

    test('insert at end appends', () {
      expect(SparseSortOrder.forInsert(neighborOrders: const [1000, 2000], insertIndex: 2), 3000);
    });

    test('insert in middle uses midpoint', () {
      expect(SparseSortOrder.forInsert(neighborOrders: const [1000, 3000], insertIndex: 1), 2000);
    });

    test('repeated same-slot inserts eventually require rebalance', () {
      var orders = <double>[1000, 2000];
      var collapsed = false;

      for (var i = 0; i < 40; i++) {
        final next = SparseSortOrder.forInsert(neighborOrders: orders, insertIndex: 1);
        if (next == null) {
          collapsed = true;
          final rebalanced = SparseSortOrder.rebalance(orders.length + 1);
          expect(rebalanced.length, orders.length + 1);
          expect(rebalanced[1], greaterThan(rebalanced[0]));
          expect(rebalanced[2], greaterThan(rebalanced[1]));
          // Place the new item at slot 1 after rebalance, then continue inserting there.
          orders = [rebalanced[0], rebalanced[1], ...rebalanced.skip(2)];
          final after = SparseSortOrder.forInsert(neighborOrders: orders, insertIndex: 1);
          expect(after, isNotNull);
          orders = [orders[0], after!, ...orders.skip(1)];
          continue;
        }
        orders = [orders[0], next, ...orders.skip(1)];
      }

      expect(collapsed, isTrue);
      for (var i = 1; i < orders.length; i++) {
        expect(orders[i], greaterThan(orders[i - 1]));
      }
    });
  });

  group('SparseSortOrder.rebalance', () {
    test('spaces items by gap starting at gap', () {
      expect(SparseSortOrder.rebalance(3), [1000, 2000, 3000]);
    });

    test('empty column yields empty list', () {
      expect(SparseSortOrder.rebalance(0), isEmpty);
    });
  });
}
