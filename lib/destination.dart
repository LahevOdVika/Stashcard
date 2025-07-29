import 'package:flutter/material.dart';
import 'package:stashcard/Views/settings.dart';

import 'Views/home.dart';

class Destination {
  const Destination(this.index, this.title, this.icon, this.selectedIcon);
  final int index;
  final String title;
  final IconData icon;
  final IconData selectedIcon;
}

class DestinationView extends StatefulWidget {
  const DestinationView({super.key, required this.destination, required this.navigatorKey});

  final Destination destination;
  final Key navigatorKey;

  @override
  State<DestinationView> createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) {
            switch (settings.name) {
              case '/':
                if (widget.destination.index == 0) {
                  return const Home();
                } else if (widget.destination.index == 1) {
                  return const SettingsPage();
                }
            }
            assert(false);
            return const SizedBox();
          },
        );
      },
    );
  }
}