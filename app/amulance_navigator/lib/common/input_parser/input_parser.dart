import 'package:amulance_navigator/common/input_parser/input_parsing_exception.dart';
import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:amulance_navigator/models/road.dart';
import 'package:meta/meta.dart';

final hospitalPattern = RegExp(
    r'^(\d+)\s\|\s([^|]+)\s\|\s(-?\d+)\s\|\s(-?\d+)\s\|\s(\d+)\s\|\s(\d+)');
final placePattern = RegExp(r'^(\d+)\s\|\s([^|]+)\s\|\s(-?\d+)\s\|\s(-?\d+)');
final roadPattern = RegExp(r'^(\d+)\s\|\s(\d+)\s\|\s(\d+)\s\|\s(\d+)');
final patientPattern = RegExp(r'^(\d+)\s\|\s(-?\d+)\s\|\s(-?\d+)');

class InputParser {
  const InputParser();

  List<Hospital> parseHospitals(List<String> lines) => lines
      .where((line) => line.isNotEmpty)
      .skip(1)
      .takeWhile((line) => line[0] != '#')
      .map(parseHospital)
      .toList();

  List<Place> parsePlaces(List<String> lines) => lines
      .where((line) => line.isNotEmpty)
      .skip(1)
      .skipWhile((line) => line[0] != '#')
      .skip(1)
      .takeWhile((line) => line[0] != '#')
      .map(parsePlace)
      .toList();

  List<Road> parseRoads(List<String> lines, Map<int, Hospital> hospitals) =>
      lines
          .where((line) => line.isNotEmpty)
          .skip(1)
          .skipWhile((line) => line[0] != '#')
          .skip(1)
          .skipWhile((line) => line[0] != '#')
          .skip(1)
          .map((line) => parseRoad(line, hospitals))
          .toList();

  List<Patient> parsePatients(List<String> lines) =>
      lines.where((line) => line.isNotEmpty).map(parsePatient).toList();

  @visibleForTesting
  Hospital parseHospital(String line) {
    final match = hospitalPattern.firstMatch(line);

    if (match?.groupCount != 6) {
      throw HospitalParsingException(line);
    }

    try {
      return Hospital(
        id: int.parse(match.group(1)),
        name: match.group(2),
        position: Position(
          double.parse(match.group(3)),
          double.parse(match.group(4)),
        ),
        capacity: int.parse(match.group(5)),
        availableBeds: int.parse(match.group(6)),
      );
    } catch (_) {
      throw HospitalParsingException(line);
    }
  }

  @visibleForTesting
  Place parsePlace(String line) {
    final match = placePattern.firstMatch(line);

    if (match?.groupCount != 4) {
      throw PlaceParsingException(line);
    }

    try {
      return Place(
        id: int.parse(match.group(1)),
        name: match.group(2),
        position: Position(
          double.parse(match.group(3)),
          double.parse(match.group(4)),
        ),
      );
    } catch (_) {
      throw PlaceParsingException(line);
    }
  }

  @visibleForTesting
  Road parseRoad(String line, Map<int, Hospital> hospitals) {
    final match = roadPattern.firstMatch(line);

    if (match?.groupCount != 4) {
      throw RoadParsingException(line);
    }

    try {
      return Road(
        source: hospitals[int.parse(match.group(2))].position,
        destination: hospitals[int.parse(match.group(3))].position,
        length: double.parse(match.group(4)),
      );
    } catch (_) {
      throw RoadParsingException(line);
    }
  }

  @visibleForTesting
  Patient parsePatient(String line) {
    final match = patientPattern.firstMatch(line);

    if (match?.groupCount != 3) {
      throw PatientParsingException(line);
    }

    try {
      return Patient(
        int.parse(match.group(1)),
        Position(
          double.parse(match.group(2)),
          double.parse(match.group(3)),
        ),
      );
    } catch (_) {
      throw PatientParsingException(line);
    }
  }
}
