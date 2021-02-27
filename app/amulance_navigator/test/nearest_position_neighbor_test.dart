import 'package:amulance_navigator/algorithms/nearest_position_neighbor.dart';
import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Nearest Point Algorithm", () {
    NearestPositionNeighbor algorithm;
    Position patientPosition;
    List<Hospital> hospitals;

    setUp(() {
      algorithm = NearestPositionNeighbor();
      hospitals = _generateHospitalList(10, false);
    });

    test("should return nearest hospital ref to patient position", () {
      patientPosition = Position(7.6, 7.6);

      final result = algorithm.get(patientPosition, hospitals);
      expect(result, hospitals[8]);
    });

    test("should return hospital with more available beds if equal distances",
        () {
      patientPosition = Position(7.5, 7.5);

      final result = algorithm.get(patientPosition, hospitals);
      expect(result, hospitals[8]);
    });

    test("should return first if available beds and distances are equal", () {
      patientPosition = Position(0.5, 0.5);
      hospitals = _generateHospitalList(2, true);

      final result = algorithm.get(patientPosition, hospitals);
      expect(result, hospitals[0]);
    });

    test("should throw ArgumentError if hospitals list is null", () {
      patientPosition = Position(0.0, 0.0);
      hospitals = null;

      expect(
        () => algorithm.get(patientPosition, hospitals),
        throwsArgumentError,
      );
    });

    test("Should throw ArgumentError if hospitals List is empty", () {
      patientPosition = Position(0.0, 0.0);
      hospitals = <Hospital>[];

      expect(
        () => algorithm.get(patientPosition, hospitals),
        throwsArgumentError,
      );
    });
  });
}

List<Hospital> _generateHospitalList(int size, bool availableBedsAreEqual) {
  var hospitals = <Hospital>[];

  for (var i = 0; i < size; i++) {
    var bedsAmount = availableBedsAreEqual ? 100 : (i + 1) * 100;

    hospitals.add(new Hospital(
      id: i,
      name: "Szpital nr. " + i.toString(),
      position: new Position(i.toDouble(), i.toDouble()),
      capacity: bedsAmount,
      availableBeds: bedsAmount,
    ));
  }

  return hospitals;
}
