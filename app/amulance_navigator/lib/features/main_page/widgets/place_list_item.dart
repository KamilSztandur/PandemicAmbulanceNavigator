import 'package:amulance_navigator/models/place.dart';
import 'package:flutter/material.dart';

class PlaceListItem extends StatelessWidget {
  const PlaceListItem({
    Key key,
    @required this.place,
    this.visible,
    @required this.onToggleVisibility,
  })  : assert(place != null),
        super(key: key);

  final Place place;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Text('${place.id}'),
        title: Text(place.name),
        subtitle: Row(
          children: [
            Expanded(
                child: Text('x: ${place.position.x.toStringAsPrecision(4)}')),
            Expanded(
                child: Text('y: ${place.position.y.toStringAsPrecision(4)}')),
          ],
        ),
        trailing: visible != null
            ? IconButton(
                icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                splashRadius: 20,
                onPressed: onToggleVisibility,
              )
            : null,
      );
}
