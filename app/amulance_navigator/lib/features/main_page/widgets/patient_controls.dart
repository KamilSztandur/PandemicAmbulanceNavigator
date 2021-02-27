import 'package:flutter/material.dart';

class PatientControls extends StatefulWidget {
  const PatientControls({Key key, @required this.onPatientAdded})
      : super(key: key);

  final void Function(double x, double y) onPatientAdded;

  @override
  _PatientControlsState createState() => _PatientControlsState();
}

class _PatientControlsState extends State<PatientControls> {
  final xController = TextEditingController();
  final yController = TextEditingController();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: xController,
              keyboardType: TextInputType.number,
              inputFormatters: [],
              decoration: InputDecoration(hintText: 'x'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: yController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'y'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            splashRadius: 20,
            onPressed: () => widget.onPatientAdded?.call(
                double.tryParse(xController.text),
                double.tryParse(yController.text)),
          ),
        ],
      );

  @override
  void dispose() {
    xController.dispose();
    yController.dispose();
    super.dispose();
  }
}
