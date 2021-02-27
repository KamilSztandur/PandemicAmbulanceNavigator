import 'dart:math';

import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/road.dart';
import 'package:flutter/material.dart';

final hospitalPaint = Paint()..color = Colors.red;
final placePaint = Paint()..color = Colors.blue;
final roadPaint = Paint()..color = Colors.grey;
final patientPatient = Paint()..color = Colors.green;

class MapView extends StatelessWidget {
  const MapView({
    Key key,
    @required this.hospitals,
    @required this.hospitalsVisibility,
    @required this.places,
    @required this.placesVisibility,
    @required this.roads,
    @required this.patients,
  }) : super(key: key);

  final List<Hospital> hospitals;
  final Map<int, bool> hospitalsVisibility;
  final List<Place> places;
  final Map<int, bool> placesVisibility;
  final List<Road> roads;
  final List<Patient> patients;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: MapPainter(
          hospitals: hospitals,
          hospitalsVisibility: hospitalsVisibility,
          places: places,
          placesVisibility: placesVisibility,
          roads: roads,
          patients: patients,
        ),
      );
}

class MapPainter extends CustomPainter {
  const MapPainter({
    @required this.hospitals,
    @required this.hospitalsVisibility,
    @required this.places,
    @required this.placesVisibility,
    @required this.roads,
    @required this.patients,
  });

  final List<Hospital> hospitals;
  final Map<int, bool> hospitalsVisibility;
  final List<Place> places;
  final Map<int, bool> placesVisibility;
  final List<Road> roads;
  final List<Patient> patients;

  @override
  void paint(Canvas canvas, Size size) {
    if (hospitals.isEmpty && places.isEmpty && patients.isEmpty) {
      return;
    }

    final combined = hospitals
        .map((hospital) => hospital.position)
        .followedBy(places.map((place) => place.position))
        .followedBy(patients.map((patient) => patient.position));
    final borderLeft = combined.map((place) => place.x).reduce(min);
    final borderTop = combined.map((place) => place.y).reduce(min);
    final width = combined.map((place) => place.x).reduce(max) - borderLeft;
    final height = combined.map((place) => place.y).reduce(max) - borderTop;

    for (final road in roads) {
      canvas.drawLine(
        Offset(
          32 + (road.source.x - borderLeft) / width * (size.width - 64),
          32 + (road.source.y - borderTop) / height * (size.height - 64),
        ),
        Offset(
          32 + (road.destination.x - borderLeft) / width * (size.width - 64),
          32 + (road.destination.y - borderTop) / height * (size.height - 64),
        ),
        roadPaint,
      );
    }

    for (final hospital
        in hospitals.where((hospital) => hospitalsVisibility[hospital.id])) {
      canvas.drawCircle(
        Offset(
          32 + (hospital.position.x - borderLeft) / width * (size.width - 64),
          32 + (hospital.position.y - borderTop) / height * (size.height - 64),
        ),
        6,
        hospitalPaint,
      );
    }

    for (final place in places.where((place) => placesVisibility[place.id])) {
      canvas.drawCircle(
        Offset(
          32 + (place.position.x - borderLeft) / width * (size.width - 64),
          32 + (place.position.y - borderTop) / height * (size.height - 64),
        ),
        4,
        placePaint,
      );
    }

    for (final patient in patients) {
      canvas.drawCircle(
        Offset(
          32 + (patient.position.x - borderLeft) / width * (size.width - 64),
          32 + (patient.position.y - borderTop) / height * (size.height - 64),
        ),
        4,
        patientPatient,
      );
    }
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) =>
      hospitals != oldDelegate.hospitals ||
      hospitalsVisibility != oldDelegate.hospitalsVisibility ||
      places != oldDelegate.places ||
      placesVisibility != oldDelegate.placesVisibility;
}
