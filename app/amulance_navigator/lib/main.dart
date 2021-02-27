import 'package:amulance_navigator/algorithms/crossroads_finder.dart';
import 'package:amulance_navigator/algorithms/dijkstra_shortest_route.dart';
import 'package:amulance_navigator/algorithms/nearest_position_neighbor.dart';
import 'package:amulance_navigator/common/file_reader.dart';
import 'package:amulance_navigator/common/input_parser/input_parser.dart';
import 'package:amulance_navigator/features/main_page/input_data_cubit.dart';
import 'package:amulance_navigator/features/main_page/main_cubit.dart';
import 'package:amulance_navigator/features/main_page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(_App());
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Ambulance navigator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: BlocProvider(
          create: (_) => InputDataCubit(
            FileReader(),
            InputParser(),
          ),
          child: BlocProvider(
            create: (context) => MainCubit(
              context.read<InputDataCubit>(),
              NearestPositionNeighbor(),
              CrossRoadsFinder(),
              DijkstraShortestRoute(),
            )..init(),
            child: MainPage(),
          ),
        ),
      );
}
