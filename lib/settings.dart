import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:stashcard/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

/*
* Settings
* - color scheme
* - dark/light theme
* - github link
* - app lock
* - copyright
* */

enum AppThemeMode {
  system("System"),
  light("Light"),
  dark("Dark");

  final String displayName;
  const AppThemeMode(this.displayName);

  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  static AppThemeMode fromFlutterThemeMode(ThemeMode flutterMode) {
    switch (flutterMode) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final githubUrl = "https://github.com/LahevOdVika/Stashcard";
  final TextEditingController _themeModeController = TextEditingController();

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(githubUrl);
    if (!await launchUrl(url)) {
      throw Exception("Could not launch $url");
    }
  }

  ThemeMode? selectedTheme;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text("App color scheme"),
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Pick a color"),
                    content: BlockPicker(
                        pickerColor: themeProvider.seedColor,
                        onColorChanged: (Color color) {
                          themeProvider.setSeedColor(color);
                          Navigator.of(context).pop();
                        },
                    ),
                  );
                },
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.brightness_4),
          title: const Text("App theme"),
          trailing: DropdownMenu(
            initialSelection: AppThemeMode.fromFlutterThemeMode(themeProvider.themeMode),
            controller: _themeModeController,
            dropdownMenuEntries: AppThemeMode.values.map<DropdownMenuEntry<AppThemeMode>>(
                (AppThemeMode mode) {
                  return DropdownMenuEntry(value: mode, label: mode.displayName);
                },
            ).toList(),
            onSelected: (AppThemeMode? selectedAppMode) {
              if (selectedAppMode != null) {
                themeProvider.setThemeMode(selectedAppMode.toFlutterThemeMode());
                _themeModeController.text = selectedAppMode.displayName;
              }
            },
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text("App lock"),
        ),
        const Divider(),
        ListTile(
          trailing: TextButton.icon(
              onPressed: () {
                _launchUrl();
              },
              icon: const Icon(Icons.code),
              label: const Text("Open source code"),
          ),
        ),
        const Divider(),
        ListTile(
          trailing: const Text("Copyright © 2025 LahevOdVika"),
        ),
      ],
    );
  }
}