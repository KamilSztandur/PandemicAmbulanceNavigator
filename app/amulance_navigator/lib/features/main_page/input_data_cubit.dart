import 'dart:async';
import 'dart:math';

import 'package:amulance_navigator/common/file_reader.dart';
import 'package:amulance_navigator/common/input_parser/input_parser.dart';
import 'package:amulance_navigator/common/input_parser/input_parsing_exception.dart';
import 'package:amulance_navigator/common/presentation_stream/presentation_event.dart';
import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:amulance_navigator/models/road.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InputDataCubit extends Cubit<InputDataState> {
  InputDataCubit(
    this._fileReader,
    this._inputParser,
  ) : super(const InputDataState());

  final FileReader _fileReader;
  final InputParser _inputParser;

  final _presentationController =
      StreamController<PresentationEvent>.broadcast();

  Stream<PresentationEvent> get presentationStream =>
      _presentationController.stream;

  Future<void> loadPlaces(String path) async {
    try {
      final lines = await _fileReader.read(path);

      final hospitals = _inputParser.parseHospitals(lines);
      final places = _inputParser.parsePlaces(lines);
      final roads = _inputParser.parseRoads(
        lines,
        Map.fromIterable(
          hospitals,
          key: (hospital) => (hospital as Hospital).id,
          value: (hospital) => hospital as Hospital,
        ),
      );

      emit(
        state.copyWith(
          hospitals: hospitals,
          hospitalsVisibility: Map.fromIterable(
            hospitals,
            key: (hospital) => (hospital as Hospital).id,
            value: (_) => true,
          ),
          places: places,
          placesVisibility: Map.fromIterable(
            places,
            key: (place) => (place as Place).id,
            value: (_) => true,
          ),
          roads: roads,
        ),
      );
    } on InputParsingException catch (e) {
      _presentationController.add(InputErrorEvent(e));
    }
  }

  void toggleHospitalVisibility(int id) {
    final hospitalsVisibility = {...state.hospitalsVisibility};
    hospitalsVisibility[id] = !hospitalsVisibility[id];

    emit(state.copyWith(hospitalsVisibility: hospitalsVisibility));
  }

  void togglePlaceVisibility(int id) {
    final placesVisibility = {...state.placesVisibility};
    placesVisibility[id] = !placesVisibility[id];

    emit(state.copyWith(placesVisibility: placesVisibility));
  }

  Future<void> loadPatients(String path) async {
    try {
      final lines = await _fileReader.read(path);

      final patients = await _inputParser.parsePatients(lines);

      emit(state.copyWith(patients: patients));
    } on InputParsingException catch (e) {
      _presentationController.add(InputErrorEvent(e));
    }
  }

  void addPatient(double x, double y) {
    emit(
      state.copyWith(
        patients: [
          ...state.patients,
          Patient(
            state.patients.map((patient) => patient.id).reduce(max) + 1,
            Position(x, y),
          )
        ],
      ),
    );
  }
}

class InputDataState {
  const InputDataState({
    this.hospitals = const [],
    this.hospitalsVisibility = const {},
    this.places = const [],
    this.placesVisibility = const {},
    this.roads = const [],
    this.patients = const [],
  });

  final List<Hospital> hospitals;
  final Map<int, bool> hospitalsVisibility;

  final List<Place> places;
  final Map<int, bool> placesVisibility;

  final List<Road> roads;

  final List<Patient> patients;

  InputDataState copyWith({
    List<Hospital> hospitals,
    Map<int, bool> hospitalsVisibility,
    List<Place> places,
    Map<int, bool> placesVisibility,
    List<Road> roads,
    List<Patient> patients,
  }) =>
      InputDataState(
        hospitals: hospitals ?? this.hospitals,
        hospitalsVisibility: hospitalsVisibility ?? this.hospitalsVisibility,
        places: places ?? this.places,
        placesVisibility: placesVisibility ?? this.placesVisibility,
        roads: roads ?? this.roads,
        patients: patients ?? this.patients,
      );
}

class InputErrorEvent extends PresentationEvent {
  const InputErrorEvent(this.exception);

  final InputParsingException exception;
}
