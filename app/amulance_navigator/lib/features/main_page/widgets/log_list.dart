import 'package:flutter/material.dart';

class LogList extends StatelessWidget {
  const LogList({Key key, @required this.messages})
      : assert(messages != null),
        super(key: key);

  final List<String> messages;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Log',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemBuilder: (_, index) =>
                    ListTile(title: Text(messages[index])),
                itemCount: messages.length,
              ),
            ),
          ),
        ],
      );
}
