import 'package:amulance_navigator/models/position.dart';
import 'package:meta/meta.dart';

class Place {
  const Place({
    @required this.id,
    @required this.name,
    @required this.position,
  })  : assert(id != null),
        assert(name != null),
        assert(position != null);

  final int id;
  final String name;
  final Position position;
}
