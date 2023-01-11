import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Box homeBox;

  @override
  void initState() {
    super.initState();

    homeBox = Hive.box("home");
    homeBox.put("1", 'Lao');
    homeBox.put("2", 'Thai');
    homeBox.put("3", 'Eng');

    homeBox.add("ww");
    homeBox.add("how");
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: AnimationController(
            vsync: this,
            duration: const Duration(seconds: 1),
          )..forward(),
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: const Color.fromARGB(255, 175, 93, 78),
        ),
        drawer: const NavigationDrawer(),
        body: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.infinity),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(homeBox.get('1')),
                Text(homeBox.get('2')),
                Text(homeBox.get('3')),
                Text(homeBox.getAt(0)),
                Text(homeBox.getAt(1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
