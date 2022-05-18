import 'package:flutter/material.dart';

class AnitempHomepage extends StatefulWidget {
  const AnitempHomepage({super.key});

  @override
  State<AnitempHomepage> createState() => _AnitempHomepageState();
}

class _AnitempHomepageState extends State<AnitempHomepage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      bottomNavigationBar: BottomAppBar(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <IconButton>[
                IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
              ]),
          shape: const CircularNotchedRectangle()),
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked);
}
