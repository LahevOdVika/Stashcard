import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      home: const NavigationHandler(),
    );
  }
}

class NavigationHandler extends StatefulWidget {
  const NavigationHandler();

  @override
  State<NavigationHandler> createState() => _NavigationHandlerState();
}

class _NavigationHandlerState extends State<NavigationHandler> {

  Future<SharedPreferences>? _prefsFuture;

  List<Destination> destinations = [
    const Destination(0, "Home", Icons.home_outlined, Icons.home),
    const Destination(1, "Settings", Icons.settings_outlined, Icons.settings),
  ];

  List<Widget> routes = [
    const Home(),
    const SettingsPage(),
  ];

  int _selectedIndex = 0;

  void _changeDestination(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _prefsFuture = SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    //Waits for the SharedPreferences to be loaded
    return FutureBuilder<SharedPreferences>(
        future: _prefsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text("Error while loading ${snapshot.error}"),)
            );
          } else if (snapshot.hasData) {
            final prefs = snapshot.data!;
            String? hexColor = prefs.getString("seedColor");

            //Parsing hex to Color class
            Color seedColor;
            if (hexColor != null && hexColor.isNotEmpty) {
              final String hexCode = hexColor.startsWith('#') ? hexColor.substring(1) : hexColor;
              final String fullHexCode = hexCode.length == 6 ? 'FF$hexCode' : hexCode;

              try {
                seedColor = Color(int.parse("0x$fullHexCode"));
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    themeProvider.setSeedColor(seedColor);
                  }
                });
              } catch (e) {
                print("Error parsing seed color: $e");
                seedColor = themeProvider.seedColor;
              }
            } else {
              seedColor = themeProvider.seedColor;
            }

            //Rendering the app
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
          } else {
            return const Scaffold(
              body: Center(child: Text("Somethign went wrong")),
            );
          }
        }
    );
  }
}