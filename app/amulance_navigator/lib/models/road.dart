import 'package:amulance_navigator/models/position.dart';
import 'package:meta/meta.dart';

class Road {
  const Road({
    @required this.source,
    @required this.destination,
    @required this.length,
  })  : assert(source != null),
        assert(destination != null),
        assert(length != null);

  final Position source;
  final Position destination;
  final double length;

  bool isVertical() => source.x == destination.x;
}
