import 'dart:math';
import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/position.dart';

class NearestPositionNeighbor {
  Hospital get(Position patientPosition, List<Hospital> hospitals) {
    if (hospitals == null) {
      throw new ArgumentError("Hospitals list should not be null.");
    }

    final hospitalsNumber = hospitals.length;
    if (hospitalsNumber < 1) {
      throw new ArgumentError("Should pass at least one hospital.");
    } else if (hospitalsNumber == 1) {
      return hospitals[0];
    }

    var nearestHospital = hospitals[0];
    double minDistance = _getDistanceBetween(
      patientPosition,
      hospitals[0].position,
    );

    for (var i = 1; i < hospitalsNumber; i++) {
      var hospitalPosition = hospitals[i].position;

      double distance = _getDistanceBetween(patientPosition, hospitalPosition);
      if (distance < minDistance) {
        minDistance = distance;
        nearestHospital = hospitals[i];
      } else if (distance == minDistance) {
        nearestHospital = _getHospitalWithMoreAvailableBeds(
          nearestHospital,
          hospitals[i],
        );
      }
    }

    return nearestHospital;
  }

  double _getDistanceBetween(Position patient, Position hospital) {
    double distance =
        sqrt(pow(patient.x - hospital.x, 2) + pow(patient.y - hospital.y, 2));
    return distance;
  }

  Hospital _getHospitalWithMoreAvailableBeds(Hospital first, Hospital second) {
    if (first.availableBeds >= second.availableBeds) {
      return first;
    } else {
      return second;
    }
  }
}
