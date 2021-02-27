import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:amulance_navigator/models/road.dart';
import 'package:meta/meta.dart';

class CrossRoadsFinder {
  List<Road> splitRoads(List<Hospital> hospitals, List<Road> roads) {
    final roadsCopy = [...roads];

    for (var i = 0; i < roadsCopy.length; i++) {
      final road1 = roadsCopy[i];

      for (var j = i; j < roadsCopy.length; j++) {
        final road2 = roadsCopy[j];

        final crossing = calculatePositionOfCrossroad(road1, road2);

        if (crossing != null &&
            !crossing.equalsTo(road1.source) &&
            !crossing.equalsTo(road1.destination) &&
            !crossing.equalsTo(road2.source) &&
            !crossing.equalsTo(road2.destination)) {
          roadsCopy[i] = Road(
            source: road1.source,
            destination: crossing,
            length: crossing.distance(road1.source) /
                road1.source.distance(road1.destination) *
                road1.length,
          );
          roadsCopy.add(
            Road(
              source: road1.destination,
              destination: crossing,
              length: crossing.distance(road1.destination) /
                  road1.source.distance(road1.destination) *
                  road1.length,
            ),
          );
          roadsCopy[j] = Road(
            source: road2.source,
            destination: crossing,
            length: crossing.distance(road2.source) /
                road2.source.distance(road2.destination) *
                road2.length,
          );
          roadsCopy.add(
            Road(
              source: road2.destination,
              destination: crossing,
              length: crossing.distance(road2.destination) /
                  road2.source.distance(road2.destination) *
                  road2.length,
            ),
          );
        }
      }
    }

    return roadsCopy;
  }

  @visibleForTesting
  Position calculatePositionOfCrossroad(Road road1, Road road2) {
    if (road1 == null || road2 == null) {
      throw ArgumentError("Road cannot be null.");
    }

    if (road1.isVertical() && road2.isVertical()) {
      return null;
    } else if (road1.isVertical()) {
      return _solveWithVerticalRoad(road1, road2);
    } else if (road2.isVertical()) {
      return _solveWithVerticalRoad(road2, road1);
    }

    List<double> tmp = _calculateEquationOfRoad(road1);
    if (tmp == null) {
      return null;
    }
    double a1 = tmp[0];
    double b1 = tmp[1];

    tmp = _calculateEquationOfRoad(road2);
    if (tmp == null) {
      return null;
    }
    double a2 = tmp[0];
    double b2 = tmp[1];

    double wPos = _calculateDet(a1, -1, a2, -1);
    double wxPos = _calculateDet(-b1, -1, -b2, -1);
    double wyPos = _calculateDet(a1, -b1, a2, -b2);
    if (wPos == null) {
      return null;
    }

    Position result = new Position(wxPos / wPos, wyPos / wPos);
    return _isFine(road1, road2, result) ? result : null;
  }

  Position _solveWithVerticalRoad(Road verticalRoad, Road notVerticalRoad) {
    List<double> tmp = _calculateEquationOfRoad(notVerticalRoad);
    if (tmp == null) {
      return null;
    }

    double a = tmp[0];
    double b = tmp[1];
    double x = verticalRoad.source.x;

    Position result = new Position(x, a * x + b);

    return _isFine(verticalRoad, notVerticalRoad, result) ? result : null;
  }

  List<double> _calculateEquationOfRoad(Road road) {
    double w = _calculateDet(road.source.x, 1, road.destination.x, 1);
    if (w == 0) {
      return null;
    }

    double wa = _calculateDet(road.source.y, 1, road.destination.y, 1);

    double wb = _calculateDet(
        road.source.x, road.source.y, road.destination.x, road.destination.y);

    double a = wa / w;
    double b = wb / w;

    return [a, b];
  }

  double _calculateDet(double a11, double a12, double a21, double a22) {
    return a11 * a22 - a12 * a21;
  }

  bool _isFine(Road road1, Road road2, Position pos) {
    return _isOnRoad(pos, road1) && _isOnRoad(pos, road2);
  }

  bool _isOnRoad(Position posOfCrossRoad, Road road) {
    double x = posOfCrossRoad.x;
    double y = posOfCrossRoad.y;
    return ((x <= road.source.x && x >= road.destination.x) ||
            (x >= road.source.x && x <= road.destination.x)) &&
        ((y <= road.source.y && y >= road.destination.y) ||
            (y >= road.source.y && y <= road.destination.y));
  }
}
