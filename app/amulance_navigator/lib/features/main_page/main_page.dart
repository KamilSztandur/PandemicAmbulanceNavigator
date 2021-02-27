import 'package:amulance_navigator/common/input_parser/input_parsing_exception.dart';
import 'package:amulance_navigator/common/presentation_stream/presentation_event.dart';
import 'package:amulance_navigator/common/presentation_stream/presetnation_listener.dart';
import 'package:amulance_navigator/features/main_page/input_data_cubit.dart';
import 'package:amulance_navigator/features/main_page/main_cubit.dart';
import 'package:amulance_navigator/features/main_page/widgets/left_menu.dart';
import 'package:amulance_navigator/features/main_page/widgets/log_list.dart';
import 'package:amulance_navigator/features/main_page/widgets/map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) => BlocBuilder<InputDataCubit,
          InputDataState>(
      builder: (context, inputDataState) => BlocBuilder<MainCubit, MainState>(
            builder: (context, mainState) => Scaffold(
              body: PresentationListener(
                stream: context.watch<InputDataCubit>().presentationStream,
                onEvent: _onPresentationEvent,
                child: Row(
                  children: [
                    LeftMenu(
                      mainState: mainState,
                      inputDataState: inputDataState,
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: MapView(
                              hospitals: inputDataState.hospitals,
                              hospitalsVisibility:
                                  inputDataState.hospitalsVisibility,
                              places: inputDataState.places,
                              placesVisibility: inputDataState.placesVisibility,
                              roads: inputDataState.roads,
                              patients: mainState.patients,
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    FloatingActionButton(
                                      onPressed: () {
                                        if (mainState.status ==
                                            SimulationStatus.running) {
                                          context.read<MainCubit>().pause();
                                        } else {
                                          context.read<MainCubit>().start();
                                        }
                                      },
                                      child: Icon(mainState.status ==
                                              SimulationStatus.running
                                          ? Icons.pause
                                          : Icons.play_arrow),
                                    ),
                                    const SizedBox(width: 8),
                                    FloatingActionButton(
                                      mini: true,
                                      onPressed:
                                          context.watch<MainCubit>().stop,
                                      child: Icon(Icons.stop),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: mainState.speed,
                                  min: 1,
                                  max: 8,
                                  divisions: 7,
                                  onChanged:
                                      context.watch<MainCubit>().setSpeed,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Container(
                      width: 320,
                      padding: const EdgeInsets.all(8),
                      child: LogList(messages: mainState.logMessages),
                    ),
                  ],
                ),
              ),
            ),
          ));

  void _onPresentationEvent(BuildContext context, PresentationEvent event) {
    if (event is InputErrorEvent) {
      String message;
      if (event.exception is HospitalParsingException) {
        message =
            'Błąd parsowania szpitala na linii: "${event.exception.line}"';
      } else if (event.exception is PlaceParsingException) {
        message = 'Błąd parsowania miejsca na linii: "${event.exception.line}"';
      } else if (event.exception is RoadParsingException) {
        message = 'Błąd parsowania drogi na linii: "${event.exception.line}"';
      } else if (event.exception is PatientParsingException) {
        message = 'Błąd parsowania pacjęta na linii: "${event.exception.line}"';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Niepoprawne dane wejściowe'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'),
            )
          ],
        ),
      );
    }
  }
}
