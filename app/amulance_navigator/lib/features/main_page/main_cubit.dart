import 'dart:async';

import 'package:amulance_navigator/algorithms/crossroads_finder.dart';
import 'package:amulance_navigator/algorithms/dijkstra_shortest_route.dart';
import 'package:amulance_navigator/algorithms/nearest_position_neighbor.dart';
import 'package:amulance_navigator/algorithms/shape_membership_validator.dart';
import 'package:amulance_navigator/features/main_page/input_data_cubit.dart';
import 'package:amulance_navigator/models/hospital.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:amulance_navigator/models/vertex.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SimulationStatus { stopped, running, paused }

class MainCubit extends Cubit<MainState> {
  MainCubit(
    this._inputDataCubit,
    this._nearestPositionNeighbor,
    this._crossRoadsFinder,
    this._dijkstraShortestRoute,
  ) : super(const MainState());

  final InputDataCubit _inputDataCubit;
  final NearestPositionNeighbor _nearestPositionNeighbor;
  final CrossRoadsFinder _crossRoadsFinder;
  final DijkstraShortestRoute _dijkstraShortestRoute;

  Timer _timer;
  StreamSubscription _subscription;

  void init() {
    _subscription = _inputDataCubit.listen(_onInputDataStateUpdate);
  }

  _onInputDataStateUpdate(InputDataState inputDataState) => emit(
        state.copyWith(
          inputDataState: inputDataState,
          shapeMembershipValidator: ShapeMembershipValidator(
            [
              ...inputDataState.hospitals,
              ...inputDataState.places,
            ],
          ),
          hospitals: inputDataState.hospitals,
          vertices: _generateVertices(inputDataState),
          patients: [
            ...state.patients,
            ...inputDataState.patients.skip(state.patients.length),
          ],
        ),
      );

  List<Vertex> _generateVertices(InputDataState inputDataState) {
    final hospitals = inputDataState.hospitals;
    final roads = _crossRoadsFinder.splitRoads(
      hospitals,
      inputDataState.roads,
    );

    final positionVertex = <Position, Vertex>{};

    for (final road in roads) {
      positionVertex[road.source] ??= Vertex(
        hospitals
            .firstWhere(
              (hospital) => hospital.position == road.source,
              orElse: () => null,
            )
            ?.id,
      );
      positionVertex[road.destination] ??= Vertex(
        hospitals
            .firstWhere(
              (hospital) => hospital.position == road.destination,
              orElse: () => null,
            )
            ?.id,
      );
      positionVertex[road.source].addNeighbor(
        positionVertex[road.destination],
        road.length,
      );
      positionVertex[road.destination].addNeighbor(
        positionVertex[road.source],
        road.length,
      );
    }

    return positionVertex.values.toList();
  }

  void start() {
    if (state.handledPatients < state.patients.length) {
      _timer ??= Timer.periodic(
        Duration(milliseconds: 100 * (9 - state.speed).toInt()),
        (_) => _onUpdate(),
      );
      emit(state.copyWith(status: SimulationStatus.running));
    }
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(status: SimulationStatus.paused));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    emit(
      state.copyWith(
        status: SimulationStatus.stopped,
        hospitals: state.inputDataState.hospitals,
        patients: state.inputDataState.patients,
        handledPatients: 0,
        logMessages: const [],
      ),
    );
  }

  void setSpeed(double speed) {
    if (_timer?.isActive ?? false) {
      _timer.cancel();
      _timer = Timer.periodic(
        Duration(milliseconds: 100 * (9 - state.speed).toInt()),
        (_) => _onUpdate(),
      );
    }
    emit(state.copyWith(speed: speed));
  }

  void _onUpdate() {
    if (state.handledPatients >= state.patients.length) {
      pause();
    } else {
      final index = state.handledPatients;
      final patient = state.patients[index];
      final contained = state.shapeMembershipValidator.contains(patient);

      if (contained) {
        final closestHospital = _nearestPositionNeighbor.get(
          patient.position,
          state.inputDataState.hospitals,
        );

        emit(
          state.copyWith(
            patients: setPatientPosition(
              index,
              closestHospital.position,
              state.patients,
            ),
            logMessages: addLogMessage(
              'Pacjent #${patient.id} przewieziony do spitala #${closestHospital.id} ${closestHospital.name}',
              state.logMessages,
            ),
          ),
        );

        if (closestHospital.availableBeds > 0) {
          emit(
            state.copyWith(
              logMessages: addLogMessage(
                'Pacjent #${patient.id} przyjęty do spitala #${closestHospital.id} ${closestHospital.name}',
                state.logMessages,
              ),
              hospitals: decrementAvailable(
                state.hospitals.indexWhere(
                    (hospital) => hospital.id == closestHospital.id),
                state.hospitals,
              ),
            ),
          );
        } else {
          final visitedHospitals = {closestHospital.id: closestHospital};

          while (true) {
            if (visitedHospitals.length >= state.hospitals.length) {
              emit(
                state.copyWith(
                  logMessages: addLogMessage(
                    'Pacjent #${patient.id} porzucony pod spitalem #${visitedHospitals.keys.last} ${visitedHospitals.values.last.name}',
                    state.logMessages,
                  ),
                ),
              );
              break;
            }

            final vertices = _dijkstraShortestRoute.findTheShortestRoute(
              state.vertices,
              state.vertices.indexWhere(
                  (vertex) => vertex.hospitalId == visitedHospitals.keys.last),
              visitedHospitals.keys.toList(),
            );

            final vertex = vertices.last;
            final hospital = state.hospitals
                .firstWhere((hospital) => hospital.id == vertex.hospitalId);

            emit(
              state.copyWith(
                patients: setPatientPosition(
                  index,
                  hospital.position,
                  state.patients,
                ),
                logMessages: addLogMessage(
                  'Pacjent #${patient.id} przewieziony do spitala #${hospital.id} ${hospital.name}',
                  state.logMessages,
                ),
              ),
            );

            if (hospital.availableBeds > 0) {
              emit(
                state.copyWith(
                  logMessages: addLogMessage(
                    'Pacjent #${patient.id} przyjęty do spitala #${hospital.id} ${hospital.name}',
                    state.logMessages,
                  ),
                  hospitals: decrementAvailable(
                    state.hospitals.indexWhere((h) => h.id == hospital.id),
                    state.hospitals,
                  ),
                ),
              );
              break;
            }

            visitedHospitals[vertex.hospitalId] = hospital;
          }
        }
      } else {
        emit(
          state.copyWith(
            logMessages: addLogMessage(
              'Pacjent #${patient.id} poza obsługiwany obszarem',
              state.logMessages,
            ),
          ),
        );
      }

      emit(state.copyWith(handledPatients: state.handledPatients + 1));
    }
  }

  List<Patient> setPatientPosition(
          int index, Position position, List<Patient> patients) =>
      [
        ...patients.take(index),
        Patient(patients[index].id, position),
        ...patients.skip(index + 1),
      ];

  List<Hospital> decrementAvailable(int index, List<Hospital> hospitals) => [
        ...hospitals.take(index),
        hospitals[index]
            .copyWith(availableBeds: hospitals[index].availableBeds - 1),
        ...hospitals.skip(index + 1),
      ];

  List<String> addLogMessage(String message, List<String> logMessages) => [
        ...state.logMessages,
        message,
      ];

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}

class MainState {
  const MainState({
    this.status = SimulationStatus.stopped,
    this.speed = 4,
    this.inputDataState = const InputDataState(),
    this.shapeMembershipValidator,
    this.hospitals = const [],
    this.patients = const [],
    this.vertices = const [],
    this.handledPatients = 0,
    this.logMessages = const [],
  });

  final SimulationStatus status;
  final double speed;
  final InputDataState inputDataState;
  final ShapeMembershipValidator shapeMembershipValidator;
  final List<Hospital> hospitals;
  final List<Patient> patients;
  final List<Vertex> vertices;
  final int handledPatients;
  final List<String> logMessages;

  MainState copyWith({
    SimulationStatus status,
    double speed,
    InputDataState inputDataState,
    ShapeMembershipValidator shapeMembershipValidator,
    List<Hospital> hospitals,
    List<Patient> patients,
    List<Vertex> vertices,
    int handledPatients,
    List<String> logMessages,
  }) =>
      MainState(
        status: status ?? this.status,
        speed: speed ?? this.speed,
        inputDataState: inputDataState ?? this.inputDataState,
        shapeMembershipValidator:
            shapeMembershipValidator ?? this.shapeMembershipValidator,
        hospitals: hospitals ?? this.hospitals,
        patients: patients ?? this.patients,
        vertices: vertices ?? this.vertices,
        handledPatients: handledPatients ?? this.handledPatients,
        logMessages: logMessages ?? this.logMessages,
      );
}
