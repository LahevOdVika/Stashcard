import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stashcard/Views/home.dart';
import 'package:stashcard/Views/settings.dart';
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
  List<Destination> destinations = [
    const Destination(0, "Home", Icons.home_outlined, Icons.home),
    const Destination(1, "Settings", Icons.settings_outlined, Icons.settings),
  ];

  List<Widget> routes = [
    Home(),
    SettingsPage(),
  ];

  int _selectedIndex = 0;

  void _changeDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: routes[_selectedIndex],
      bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _changeDestination,
          destinations: destinations.map((Destination destination) =>
            NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.title,
            )
          ).toList(),
      ),
    );
  }
}