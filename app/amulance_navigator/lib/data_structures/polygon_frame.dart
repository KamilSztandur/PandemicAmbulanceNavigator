import 'package:amulance_navigator/algorithms/index_sorter.dart';

class PolygonFrame {
  int firstVerticeIndex;
  int secondVerticeIndex;
  int thirdVerticeIndex;

  PolygonFrame(int first, int second, int third) {
    if (first == second || second == third || first == third) {
      throw ArgumentError("No index duplicates allowed.");
    }

    var sortedIndexes = IndexSorter.getAsSortedList(first, second, third);

    this.firstVerticeIndex = sortedIndexes[0];
    this.secondVerticeIndex = sortedIndexes[1];
    this.thirdVerticeIndex = sortedIndexes[2];
  }

  bool equalsTo(PolygonFrame other) {
    return other.firstVerticeIndex == this.firstVerticeIndex &&
        other.secondVerticeIndex == this.secondVerticeIndex &&
        other.thirdVerticeIndex == this.thirdVerticeIndex;
  }

  @override
  String toString() {
    return "{" +
        firstVerticeIndex.toString() +
        ", " +
        secondVerticeIndex.toString() +
        ", " +
        thirdVerticeIndex.toString() +
        "}";
  }
}
