import 'package:flutter/material.dart';
import 'package:lao_tipitaka/main.dart';

// how to create DetailSutra page
class DetailSutra extends StatefulWidget {
  const DetailSutra({
    Key? key,
    required this.title,
    required this.content,
    required this.category,
  }) : super(key: key);
  final String title;
  final String content;
  final String category;

  @override
  State<DetailSutra> createState() => _DetailSutraState();
}

class _DetailSutraState extends State<DetailSutra> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ພຣະສູດ"),
        backgroundColor: const Color.fromARGB(255, 175, 93, 78),
      ),
      drawer: const NavigationDrawer(),
      body: InteractiveViewer(
        maxScale: 4.0,
        minScale: 0.5,
        child: Container(
          color: Colors.orangeAccent[100],
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SideBox
                const SizedBox(
                  height: 5,
                ),
                // Divider light
                const Divider(
                  color: Colors.black,
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.content,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // body: SingleChildScrollView(
      //   child: InteractiveViewer(
      //     maxScale: 4.0,
      //     minScale: 0.5,
      //     child: Container(
      //       color: Colors.orangeAccent[100],
      //       child: Column(
      //         children: <Widget>[
      //           Expanded(
      //             child: ListView(
      //               children: <Widget>[
      //                 Text(
      //                   widget.title,
      //                   style: const TextStyle(
      //                     fontSize: 30,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 Text(
      //                   widget.content,
      //                   style: const TextStyle(
      //                     fontSize: 25,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 Text(
      //                   widget.category,
      //                   style: const TextStyle(
      //                     fontSize: 20,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
