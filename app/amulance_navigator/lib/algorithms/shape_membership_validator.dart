import 'package:amulance_navigator/data_structures/polygon_frame.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:dart_numerics/dart_numerics.dart';

class ShapeMembershipValidator {
  static const MAX_X = int64MaxValue;
  List<Position> borderMarkersPositions;
  List<PolygonFrame> _subPolygonsFrames;

  ShapeMembershipValidator(List<Place> borderMarkers) {
    this.borderMarkersPositions = _toPositionList(borderMarkers);
    this._subPolygonsFrames = _createSubPolygonsList(
      this.borderMarkersPositions,
    );
  }

  List<Patient> getOnlyPatientsInsideCountryFrom(List<Patient> patients) {
    final patientsAmount = patients.length;
    var patientsFlags = _createPatientsFlagList(patientsAmount);

    for (var subPolygonFrame in this._subPolygonsFrames) {
      var singlePolygon = _createSubPolygonFromIndexes(
        subPolygonFrame.firstVerticeIndex,
        subPolygonFrame.secondVerticeIndex,
        subPolygonFrame.thirdVerticeIndex,
      );

      for (int id = 0; id < patientsAmount; id++) {
        if (patientsFlags[id] == false) {
          var patientPosition = patients[id].position;

          if (_isInsideSinglePolygon(singlePolygon, patientPosition)) {
            patientsFlags[id] = true;
          }
        }
      }
    }

    for (int id = 0; id < patientsAmount; id++) {
      if (patientsFlags[id] == false) {
        patientsFlags[id] = _isOnAnyVertice(patients[id].position);
      }
    }

    var patientsInsideCountry = _getPatientsByFlags(patients, patientsFlags);
    return patientsInsideCountry;
  }

  bool contains(Patient patient) {
    final patientPosition = patient.position;
    var isInside = false;

    for (var subPolygonFrame in this._subPolygonsFrames) {
      if (isInside) {
        break;
      }

      var singlePolygon = _createSubPolygonFromIndexes(
        subPolygonFrame.firstVerticeIndex,
        subPolygonFrame.secondVerticeIndex,
        subPolygonFrame.thirdVerticeIndex,
      );

      if (_isInsideSinglePolygon(singlePolygon, patientPosition)) {
        isInside = true;
      }
    }

    if (isInside == false) {
      isInside = _isOnAnyVertice(patientPosition);
    }

    return isInside;
  }

  List<bool> _createPatientsFlagList(int patientsAmount) {
    var flagList = List<bool>.generate(
      patientsAmount,
      (flag) => false,
    );

    return flagList;
  }

  List<Position> _createSubPolygonFromIndexes(int i, int j, int k) {
    var subPolygon = <Position>[];
    subPolygon.add(borderMarkersPositions[i]);
    subPolygon.add(borderMarkersPositions[j]);
    subPolygon.add(borderMarkersPositions[k]);

    return subPolygon;
  }

  List<Position> _toPositionList(List<Place> borderMarkers) {
    var positions = <Position>[];

    borderMarkers.forEach(
      (borderPlace) => positions.add(borderPlace.position),
    );

    return positions;
  }

  List<Patient> _getPatientsByFlags(List<Patient> patients, List<bool> flags) {
    var patientsWithActiveFlags = <Patient>[];

    final n = patients.length;
    for (int id = 0; id < n; id++) {
      if (flags[id] == true) {
        patientsWithActiveFlags.add(patients[id]);
      }
    }

    return patientsWithActiveFlags;
  }

  List<PolygonFrame> _createSubPolygonsList(List<Position> borderMarkers) {
    final verticesAmount = borderMarkers.length;
    var subPolygonsFrames = <PolygonFrame>[];

    for (int i = 0; i < verticesAmount; i++) {
      for (int j = 0; j < verticesAmount; j++) {
        for (int k = 0; k < verticesAmount; k++) {
          if (k == j || k == i || j == i) {
            continue;
          } else {
            var subPolygonFrame = PolygonFrame(i, j, k);

            if (!_isDuplicated(subPolygonsFrames, subPolygonFrame)) {
              subPolygonsFrames.add(subPolygonFrame);
            }
          }
        }
      }
    }

    return subPolygonsFrames;
  }

  bool _isDuplicated(List<PolygonFrame> controlList, PolygonFrame frame) {
    for (var frameInList in controlList) {
      if (frameInList.equalsTo(frame)) {
        return true;
      }
    }

    return false;
  }

  /* Algorithm functions */
  bool _isOnAnyVertice(Position point) {
    for (var verticePosition in borderMarkersPositions) {
      if (point.equalsTo(verticePosition)) {
        return true;
      }
    }

    return false;
  }

  bool isAtHeightOfAnyBorderMarkers(Position point) {
    for (var i = 0; i < borderMarkersPositions.length; i++) {
      if (borderMarkersPositions[i].y == point.y) {
        return true;
      }
    }

    return false;
  }

  int _howManyIntersectionsWithBorderMarkers(Position point) {
    var intersectionsCounter = 0;
    for (var i = 0; i < borderMarkersPositions.length; i++) {
      if (borderMarkersPositions[i].y == point.y &&
          borderMarkersPositions[i].x >= point.x) {
        intersectionsCounter++;
      }
    }

    return intersectionsCounter;
  }

  bool _isInsideSinglePolygon(List<Position> polygon, Position point) {
    var extreme = new Position(MAX_X.toDouble(), point.y);
    var count = 0, i = 0;

    do {
      var next = (i + 1) % 3;
      if (_doIntersect(polygon[i], polygon[next], point, extreme)) {
        if (_orientation(polygon[i], point, polygon[next]) == 0) {
          return _isInsideSquareRange(polygon[i], point, polygon[next]);
        }

        count++;
      }

      i = next;
    } while (i != 0);
    if (isAtHeightOfAnyBorderMarkers(point)) {
      var borderIntersections = count;
      var borderMarkersIntersections = _howManyIntersectionsWithBorderMarkers(
        point,
      );

      var allIntersections = borderIntersections + borderMarkersIntersections;
      return allIntersections % 2 == 1;
    } else {
      var isInsideThisPolygon = count % 2 == 1;
      return isInsideThisPolygon;
    }
  }

  bool _doIntersect(Position p1, Position q1, Position p2, Position q2) {
    final o1 = _orientation(p1, q1, p2);
    final o2 = _orientation(p1, q1, q2);
    final o3 = _orientation(p2, q2, p1);
    final o4 = _orientation(p2, q2, q1);

    if (o1 != o2 && o3 != o4) {
      return true;
    }

    if (o1 == 0 && _isInsideSquareRange(p1, p2, q1)) {
      return true;
    }

    if (o2 == 0 && _isInsideSquareRange(p1, q2, q1)) {
      return true;
    }

    if (o3 == 0 && _isInsideSquareRange(p2, p1, q2)) {
      return true;
    }

    if (o4 == 0 && _isInsideSquareRange(p2, q1, q2)) {
      return true;
    }

    return false;
  }

  int _orientation(Position point, Position p1, Position p2) {
    final val =
        (p1.y - point.y) * (p2.x - p1.x) - (p1.x - point.x) * (p2.y - p1.y);

    if (val == 0) {
      return 0;
    } else {
      return (val > 0) ? 1 : 2;
    }
  }

  bool _isInsideSquareRange(Position p1, Position p2, Position point) {
    if (_isInsideXRange(point, p1, p2) && _isInsideYRange(point, p1, p2)) {
      return true;
    } else {
      return false;
    }
  }

  bool _isInsideYRange(Position p1, Position p2, Position point) {
    double min, max;
    if (p1.y > p2.y) {
      min = p2.y;
      max = p1.y;
    } else {
      min = p1.y;
      max = p2.y;
    }

    return (point.y >= min && point.y <= max);
  }

  bool _isInsideXRange(Position p1, Position p2, Position point) {
    double min, max;
    if (p1.x > p2.x) {
      min = p2.x;
      max = p1.x;
    } else {
      min = p1.x;
      max = p2.x;
    }

    return (point.x > min && point.x < max);
  }
}
