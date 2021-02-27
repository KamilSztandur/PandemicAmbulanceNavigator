import 'dart:math';

class Position {
  const Position(this.x, this.y)
      : assert(x != null),
        assert(y != null);

  final double x;
  final double y;

  bool equalsTo(Position other) {
    if (x == other.x && y == other.y) {
      return true;
    } else {
      return false;
    }
  }

  double distance(Position other) =>
      sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y));
}
