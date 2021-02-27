import 'package:amulance_navigator/algorithms/shape_membership_validator.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';
import '../shape_membership_validator_test.dart';

import 'dart:math';
import 'dart:io';

void main() {
  print("Init");
  var patientsAmount = 1;

  var avgTimesGroup = <double>[];
  var avgTimesInd = <double>[];

  for (int i = 3; i <= 53; i++) {
    print("Testuję dla $i border markerów...");
    var avgInd = 0.0;
    var avgGr = 0.0;

    for (int j = 0; j < 10; j++) {
      var patients = getPatients(patientsAmount);
      var borderMarkers = getBorderMarkers(i);
      var validator = new ShapeMembershipValidator(borderMarkers);

      var stopwatch1 = new Stopwatch()..start();
      validator.getOnlyPatientsInsideCountryFrom(patients);
      avgGr += stopwatch1.elapsed.inMicroseconds;

      var stopwatch2 = new Stopwatch()..start();
      patients.forEach(
        (patient) => (validator.contains(patient)),
      );
      avgInd += stopwatch2.elapsed.inMicroseconds;
    }

    avgTimesInd.add(avgInd / 10.0);
    avgTimesGroup.add(avgGr / 10.0);
  }

  print("Wyniki dla $patientsAmount pacjentów:");

  print("Grupowy:");
  for (var result in avgTimesInd) {
    //print("$result ms dla ${avgTimesInd.indexOf(result) + 3} bordermarków");
    stdout.write(result.toInt().toString() + "\n");
  }

  print("Indywidualny:");
  for (var result in avgTimesGroup) {
    //print("$result ms dla ${avgTimesGroup.indexOf(result) + 3} bordermarków");
    stdout.write(result.toInt().toString() + "\n");
  }
}

List<Patient> getPatients(int n) {
  var patients = <Patient>[];
  for (int i = 0; i < n; i++) {
    patients.add(getDummyPatient(i, i));
  }

  return patients;
}

List<Place> getBorderMarkers(int n) {
  var borderMarkers = <Place>[];
  var random = Random();

  for (int i = 0; i < n; i++) {
    borderMarkers.add(
      new Place(
        id: i,
        name: getRandDummyName(10, random),
        position: new Position(
          random.nextDouble() * 1000,
          random.nextDouble() * 1000,
        ),
      ),
    );
  }

  return borderMarkers;
}
