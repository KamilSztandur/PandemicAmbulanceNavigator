import 'package:amulance_navigator/algorithms/index_sorter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Index Sorter", () {
    test("should sort correctly for already sorted indexes", () {
      final sortedList = IndexSorter.getAsSortedList(0, 1, 2);
      expect(_isSorted(sortedList), true);
    });

    test("should sort correctly for various combinations", () {
      final sortedList1 = IndexSorter.getAsSortedList(0, 1, 2);
      final sortedList2 = IndexSorter.getAsSortedList(2, 1, 0);
      final sortedList3 = IndexSorter.getAsSortedList(2, 0, 1);
      final sortedList4 = IndexSorter.getAsSortedList(1, 0, 2);
      final sortedList5 = IndexSorter.getAsSortedList(0, 2, 1);
      final sortedList6 = IndexSorter.getAsSortedList(1, 2, 0);

      expect(_isSorted(sortedList1), true);
      expect(_isSorted(sortedList2), true);
      expect(_isSorted(sortedList3), true);
      expect(_isSorted(sortedList4), true);
      expect(_isSorted(sortedList5), true);
      expect(_isSorted(sortedList6), true);
    });

    test("should sort correctly for various combinations with duplicates", () {
      final sortedList1 = IndexSorter.getAsSortedList(0, 0, 0);
      final sortedList2 = IndexSorter.getAsSortedList(0, 1, 1);
      final sortedList3 = IndexSorter.getAsSortedList(1, 1, 0);
      final sortedList4 = IndexSorter.getAsSortedList(1, 0, 1);

      expect(_isSorted(sortedList1), true);
      expect(_isSorted(sortedList2), true);
      expect(_isSorted(sortedList3), true);
      expect(_isSorted(sortedList4), true);
    });
  });
}

bool _isSorted(List<int> list) {
  if (list[0] <= list[1] && list[1] <= list[2]) {
    return true;
  } else {
    return false;
  }
}
