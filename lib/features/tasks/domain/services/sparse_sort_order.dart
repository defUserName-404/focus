/// Sparse gap ordering for board-style lists.
///
/// Cards are spaced by [gap] so a single-item reorder usually needs only one
/// row update (midpoint between neighbours) instead of rewriting the column.
abstract final class SparseSortOrder {
  static const double gap = 1000;

  /// Minimum separation before a full-column rebalance is recommended.
  static const double minGap = 0.001;

  /// Sort order for a new card appended after [lastOrder].
  static double append([double? lastOrder]) {
    if (lastOrder == null) return gap;
    return lastOrder + gap;
  }

  /// Sort order for inserting before the current first card.
  static double prepend(double firstOrder) => firstOrder - gap;

  /// Sort order between [before] and [after] neighbours.
  ///
  /// Returns `null` when the midpoint would collapse below [minGap], signalling
  /// the caller should [rebalance] the column then retry.
  static double? between({required double before, required double after}) {
    if (after - before <= minGap * 2) return null;
    return (before + after) / 2;
  }

  /// Compute the sort order for placing an item at [insertIndex] among
  /// [neighborOrders] (the column orders **excluding** the moved item).
  ///
  /// [insertIndex] is the destination index in that neighbour list
  /// (`0` = before first, `neighborOrders.length` = after last).
  ///
  /// Returns `null` when a midpoint would collapse — caller should rebalance.
  static double? forInsert({required List<double> neighborOrders, required int insertIndex}) {
    if (neighborOrders.isEmpty) return gap;

    final clamped = insertIndex.clamp(0, neighborOrders.length);
    if (clamped == 0) return prepend(neighborOrders.first);
    if (clamped == neighborOrders.length) return append(neighborOrders.last);

    return between(before: neighborOrders[clamped - 1], after: neighborOrders[clamped]);
  }

  /// Full-column rewrite using evenly spaced gaps starting at [gap].
  static List<double> rebalance(int count) {
    return List<double>.generate(count, (index) => (index + 1) * gap);
  }
}
