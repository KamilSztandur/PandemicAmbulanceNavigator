class Vertex {
  Vertex(this.hospitalId);

  final int hospitalId;
  final neighbors = <Vertex, double>{};

  bool get hasConnections => neighbors.length > 0;

  void addNeighbor(Vertex neighbor, double lengthOfRoad) {
    neighbors.putIfAbsent(neighbor, () => lengthOfRoad);
  }
}
