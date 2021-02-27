import 'package:amulance_navigator/algorithms/crossroads_finder.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:amulance_navigator/models/road.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Main group", () {
    test("Should find proper position", () {
      final p1 = Position(-7, 7);
      final p2 = Position(2, -2);
      final p3 = Position(-17, 2);
      final p4 = Position(44, 2);

      var algorithm = CrossRoadsFinder();
      var road1 = Road(
        source: p1,
        destination: p2,
        length: 1,
      );
      var road2 = Road(
        source: p3,
        destination: p4,
        length: 1,
      );

      Position result = algorithm.calculatePositionOfCrossroad(road1, road2);
      var expectedX = -2;
      var expectedY = 2;

      expect(result.x, expectedX);
      expect(result.y, expectedY);
    });

    test("Should find proper position again", () {
      final p1 = Position(-8, -6);
      final p2 = Position(-2, -3);
      final p3 = Position(-7, 1);
      final p4 = Position(1, -7);

      var algorithm = CrossRoadsFinder();
      var road1 = Road(
        source: p1,
        destination: p2,
        length: 1,
      );
      var road2 = Road(
        source: p3,
        destination: p4,
        length: 1,
      );

      Position result = algorithm.calculatePositionOfCrossroad(road1, road2);
      var expectedX = -8.0 / 3.0;
      var expectedY = -10.0 / 3.0;
      expect(result.x, expectedX);
      expect(result.y, expectedY);
    });

    test("Should find proper position when one of the roads is vertical", () {
      final p1 = Position(2, -420);
      final p2 = Position(2, 420);
      final p3 = Position(-3, -6);
      final p4 = Position(4, 8);

      var algorithm = CrossRoadsFinder();
      var road1 = Road(
        source: p1,
        destination: p2,
        length: 1,
      );
      var road2 = Road(
        source: p3,
        destination: p4,
        length: 1,
      );

      Position result = algorithm.calculatePositionOfCrossroad(road1, road2);
      var expectedX = 2;
      var expectedY = 4;
      expect(result.x, expectedX);
      expect(result.y, expectedY);
    });

    test("Should return null when the roads don't cross", () {
      final p1 = Position(-2, -4);
      final p2 = Position(20, -5);
      final p3 = Position(0, -4);
      final p4 = Position(44, 7);

      var algorithm = CrossRoadsFinder();
      var road1 = Road(
        source: p1,
        destination: p2,
        length: 1,
      );
      var road2 = Road(
        source: p3,
        destination: p4,
        length: 1,
      );

      Position result = algorithm.calculatePositionOfCrossroad(road1, road2);
      expect(result, null);
    });

    test(
        "Should find proper position of crossing vartical road with horizontal one",
        () {
      final p1 = Position(2, -6);
      final p2 = Position(2, 3);
      final p3 = Position(-9, 1);
      final p4 = Position(3, 1);

      var algorithm = CrossRoadsFinder();
      var road1 = Road(
        source: p1,
        destination: p2,
        length: 1,
      );
      var road2 = Road(
        source: p3,
        destination: p4,
        length: 1,
      );

      Position result = algorithm.calculatePositionOfCrossroad(road1, road2);
      var expectedX = 2;
      var expectedY = 1;
      expect(result.x, expectedX);
      expect(result.y, expectedY);
    });

    test("Should throw argument error", () {
      var algorithm = CrossRoadsFinder();

      expect(() => algorithm.calculatePositionOfCrossroad(null, null),
          throwsArgumentError);
    });

    test("Should return null when roads are parallel", () {
      final p1 = Position(-2, -1);
      final p2 = Position(2, 3);
      final p3 = Position(-1, -2);
      final p4 = Position(3, 2);

      var algorithm = CrossRoadsFinder();
      var road1 = Road(
        source: p1,
        destination: p2,
        length: 1,
      );
      var road2 = Road(
        source: p3,
        destination: p4,
        length: 1,
      );

      Position result = algorithm.calculatePositionOfCrossroad(road1, road2);
      expect(result, null);
    });
  });
}
