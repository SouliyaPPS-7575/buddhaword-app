import 'package:flutter/material.dart';
import '../main.dart';

class Categories extends StatelessWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(),
      appBar: AppBar(
        title: const Text("ໝວດທັມ"),
        backgroundColor: const Color.fromARGB(241, 179, 93, 78),
      ),
      body: const Center(
        child: Text("This is the Categories page"),
      ),
    );
  }
}
