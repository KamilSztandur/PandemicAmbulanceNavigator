import 'package:amulance_navigator/algorithms/shape_membership_validator.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';

import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

void main() {
  group("Shape Membership Validator", () {
    ShapeMembershipValidator validator;
    List<Patient> patients;
    List<Place> borderMarkers;

    tearDown(() {
      borderMarkers = null;
      patients = null;
      validator = null;
    });

    test("should pass test for data from ISOD", () {
      borderMarkers = getISODBorderMarkers();
      patients = getISODPatients();
      validator = ShapeMembershipValidator(borderMarkers);

      final result = validator.getOnlyPatientsInsideCountryFrom(patients);
      expect(result.isEmpty, true);
    });

    test("should not throw exception when all points are in one line", () {
      patients = getPatientsOnBordersForOneLineTest();
      borderMarkers = getBorderMarkersForOneLineTest();

      validator = ShapeMembershipValidator(borderMarkers);
      validator.getOnlyPatientsInsideCountryFrom(patients);
    });

    test("should detect internal points inside single triangular polygon", () {
      var polygon = getBorderMarkersForTriangularTest();
      var patients = getPatientsForTriangularTest();
      validator = ShapeMembershipValidator(polygon);

      expect(validator.contains(patients[0]), false);
      expect(validator.contains(patients[1]), false);
      expect(validator.contains(patients[2]), false);
      expect(validator.contains(patients[3]), true);
    });

    test("should find patients at the same height like bordermarkers", () {
      var polygon = getBorderMarkersForHeightTest();
      var patients = getPatientsForHeightTest();
      validator = ShapeMembershipValidator(polygon);

      expect(
        validator.isAtHeightOfAnyBorderMarkers(patients[0].position),
        true,
      );
      expect(
        validator.isAtHeightOfAnyBorderMarkers(patients[1].position),
        true,
      );
      expect(
        validator.isAtHeightOfAnyBorderMarkers(patients[2].position),
        true,
      );
      expect(
        validator.isAtHeightOfAnyBorderMarkers(patients[3].position),
        false,
      );
    });

    test("should detect internal point inside advanced shape", () {
      borderMarkers = getBorderMarkersForAdvancedShapeTest();
      patients = getPatientsForAdvancedShapeTest();
      validator = ShapeMembershipValidator(borderMarkers);

      expect(validator.contains(patients[0]), true);
      expect(validator.contains(patients[1]), true);
      expect(validator.contains(patients[2]), true);
      expect(validator.contains(patients[3]), true);
      expect(validator.contains(patients[4]), true);
      expect(validator.contains(patients[5]), false);
    });

    test("should detect internal point inside advanced shape on vertices", () {
      borderMarkers = getBorderMarkersForAdvancedShapeTest();
      patients = getPatientsOnVerticesForAdvancedShapeTest();
      validator = ShapeMembershipValidator(borderMarkers);

      expect(true, validator.contains(patients[0]));
      expect(true, validator.contains(patients[1]));
      expect(true, validator.contains(patients[2]));
      expect(true, validator.contains(patients[3]));
      expect(false, validator.contains(patients[4]));
    });

    test("should work correctly with negative coordinates", () {
      borderMarkers = getBorderMarkersForNegativeCoordsTest();
      patients = getPatientsForNegativeCoordsTest();
      validator = ShapeMembershipValidator(borderMarkers);

      expect(validator.contains(patients[0]), true);
      expect(validator.contains(patients[1]), false);
      expect(validator.contains(patients[2]), false);
      expect(validator.contains(patients[3]), false);
    });
  });
}

/* Data getters for testing methods (also used by SMV visualizer) */
Patient getDummyPatient(int x, int y) {
  return new Patient(
    0,
    new Position(x.toDouble(), y.toDouble()),
  );
}

List<Place> getBorderMarkersForHeightTest() {
  var random = Random();
  var polygon = <Place>[];

  polygon.add(new Place(
      id: 1,
      name: getRandDummyName(1, random),
      position: new Position(400, 1000)));

  polygon.add(new Place(
      id: 2,
      name: getRandDummyName(1, random),
      position: new Position(1000, 800)));

  polygon.add(new Place(
      id: 3,
      name: getRandDummyName(1, random),
      position: new Position(500, 700)));

  return polygon;
}

List<Patient> getPatientsForHeightTest() {
  var patients = <Patient>[];
  patients.add(getDummyPatient(400, 800));
  patients.add(getDummyPatient(800, 700));
  patients.add(getDummyPatient(700, 1000));
  patients.add(getDummyPatient(600, 850));

  return patients;
}

List<Place> getBorderMarkersForTriangularTest() {
  var random = new Random();
  var polygon = <Place>[];

  polygon.add(new Place(
      id: 1,
      name: getRandDummyName(1, random),
      position: new Position(400, 1500)));

  polygon.add(new Place(
      id: 2,
      name: getRandDummyName(1, random),
      position: new Position(1000, 1300)));

  polygon.add(new Place(
      id: 3,
      name: getRandDummyName(1, random),
      position: new Position(500, 1200)));

  return polygon;
}

List<Patient> getPatientsForTriangularTest() {
  var patients = <Patient>[];
  patients.add(new Patient(1, new Position(400, 1300)));
  patients.add(new Patient(2, new Position(800, 1200)));
  patients.add(new Patient(3, new Position(700, 1500)));
  patients.add(new Patient(4, new Position(600, 1350)));

  return patients;
}

List<Patient> getPatientsForAdvancedShapeTest() {
  var patients = <Patient>[];
  patients.add(new Patient(1, new Position(400, 400)));
  patients.add(new Patient(2, new Position(400, 800)));
  patients.add(new Patient(3, new Position(800, 400)));
  patients.add(new Patient(4, new Position(800, 800)));
  patients.add(new Patient(5, new Position(600, 600)));
  patients.add(new Patient(6, new Position(1000, 1000)));

  return patients;
}

List<Place> getBorderMarkersForAdvancedShapeTest() {
  var random = new Random();
  var polygon = <Place>[];

  polygon.add(new Place(
      id: 1,
      name: getRandDummyName(1, random),
      position: new Position(350, 350)));

  polygon.add(new Place(
      id: 2,
      name: getRandDummyName(1, random),
      position: new Position(350, 850)));

  polygon.add(new Place(
      id: 3,
      name: getRandDummyName(1, random),
      position: new Position(850, 350)));

  polygon.add(new Place(
      id: 4,
      name: getRandDummyName(1, random),
      position: new Position(850, 850)));

  return polygon;
}

List<Patient> getPatientsOnBordersForAdvancedShapeTest() {
  var patients = <Patient>[];
  patients.add(new Patient(1, new Position(850, 600)));
  patients.add(new Patient(2, new Position(350, 600)));
  patients.add(new Patient(3, new Position(600, 350)));
  patients.add(new Patient(4, new Position(600, 850)));

  patients.add(new Patient(4, new Position(900, 900)));

  return patients;
}

List<Patient> getPatientsOnVerticesForAdvancedShapeTest() {
  var patients = <Patient>[];
  patients.add(new Patient(5, new Position(850, 850)));
  patients.add(new Patient(6, new Position(350, 850)));
  patients.add(new Patient(7, new Position(350, 350)));
  patients.add(new Patient(8, new Position(850, 350)));

  patients.add(new Patient(8, new Position(900, 900)));

  return patients;
}

List<Patient> getPatientsForNegativeCoordsTest() {
  var patients = <Patient>[];
  patients.add(new Patient(1, new Position(-180, -210)));
  patients.add(new Patient(2, new Position(-180, -269)));
  patients.add(new Patient(3, new Position(-270, -210)));
  patients.add(new Patient(4, new Position(-120, -150)));

  return patients;
}

List<Place> getBorderMarkersForOneLineTest() {
  var random = new Random();
  var polygon = <Place>[];

  polygon.add(new Place(
      id: 1,
      name: getRandDummyName(1, random),
      position: new Position(-200, -200)));

  polygon.add(new Place(
      id: 2,
      name: getRandDummyName(1, random),
      position: new Position(100, 100)));

  polygon.add(new Place(
      id: 3,
      name: getRandDummyName(1, random),
      position: new Position(400, 400)));

  return polygon;
}

List<Patient> getPatientsOnBordersForOneLineTest() {
  var patients = <Patient>[];
  patients.add(new Patient(1, new Position(-500, -500)));
  patients.add(new Patient(2, new Position(-100, -100)));
  patients.add(new Patient(3, new Position(300, 300)));
  patients.add(new Patient(4, new Position(500, 500)));

  return patients;
}

List<Place> getBorderMarkersForNegativeCoordsTest() {
  var random = new Random();
  var polygon = <Place>[];

  polygon.add(new Place(
      id: 1,
      name: getRandDummyName(1, random),
      position: new Position(-180, -120)));

  polygon.add(new Place(
      id: 2,
      name: getRandDummyName(1, random),
      position: new Position(-90, -200)));

  polygon.add(new Place(
      id: 3,
      name: getRandDummyName(1, random),
      position: new Position(-300, -270)));

  return polygon;
}

List<Patient> getISODPatients() {
  var patients = <Patient>[];

  patients.add(new Patient(1, new Position(200.0, 200.0)));
  patients.add(new Patient(2, new Position(990.0, 1050.0)));
  patients.add(new Patient(3, new Position(230.0, 400.0)));

  return patients;
}

List<Place> getISODBorderMarkers() {
  var polygon = <Place>[];
  polygon.add(
    new Place(
        id: 1, name: "Pomnik Wikipedii", position: new Position(-10.0, 500.0)),
  );
  polygon.add(
    new Place(
        id: 2,
        name: "Pomnik Fryderyka Chopina",
        position: new Position(1100.0, 550.0)),
  );
  polygon.add(
    new Place(
        id: 3,
        name: "Pomnik Anonimowego Przechodnia",
        position: new Position(400.0, 700.0)),
  );

  return polygon;
}

String getRandDummyName(int n, Random random) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  var dummyPharmacyName = String.fromCharCodes(
    Iterable.generate(
      n,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );

  return dummyPharmacyName;
}
