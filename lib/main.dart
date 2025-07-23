import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashcard/providers/theme_provider.dart';

import 'destination.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: StashcardApp(),
      )
  );
}

class StashcardApp extends StatelessWidget {
  const StashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: NavigationHandler(),
    );
  }
}

class NavigationHandler extends StatefulWidget {
  const NavigationHandler();

  @override
  State<NavigationHandler> createState() => _NavigationHandlerState();
}

class _NavigationHandlerState extends State<NavigationHandler> {
  static const List<Destination> allDestinations = <Destination>[
    Destination(0, "Home", Icons.home_outlined, Icons.home),
    Destination(1, "Settings", Icons.settings_outlined, Icons.settings),
  ];

  late final List<GlobalKey<NavigatorState>> navigatorKeys;
  late final List<Widget> destinationViews;
  int selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    navigatorKeys = List<GlobalKey<NavigatorState>>.generate(allDestinations.length, (int index) => GlobalKey());
    destinationViews = allDestinations.map<Widget>((Destination destination) {
      return DestinationView(
        destination: destination,
        navigatorKey: navigatorKeys[destination.index],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    /*TODO: Replace with PopScope*/
    return NavigatorPopHandler(
        onPop: () {
          final NavigatorState navigator = navigatorKeys[selectedIndex].currentState!;
          navigator.pop();
        },
        child: Scaffold(
          body: SafeArea(
              top: false,
              child: Stack(
                fit: StackFit.expand,
                children: allDestinations.map((Destination destination) {
                  final int index = destination.index;
                  final Widget view = destinationViews[index];
                  if (index == selectedIndex) {
                    return Offstage(offstage: false, child: view);
                  } else {
                    return Offstage(child: view);
                  }
                }).toList(),
              )
          ),
          bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              destinations: allDestinations.map<NavigationDestination>((Destination destination) {
                return NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.title,
                );
              }).toList(),
          ),
        )
    );
  }
}