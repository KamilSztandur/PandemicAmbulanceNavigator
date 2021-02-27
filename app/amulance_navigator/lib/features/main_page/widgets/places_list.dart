import 'package:amulance_navigator/features/main_page/widgets/place_list_item.dart';
import 'package:amulance_navigator/models/place.dart';
import 'package:flutter/material.dart';

class PlacesList extends StatelessWidget {
  const PlacesList({
    Key key,
    @required this.title,
    @required this.places,
    @required this.visibility,
    @required this.onToggleVisibility,
  })  : assert(title != null),
        assert(places != null),
        super(key: key);

  final String title;
  final List<Place> places;
  final Map<int, bool> visibility;
  final ValueChanged<Place> onToggleVisibility;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Scrollbar(
              child: ListView.separated(
                itemBuilder: (_, index) {
                  final place = places[index];
                  return PlaceListItem(
                    place: place,
                    visible: visibility != null ? visibility[place.id] : null,
                    onToggleVisibility: () => onToggleVisibility?.call(place),
                  );
                },
                separatorBuilder: (_, __) => Divider(height: 1),
                itemCount: places.length,
              ),
            ),
          ),
        ],
      );
}
