import 'package:flutter/material.dart';
import 'package:lao_tipitaka/main.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EditDetailSutra extends StatefulWidget {
  const EditDetailSutra({
    Key? key,
    required this.title,
    required this.content,
    required this.category,
  }) : super(key: key);

  final String category;
  final String content;
  final String title;

  @override
  State<EditDetailSutra> createState() => _EditDetailSutraState();
}

class _EditDetailSutraState extends State<EditDetailSutra>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late Animation<double> _scaleAnimation;
  late AnimationController _scaleController;
  late Box<Sutra> sutraBox;

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    sutraBox = Hive.box<Sutra>("sutra");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawer(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: GestureDetector(
              onScaleStart: _onScaleStart,
              onScaleUpdate: _onScaleUpdate,
              onScaleEnd: _onScaleEnd,
              child: SingleChildScrollView(
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 5.0,
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
                            child: SelectableText(
                              textAlign: TextAlign.start,
                              toolbarOptions: const ToolbarOptions(
                                copy: true,
                                cut: true,
                                paste: true,
                                selectAll: true,
                              ),
                              showCursor: true,
                              widget.content, // content
                              style: TextStyle(
                                fontSize: 20 * _scale,
                                height: 1.5,
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
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: 'fab1',
            onPressed: _onZoomInPressed,
            backgroundColor: const Color(0xFFF5F5F5),
            child: const Icon(
              Icons.add,
              color: Color.fromARGB(241, 179, 93, 78),
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
