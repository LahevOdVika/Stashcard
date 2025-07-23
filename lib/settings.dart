import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/*
* Settings
* - color scheme
* - dark/light theme
* - github link
* - app lock
* - copyright
* */

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final githubUrl = "https://github.com/LahevOdVika/Stashcard";

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(githubUrl);
    if (!await launchUrl(url)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.color_lens),
          title: const Text("App color scheme"),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.brightness_4),
          title: const Text("Dark/light theme"),
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