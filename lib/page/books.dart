import 'package:flutter/material.dart';
import 'package:lao_tipitaka/main.dart';

class BookList extends StatelessWidget {
  const BookList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(),
      appBar: AppBar(
        title: const Text("Books"),
        backgroundColor: const Color.fromARGB(255, 175, 93, 78),
      ),
      body: const Center(
        child: Text("This is the Books page"),
      ),
    );
  }
}
