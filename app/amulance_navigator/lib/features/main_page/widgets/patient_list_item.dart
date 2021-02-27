import 'package:amulance_navigator/models/patient.dart';
import 'package:flutter/material.dart';

class PatientListItem extends StatelessWidget {
  const PatientListItem({Key key, @required this.patient})
      : assert(patient != null),
        super(key: key);

  final Patient patient;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text('${patient.id}'),
        title: Row(
          children: [
            Expanded(
                child: Text('x: ${patient.position.x.toStringAsPrecision(4)}')),
            Expanded(
                child: Text('y: ${patient.position.y.toStringAsPrecision(4)}')),
          ],
        ),
      );
}
