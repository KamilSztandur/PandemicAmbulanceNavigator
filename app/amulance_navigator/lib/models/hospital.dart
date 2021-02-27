import 'package:amulance_navigator/models/place.dart';
import 'package:amulance_navigator/models/position.dart';
import 'package:meta/meta.dart';

class Hospital extends Place {
  const Hospital({
    @required int id,
    @required String name,
    @required Position position,
    @required this.capacity,
    @required this.availableBeds,
  })  : assert(capacity != null),
        assert(availableBeds != null),
        assert(capacity >= 0),
        assert(availableBeds >= 0),
        super(id: id, name: name, position: position);

  final int capacity;
  final int availableBeds;

  Hospital copyWith({int availableBeds}) => Hospital(
        id: this.id,
        name: this.name,
        position: this.position,
        capacity: this.capacity,
        availableBeds: availableBeds ?? this.availableBeds,
      );
}
