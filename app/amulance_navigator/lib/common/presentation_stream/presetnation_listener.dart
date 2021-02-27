import 'dart:async';

import 'package:amulance_navigator/common/presentation_stream/presentation_event.dart';
import 'package:flutter/material.dart';

class PresentationListener extends StatefulWidget {
  const PresentationListener({
    Key key,
    @required this.stream,
    @required this.onEvent,
    @required this.child,
  })  : assert(stream != null),
        assert(onEvent != null),
        assert(child != null),
        super(key: key);

  final Stream<PresentationEvent> stream;
  final void Function(BuildContext context, PresentationEvent event) onEvent;
  final Widget child;

  @override
  _PresentationListenerState createState() => _PresentationListenerState();
}

class _PresentationListenerState extends State<PresentationListener> {
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen(
      (event) => widget.onEvent(
        context,
        event,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
