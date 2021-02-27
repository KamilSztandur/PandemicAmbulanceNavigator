import 'package:amulance_navigator/models/vertex.dart';
import 'package:amulance_navigator/algorithms/dijkstra_shortest_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Dijkstra", () {
    List<Vertex> vertices;
    List<int> visitedHospitals;

    setUp(() {
      final h1 = Vertex(0);
      final h2 = Vertex(1);
      final h3 = Vertex(2);
      final h4 = Vertex(3);
      final he = Vertex(4);
      final hf = Vertex(5);

      h1.addNeighbor(h2, 120);
      h2.addNeighbor(h1, 120);
      h2.addNeighbor(h3, 350);
      h3.addNeighbor(h2, 350);
      h2.addNeighbor(h4, 700);
      h4.addNeighbor(h2, 700);
      h3.addNeighbor(h4, 200);
      h4.addNeighbor(h3, 200);
      h3.addNeighbor(he, 50);
      he.addNeighbor(h3, 50);
      h3.addNeighbor(hf, 100);
      hf.addNeighbor(h3, 100);
      he.addNeighbor(hf, 30);
      hf.addNeighbor(he, 30);

      vertices = [
        h1,
        h2,
        h3,
        h4,
        he,
        hf,
      ];

      visitedHospitals = [
        h2.hospitalId,
        he.hospitalId,
      ];
    });

    test("Should find the shortest route straight forward", () {
      var algorithm = DijkstraShortestRoute();
      var indexOfSource = 1;

      List<Vertex> result = algorithm.findTheShortestRoute(
        vertices,
        indexOfSource,
        visitedHospitals,
      );

      var expectedResult = vertices[0];
      expect(result.last, expectedResult);
    });

    test("Should find the shortest route through already visited hospital B",
        () {
      var algorithm = DijkstraShortestRoute();
      var indexOfSource = 0;

      List<Vertex> result = algorithm.findTheShortestRoute(
        vertices,
        indexOfSource,
        visitedHospitals,
      );

      expect(result.last, vertices[2]);
    });

    test("Should find the shortest route through already visited hospital E",
        () {
      var algorithm = DijkstraShortestRoute();
      var indexOfSource = 2;

      List<Vertex> result = algorithm.findTheShortestRoute(
        vertices,
        indexOfSource,
        visitedHospitals,
      );

      var expLast = vertices[5];
      var expPenultimate = vertices[4];

      expect(result.last, expLast);
      expect(result[result.length - 2], expPenultimate);
    });

    test("Should find the way through multiple hospitals", () {
      var hospitalC = vertices[2];
      visitedHospitals.add(hospitalC.hospitalId);

      var algorithm = DijkstraShortestRoute();
      var indexOfSource = 0;

      List<Vertex> result = algorithm.findTheShortestRoute(
        vertices,
        indexOfSource,
        visitedHospitals,
      );

      var expectedF = vertices[5];
      expect(result.last, expectedF);
    });

    test("Should throw argument error because of bad index", () {
      var algorithm = DijkstraShortestRoute();

      expect(
        () => algorithm.findTheShortestRoute(List.empty(), 0, visitedHospitals),
        throwsArgumentError,
      );
    });

    test("Should throw argument error because of null argument", () {
      var algorithm = DijkstraShortestRoute();
      var indexOfSource = 2;

      expect(
        () => algorithm.findTheShortestRoute(vertices, indexOfSource, null),
        throwsArgumentError,
      );
    });
  });
}
