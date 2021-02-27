import 'package:amulance_navigator/common/input_parser/input_parser.dart';
import 'package:amulance_navigator/common/input_parser/input_parsing_exception.dart';
import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:amulance_navigator/models/road.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(
    'InputParser',
    () {
      InputParser inputParser;

      setUp(() => inputParser = InputParser());

      test(
        'returns Hospital when parseHospital with correctly formatted line',
        () {
          final line = '1 | Szpital Wojewódzki nr 997 | 10 | 10 | 1000 | 100';

          final result = inputParser.parseHospital(line);

          expect(
            result,
            isA<Hospital>()
                .having((hospital) => hospital.id, 'id', 1)
                .having((hospital) => hospital.name, 'name',
                    'Szpital Wojewódzki nr 997')
                .having((hospital) => hospital.position.x, 'position.x', 10)
                .having((hospital) => hospital.position.y, 'position.y', 10)
                .having((hospital) => hospital.capacity, 'capacity', 1000)
                .having(
                    (hospital) => hospital.availableBeds, 'availableBeds', 100),
          );
        },
      );

      test(
        'returns Place when parsePlace with correctly formatted line',
        () {
          final line = '1 | Pomnik Wikipedii | -1 | 50';

          final result = inputParser.parsePlace(line);

          expect(
            result,
            isA<Place>()
                .having((hospital) => hospital.id, 'id', 1)
                .having((hospital) => hospital.name, 'name', 'Pomnik Wikipedii')
                .having((hospital) => hospital.position.x, 'position.x', -1)
                .having((hospital) => hospital.position.y, 'position.y', 50),
          );
        },
      );

      test(
        'returns Road when parseRoad with correctly formatted line',
        () {
          final line = '1 | 1 | 2 | 700';
          final source = Position(0, 0);
          final destination = Position(10, 10);
          final hospitals = <int, Hospital>{
            1: Hospital(
              id: 1,
              name: '',
              position: source,
              capacity: 1,
              availableBeds: 1,
            ),
            2: Hospital(
              id: 2,
              name: '',
              position: destination,
              capacity: 1,
              availableBeds: 1,
            ),
          };

          final result = inputParser.parseRoad(line, hospitals);

          expect(
            result,
            isA<Road>()
                .having((hospital) => hospital.source, 'source', source)
                .having((hospital) => hospital.destination, 'destination',
                    destination)
                .having((hospital) => hospital.length, 'length', 700),
          );
        },
      );

      test(
        'returns Patient when parsePatient with correctly formatted line',
        () {
          final line = '1 | 20 | 20';

          final result = inputParser.parsePatient(line);

          expect(
            result,
            isA<Patient>()
                .having((patient) => patient.id, 'id', 1)
                .having((patient) => patient.position.x, 'position.x', 20)
                .having((patient) => patient.position.y, 'position.y', 20),
          );
        },
      );

      test(
        'throws HospitalParsingError when parseHospital is called with malformatted line',
        () {
          final line = 'malformattedLine';

          expect(
            () => inputParser.parseHospital(line),
            throwsA(
              isA<HospitalParsingException>()
                  .having((exception) => exception.line, 'line', line),
            ),
          );
        },
      );

      test(
        'throws PlaceParsingError when parsePlace is called with malformatted line',
        () {
          final line = 'malformattedLine';

          expect(
            () => inputParser.parsePlace(line),
            throwsA(
              isA<PlaceParsingException>()
                  .having((exception) => exception.line, 'line', line),
            ),
          );
        },
      );

      test(
        'throws RoadParsingError when parseRoad is called with malformatted line',
        () {
          final line = 'malformattedLine';
          final source = Position(0, 0);
          final destination = Position(10, 10);
          final hospitals = <int, Hospital>{
            1: Hospital(
              id: 1,
              name: '',
              position: source,
              capacity: 1,
              availableBeds: 1,
            ),
            2: Hospital(
              id: 2,
              name: '',
              position: destination,
              capacity: 1,
              availableBeds: 1,
            ),
          };

          expect(
            () => inputParser.parseRoad(line, hospitals),
            throwsA(
              isA<RoadParsingException>()
                  .having((exception) => exception.line, 'line', line),
            ),
          );
        },
      );

      test(
        'throws PatientParsingError when parsePatient is called with malformatted line',
        () {
          final line = 'malformattedLine';

          expect(
            () => inputParser.parsePatient(line),
            throwsA(
              isA<PatientParsingException>()
                  .having((exception) => exception.line, 'line', line),
            ),
          );
        },
      );
    },
  );
}
