// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/main.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/add_sutra.dart';
import 'package:lao_tipitaka/page/edit_detail_sutra.dart';

class SutraList extends StatefulWidget {
  const SutraList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SutraList> createState() => _SutraListState();
}

class _SutraListState extends State<SutraList> with TickerProviderStateMixin {
  late Box<Sutra> sutraBox;
  late final Function updateListViewLength;

  @override
  void initState() {
    super.initState();
    sutraBox = Hive.box<Sutra>("sutra");
  }

  // How to create view detail page
  void viewDetail(BuildContext context, int index) {
    final sutra = sutraBox.getAt(index);
    //how to navigate to DetailSutra page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditDetailSutra(
          title: sutra!.title.toString(),
          content: sutra.content.toString(),
          category: sutra.category.toString(),
        ),
      ),
    );
  }

  // How to create edit page

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
          title: const Text("ລາຍການພຣະສູດ"),
          backgroundColor: const Color.fromARGB(241, 179, 93, 78),
        ),
        drawer: const NavigationDrawer(),
        body: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(double.maxFinite),
          child: ValueListenableBuilder(
              valueListenable: sutraBox.listenable(),
              builder: (context, box, child) {
                return ListView.builder(
                  itemCount: sutraBox.length,
                  itemBuilder: ((context, index) {
                    final sutra = sutraBox.getAt(index) as Sutra;

                    return Card(
                      // How to add viewDetail function
                      child: InkWell(
                        onTap: () => viewDetail(context, index),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sutra.title.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      sutra.category.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddSutraList(
                          title: 'ລາຍການທີ່ບັນທຶກ',
                        )));
          },
          label: const Text('ເພີ່ມ'),
          icon: const Icon(Icons.add),
          backgroundColor: const Color.fromARGB(241, 179, 93, 78),
        ),
      ),
    );
  }
}
