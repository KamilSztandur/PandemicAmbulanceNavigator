import 'package:amulance_navigator/features/main_page/widgets/patient_list_item.dart';
import 'package:amulance_navigator/models/patient.dart';
import 'package:flutter/material.dart';

class PatientsList extends StatelessWidget {
  const PatientsList({
    Key key,
    @required this.patients,
  })  : assert(patients != null),
        super(key: key);

  final List<Patient> patients;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Pacjenci',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Scrollbar(
              child: ListView.separated(
                itemBuilder: (_, index) =>
                    PatientListItem(patient: patients[index]),
                separatorBuilder: (_, __) => Divider(height: 1),
                itemCount: patients.length,
              ),
            ),
          ),
        ],
      );
}
