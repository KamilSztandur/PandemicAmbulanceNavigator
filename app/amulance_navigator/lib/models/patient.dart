import 'package:amulance_navigator/models/position.dart';

class Patient {
  const Patient(this.id, this.position)
      : assert(id != null),
        assert(position != null);

  final int id;
  final Position position;
}
