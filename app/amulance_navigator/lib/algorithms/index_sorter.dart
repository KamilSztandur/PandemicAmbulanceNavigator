class IndexSorter {
  static List<int> getAsSortedList(int firstID, int secondID, int thirdID) {
    var sortedList = [firstID, secondID, thirdID];

    if (sortedList[0] > sortedList[2]) {
      var temp = sortedList[0];
      sortedList[0] = sortedList[2];
      sortedList[2] = temp;
    }

    if (sortedList[0] > sortedList[1]) {
      var temp = sortedList[0];
      sortedList[0] = sortedList[1];
      sortedList[1] = temp;
    }

    if (sortedList[1] > sortedList[2]) {
      var temp = sortedList[1];
      sortedList[1] = sortedList[2];
      sortedList[2] = temp;
    }

    return sortedList;
  }
}
