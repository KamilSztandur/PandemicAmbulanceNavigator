import 'package:amulance_navigator/algorithms/shape_membership_validator.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';
import '../shape_membership_validator_test.dart';

import 'package:image/image.dart';
import 'dart:io';
import 'dart:math';

const image_size = 2500;
const seed = 2021;

void main() {
  print("Visualizator launched successfully.");
  stdout.write("");

  _Drawer().drawDataFromISOD();
  _Drawer().drawHeightTest();
  _Drawer().drawTriangularPolygon();

  _Drawer().drawDataWithNegativeCoords();
  _Drawer().drawRandomPolygonWithNEdges(seed, 4);
  _Drawer().drawRandomPolygonWithNEdges(seed, 5);
  _Drawer().drawRandomPolygonWithNEdges(seed, 6);
  _Drawer().drawRandomPolygonWithNEdges(seed, 8);
  print("Visualizator exited successfully.");
}

class _Drawer {
  final interiorPixel = getColor(131, 69, 255);
  final exteriorPixel = getColor(255, 246, 69);
  final interiorPatient = getColor(87, 255, 69);
  final exteriorPatient = getColor(255, 69, 69);
  final axes = getColor(0, 0, 0);
  final borderMarker = getColor(0, 0, 0);
  final path = 'test' +
      Platform.pathSeparator +
      'smv_visualizer' +
      Platform.pathSeparator +
      'rendered' +
      Platform.pathSeparator;

  void drawDataFromISOD() {
    var image = Image(image_size, image_size);

    final polygon = getISODBorderMarkers();
    final patients = getISODPatients();
    final validator = new ShapeMembershipValidator(polygon);

    final imageData = _ImageData(image, polygon, patients);
    imageData.title = "ISOD Data visualization";

    _Drawer()._drawImageFromData(imageData, validator);
  }

  void drawDataWithNegativeCoords() {
    var image = Image(image_size, image_size);

    final polygon = getBorderMarkersForNegativeCoordsTest();
    final patients = getPatientsForNegativeCoordsTest();
    var validator = new ShapeMembershipValidator(polygon);

    final imageData = _ImageData(image, polygon, patients);
    imageData.title = "Negative coords data visualization";

    _Drawer()._drawImageFromData(imageData, validator);
  }

  void drawHeightTest() {
    var image = Image(image_size, image_size);

    final polygon = getBorderMarkersForHeightTest();
    final patients = getPatientsForHeightTest();
    var validator = new ShapeMembershipValidator(polygon);

    final imageData = _ImageData(image, polygon, patients);
    imageData.title = "Height test visualization";

    _Drawer()._drawImageFromData(imageData, validator);
  }

  void drawTriangularPolygon() {
    final image = Image(image_size, image_size);

    final polygon = getBorderMarkersForTriangularTest();
    final patients = getPatientsForTriangularTest();
    var validator = new ShapeMembershipValidator(polygon);

    final imageData = _ImageData(image, polygon, patients);
    imageData.title = "Triangular polygon visualization";

    _Drawer()._drawImageFromData(imageData, validator);
  }

  void drawRandomPolygonWithNEdges(int seed, int n) {
    Image image = Image(image_size, image_size);

    var polygon = _RandomImageGenerator().getNEdgesPolygon(n);
    var patients = _RandomImageGenerator().getRandomPatients(n * 70);
    var validator = ShapeMembershipValidator(polygon);

    var imageData = _ImageData(image, polygon, patients);
    imageData.title = "Random " + n.toString() + "-edges polygon visualization";

    _Drawer()._drawImageFromData(imageData, validator);
  }

  void _drawImageFromData(
    _ImageData data,
    ShapeMembershipValidator validator,
  ) {
    print("Printing " + data.title + ":\n");

    print("\tFilling background... ");
    _drawBackground(data.image, validator);
    _drawAxes(data.image);
    print("\tDone.\n");

    print("\tDrawing border markers... ");
    data.borderMarkers
        .forEach((marker) => _drawBorderMarker(data.image, marker));
    print("\tDone.\n");

    print("\tDrawing patients... ");
    data.patients.forEach((patient) => _Drawer()
        ._drawPatient(data.image, patient, validator.contains(patient)));
    print("\tDone.\n");

    print("\tWriting to file... ");
    File(this.path + data.title + '.png')
        .writeAsBytesSync(encodePng(data.image));
    print("\tDone.\n");

    print("Visualization finished.\n");
    print("");
  }

  void _drawBackground(Image image, ShapeMembershipValidator validator) {
    final shift = image_size ~/ 2;

    for (var x = 0 - shift; x < image_size - shift; x++) {
      for (var y = 0 - shift; y < image_size - shift; y++) {
        var isInside = validator.contains(getDummyPatient(x, y));

        var color = isInside ? interiorPixel : exteriorPixel;
        drawPixel(image, x + shift, (image_size - 1) - (y + shift), color);
      }
    }
  }

  void _drawAxes(Image image) {
    final center = image_size ~/ 2;

    for (int i = 0; i < image_size; i++) {
      drawPixel(image, i, center, axes);
      drawPixel(image, center, i, axes);
    }

    for (int i = 100; i < image_size; i += 100) {
      for (int j = 1; j <= 20; j++) {
        drawPixel(image, center - j, center + i, axes);
        drawPixel(image, center + j, center + i, axes);
        drawPixel(image, center - j, center - i, axes);
        drawPixel(image, center + j, center - i, axes);
      }

      for (int j = 1; j <= 20; j++) {
        drawPixel(image, center + i, center - j, axes);
        drawPixel(image, center + i, center + j, axes);
        drawPixel(image, center - i, center - j, axes);
        drawPixel(image, center - i, center + j, axes);
      }
    }
  }

  void _drawBorderMarker(Image image, Place place) {
    final shift = image_size ~/ 2;
    var color = borderMarker;
    var positionX = place.position.x.toInt();
    var positionY = place.position.y.toInt();

    for (int y = shift + positionY - 5; y <= shift + positionY + 5; y++) {
      if (y < 0 || y > image_size) {
        continue;
      }

      for (int x = shift + positionX - 5; x <= shift + positionX + 5; x++) {
        if (x < 0 || x > image_size) {
          continue;
        }

        drawPixel(image, x, (image_size - 1) - y, color);
      }
    }
  }

  void _drawPatient(Image image, Patient patient, bool isInside) {
    final shift = image_size ~/ 2;
    var color = isInside ? interiorPatient : exteriorPatient;
    var positionX = patient.position.x.toInt();
    var positionY = patient.position.y.toInt();

    for (int y = shift + positionY - 5; y <= shift + positionY + 1; y++) {
      if (y < 0 || y > image_size) {
        continue;
      }

      for (int x = shift + positionX - 5; x <= shift + positionX + 1; x++) {
        if (x < 0 || x > image_size) {
          continue;
        }

        drawPixel(image, x, (image_size - 1) - y, color);
      }
    }
  }
}

class _ImageData {
  String title;
  List<Place> borderMarkers;
  List<Patient> patients;
  Image image;

  _ImageData(Image image, List<Place> borderMarkers, List<Patient> patients) {
    this.borderMarkers = borderMarkers;
    this.patients = patients;
    this.image = image;
  }
}

class _RandomImageGenerator {
  List<Patient> getRandomPatients(int n) {
    var random = new Random();

    return getRandomPatientsUsingSeed(n, random.nextInt(100000));
  }

  List<Patient> getRandomPatientsUsingSeed(int n, int seed) {
    final shift = image_size ~/ 2 - 1;
    var random = new Random(seed);
    double min = 0.0 - shift;
    double max = 0.0 + shift;

    var patients = <Patient>[];
    for (int i = 0; i < n; i++) {
      var x = random.nextDouble() * (max - min) + min;
      var y = random.nextDouble() * (max - min) + min;

      patients.add(new Patient(i, new Position(x, y)));
    }

    return patients;
  }

  List<Place> getNEdgesPolygon(int n) {
    var random = new Random();

    return getNEdgesPolygonWithSeed(n, random.nextInt(100000));
  }

  List<Place> getNEdgesPolygonWithSeed(int n, int seed) {
    if (n < 3) {
      throw new ArgumentError("Invalid n parameter: n < 3");
    }

    var shift = image_size ~/ 2 - 1;
    var random = new Random(seed);
    double min = 0.0 - shift;
    double max = 0.0 + shift;

    List<Place> polygon = <Place>[];
    for (int i = 1; i <= n; i++) {
      var x = random.nextDouble() * (max - min) + min;
      var y = random.nextDouble() * (max - min) + min;
      var name = getRandDummyName(i, random);

      polygon.add(new Place(id: i, name: name, position: new Position(x, y)));
    }

    return polygon;
  }
}
