import 'package:amulance_navigator/features/main_page/input_data_cubit.dart';
import 'package:amulance_navigator/features/main_page/main_cubit.dart';
import 'package:amulance_navigator/features/main_page/widgets/patient_controls.dart';
import 'package:amulance_navigator/features/main_page/widgets/patients_list.dart';
import 'package:amulance_navigator/features/main_page/widgets/places_list.dart';
import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeftMenu extends StatelessWidget {
  const LeftMenu({
    Key key,
    @required this.mainState,
    @required this.inputDataState,
  }) : super(key: key);

  final MainState mainState;
  final InputDataState inputDataState;

  @override
  Widget build(BuildContext context) => Container(
        width: 320,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
              child: RaisedButton(
                child: Text('Wybierz plik obiektów'),
                onPressed: () => _onPlacesSelect(context),
              ),
            ),
            Expanded(
              child: PlacesList(
                title: 'Szpitale',
                places: inputDataState.hospitals,
                visibility: inputDataState.hospitalsVisibility,
                onToggleVisibility: (hospital) => context
                    .read<InputDataCubit>()
                    .toggleHospitalVisibility(hospital.id),
              ),
            ),
            Expanded(
              child: PlacesList(
                title: 'Obiekty',
                places: inputDataState.places,
                visibility: inputDataState.placesVisibility,
                onToggleVisibility: (place) => context
                    .read<InputDataCubit>()
                    .togglePlaceVisibility(place.id),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: RaisedButton(
                child: Text('Wybierz plik pacjentów'),
                onPressed: () => _onPatientsSelect(context),
              ),
            ),
            Expanded(child: PatientsList(patients: mainState.patients)),
            PatientControls(
                onPatientAdded: (x, y) =>
                    context.read<InputDataCubit>().addPatient(x, y))
          ],
        ),
      );

  Future<void> _onPlacesSelect(BuildContext context) async {
    final path = await _getFilePath();
    if (path != null) {
      context.read<InputDataCubit>().loadPlaces(path);
    }
  }

  Future<void> _onPatientsSelect(BuildContext context) async {
    final path = await _getFilePath();
    if (path != null) {
      context.read<InputDataCubit>().loadPatients(path);
    }
  }

  Future<String> _getFilePath() async {
    try {
      final file = await FilePickerCross.importFromStorage(
        type: FileTypeCross.any,
        fileExtension: 'txt',
      );
      return file.path;
    } catch (_) {
      return null;
    }
  }
}
