import 'package:amulance_navigator/common/file_reader.dart';
import 'package:amulance_navigator/common/input_parser/input_parser.dart';
import 'package:amulance_navigator/features/main_page/input_data_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockFileReader extends Mock implements FileReader {}

class MockInputParser extends Mock implements InputParser {}

void main() {
  group(
    'InputDataCubit',
    () {
      InputDataCubit inputDataCubit;
      FileReader fileReader;
      InputParser inputParser;

      setUp(
        () {
          fileReader = MockFileReader();
          when(fileReader.read(any)).thenAnswer((_) async => []);
          inputParser = MockInputParser();
          when(inputParser.parseHospitals(any)).thenReturn([]);
          when(inputParser.parsePlaces(any)).thenReturn([]);
          when(inputParser.parseRoads(any, any)).thenReturn([]);
          inputDataCubit = InputDataCubit(
            fileReader,
            inputParser,
          );
        },
      );

      test(
        'calls parseHospitals on InputParser when loadPlaces is called',
        () async {
          await inputDataCubit.loadPlaces('');

          verify(inputParser.parseHospitals(any)).called(1);
        },
      );

      test(
        'calls parsePlaces on InputParser when loadPlaces is called',
        () async {
          await inputDataCubit.loadPlaces('');

          verify(inputParser.parsePlaces(any)).called(1);
        },
      );

      test(
        'calls parseRoads on InputParser when loadPlaces is called',
        () async {
          await inputDataCubit.loadPlaces('');

          verify(inputParser.parseRoads(any, any)).called(1);
        },
      );

      test(
        'calls parsePatients on InputParser when loadPlaces is called',
        () async {
          await inputDataCubit.loadPatients('');

          verify(inputParser.parsePatients(any)).called(1);
        },
      );
    },
  );
}
