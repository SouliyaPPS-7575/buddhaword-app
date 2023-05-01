import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/main.dart';

class DetailSutra extends StatefulWidget {
  const DetailSutra({
    Key? key,
    required this.index,
    required this.title,
    required this.content,
    required this.category,
  }) : super(key: key);
  final int index;
  final String category;
  final String content;
  final String title;

  @override
  State<DetailSutra> createState() => _DetailSutraState();
}

class _DetailSutraState extends State<DetailSutra>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Hive.openBox('settings');

    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation =
        Tween<double>(begin: _scale, end: _scale).animate(_scaleController)
          ..addListener(() {
            setState(() {
              _scale = _scaleAnimation.value;
            });
          });
  }

  void _onScaleStart(ScaleStartDetails details) {
    _scaleController.stop();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _scaleAnimation.value;
      _scale *= details.scale;
    });
    _scaleController.duration = const Duration(milliseconds: 500);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _scaleAnimation =
        Tween<double>(begin: _scale, end: 1.0).animate(_scaleController);
    _scaleController.reset();
    _scaleController.forward();
  }

  void _onZoomInPressed() {
    setState(() {
      _scale += 0.1;
    });
  }

  void _onZoomOutPressed() {
    setState(() {
      _scale -= 0.1;
    });
  }

  List<TextSpan> parseContent(String content) {
    final List<TextSpan> children = [];

    // Split the content into chunks between <b> and </b> tags
    final List<String> chunks = content.split(RegExp(r'<\/?b>'));

    // Add each chunk as a TextSpan, with a bold TextStyle for <b> tags
    for (int i = 0; i < chunks.length; i++) {
      final String chunk = chunks[i];
      if (i % 2 == 0) {
        children.add(TextSpan(text: chunk));
      } else {
        children.add(TextSpan(
          text: chunk,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: const Text("ພຣະສູດ"),
            backgroundColor: const Color.fromARGB(241, 179, 93, 78),
            floating: true,
            snap: true,
            actions: [
              ValueListenableBuilder(
                valueListenable: Hive.box('settings').listenable(),
                builder: (context, box, child) {
                  final isDark = box.get('isDark', defaultValue: false);
                  return Switch(
                    activeColor: Colors.black87,
                    activeTrackColor: Colors.black87,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.white,
                    value: isDark,
                    onChanged: (val) {
                      box.put('isDark', val);
                    },
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SelectableText(
                        textAlign: TextAlign.center,
                        toolbarOptions: const ToolbarOptions(
                          copy: true,
                          cut: true,
                          paste: true,
                          selectAll: true,
                        ),
                        showCursor: true,
                        widget.title, // title
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                          color: Colors.black, thickness: 1, height: 1),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          child: SelectableText.rich(
                            TextSpan(
                              children: parseContent(widget.content), // content
                            ),
                            toolbarOptions: const ToolbarOptions(
                              copy: true,
                              cut: true,
                              paste: true,
                              selectAll: true,
                            ),
                            showCursor: true,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 20 * _scale,
                              height: 1.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                          color: Colors.black, thickness: 1, height: 1),
                      const SizedBox(height: 10),
                      SelectableText(
                        toolbarOptions: const ToolbarOptions(
                          copy: true,
                          cut: true,
                          paste: true,
                          selectAll: true,
                        ),
                        showCursor: true,
                        widget.category, // category
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20 * _scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100, // adjust the width as needed
            child: FloatingActionButton(
              heroTag: 'fab1',
              onPressed: _onZoomInPressed,
              backgroundColor: const Color(0xFFF5F5F5),
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(241, 179, 93, 78),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: 'fab2',
            onPressed: _onZoomOutPressed,
            backgroundColor: const Color(0xFFF5F5F5),
            child: const Icon(
              Icons.remove,
              color: Color.fromARGB(241, 179, 93, 78),
            ),
          ),
        ],
      ),
    );
  }
}
