import 'package:amulance_navigator/models/vertex.dart';

class DijkstraShortestRoute {
  List<Vertex> findTheShortestRoute(List<Vertex> vertices,
      int indexOfSourceHospital, List<int> visitedHospitals) {
    if (vertices == null || visitedHospitals == null) {
      throw new ArgumentError("Lists cannot be null.");
    }

    if (indexOfSourceHospital >= vertices.length || indexOfSourceHospital < 0) {
      throw new ArgumentError("Bad index.");
    }

    Map<Vertex, _Properties> verticesWithProps = Map();

    for (int i = 0; i < vertices.length; i++) {
      double wage = i == indexOfSourceHospital ? 0 : 1.0 / 0.0;
      verticesWithProps.putIfAbsent(vertices[i], () => _Properties(wage));
    }

    List<Vertex> undone = List.from(vertices);
    List<Vertex> done = [];

    while (undone.isNotEmpty) {
      Vertex current = undone
          .removeAt(_pickIndexOfTheSmallestWage(undone, verticesWithProps));
      done.add(current);

      current.neighbors.forEach((neighbor, lengthOfRoad) {
        double lengthOfRoadThroughCurrent =
            verticesWithProps[current].cost + lengthOfRoad;

        if (verticesWithProps[neighbor].cost > lengthOfRoadThroughCurrent) {
          verticesWithProps[neighbor].cost = lengthOfRoadThroughCurrent;
          verticesWithProps[neighbor].last = current;
        }
      });
    }

    List<Vertex> followingVertices = [];
    final hospital = _getFirstUnvisitedHospital(done, visitedHospitals);

    if (hospital == null) {
      return null;
    }

    _prepareListOfVertices(
      hospital,
      verticesWithProps,
      followingVertices,
    );

    return followingVertices;
  }

  Vertex _getFirstUnvisitedHospital(
    List<Vertex> vertices,
    List<int> visitedHospitals,
  ) =>
      vertices.skip(1).firstWhere(
            (vertex) =>
                vertex.hospitalId != null &&
                !visitedHospitals.contains(vertex.hospitalId),
            orElse: () => null,
          );

  void _prepareListOfVertices(
    Vertex hospital,
    Map<Vertex, _Properties> map,
    List<Vertex> followingVertices,
  ) {
    if (hospital != null) {
      _prepareListOfVertices(
        map[hospital].last,
        map,
        followingVertices,
      );
      followingVertices.add(hospital);
    }
  }

  int _pickIndexOfTheSmallestWage(
    List<Vertex> vertices,
    Map<Vertex, _Properties> hospitalsWithProps,
  ) {
    double value = double.infinity;
    int result = -1;

    for (int i = 0; i < vertices.length; i++) {
      double next = hospitalsWithProps[vertices[i]].cost;
      if (next < value) {
        value = next;
        result = i;
      }
    }

    return result;
  }
}

class _Properties {
  Vertex last;
  double cost;

  _Properties(double cost) {
    this.cost = cost;
  }
}
