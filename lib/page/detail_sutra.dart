import 'package:flutter/material.dart';
import 'package:lao_tipitaka/main.dart';

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

class _DetailSutraState extends State<DetailSutra>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _scaleController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = Tween<double>(begin: _scale, end: _scale).animate(_scaleController)
      ..addListener(() {
        setState(() {
          _scale = _scaleAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onScaleStart(ScaleStartDetails details) {
    _scaleController.stop();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _scaleAnimation.value;
      _scale *= details.scale;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _scaleAnimation = Tween<double>(begin: _scale, end: 1.0).animate(_scaleController);
    _scaleController.reset();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ພຣະສູດ"),
        backgroundColor: const Color.fromARGB(241, 179, 93, 78),
      ),
      drawer: const NavigationDrawer(),
      body: GestureDetector(
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onScaleEnd: _onScaleEnd,
        child: SingleChildScrollView(
          child: Container(
            color: Colors.orangeAccent[100],
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, thickness: 1, height: 1),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: Text(
                      widget.content,
                      style: TextStyle(
                        fontSize: 20 * _scale,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.black, thickness: 1, height: 1),
                const SizedBox(height: 10),
                Text(
                  widget.category,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20 * _scale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
