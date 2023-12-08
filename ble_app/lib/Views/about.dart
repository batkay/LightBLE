import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pinkAccent,
          title: const Text("Information"),
        ),
        body: SingleChildScrollView(
          child: Text(
              "App by Thomas Lang\n Special Thanks to Amy Xue for helping with this project.\n"),
        ));
  }
}
