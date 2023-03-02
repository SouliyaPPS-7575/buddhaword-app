// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/main.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/add_sutra.dart';
import 'package:lao_tipitaka/page/edit_detail_sutra.dart';
import 'package:lao_tipitaka/page/edit_sutra.dart';

class SutraList extends StatefulWidget {
  const SutraList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SutraList> createState() => _SutraListState();
}

class _SutraListState extends State<SutraList> with TickerProviderStateMixin {
  late Box<Sutra> sutraBox;
  late final Function updateListViewLength;
  late String searchText;
  late List<Sutra> searchResults;
  late FocusNode searchFocusNode;

  @override
  void initState() {
    super.initState();
    sutraBox = Hive.box<Sutra>("sutra");
    searchText = '';
    searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
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

  final TextEditingController searchController = TextEditingController();

  void performSearch(String query) {
    setState(() {
      searchText = query;
      if (searchText.isNotEmpty) {
        searchResults = sutraBox.values
            .where((sutra) =>
                sutra.title.toLowerCase().contains(searchText.toLowerCase()) ||
                sutra.content
                    .toLowerCase()
                    .contains(searchText.toLowerCase()) ||
                sutra.category.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      } else {
        searchResults = sutraBox.values.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchText.isEmpty
          ? AppBar(
              title: const Text("ລາຍການພຣະສູດ"),
              backgroundColor: const Color.fromARGB(241, 179, 93, 78),
            )
          : null,
      drawer: const NavigationDrawer(),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(double.maxFinite),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  style: const TextStyle(fontSize: 17.0),
                  focusNode: searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'ຄົ້ນຫາ...',
                    prefixIcon: Icon(Icons.search),
                    hoverColor: Color.fromARGB(241, 179, 93, 78),
                    fillColor: Color.fromARGB(241, 179, 93, 78),
                    focusColor: Color.fromARGB(241, 179, 93, 78),
                  ),
                  onChanged: (value) => performSearch(value),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: sutraBox.listenable(),
                  builder: (context, box, child) {
                    final sutras = sutraBox.values
                        .where((sutra) => sutra.title
                            .toString()
                            .toLowerCase()
                            .contains(searchText.toLowerCase()))
                        .toList();
                    return ListView.builder(
                      itemCount: sutras.length,
                      itemBuilder: ((context, index) {
                        final sutra = sutras[index];

                        return Card(
                          child: ListTile(
                            // How to add viewDetail function
                            leading: IconButton(
                              onPressed: () => {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditSutraList(
                                      index: index,
                                      id: sutra.id,
                                      title: sutra.title.toString(),
                                      content: sutra.content.toString(),
                                      category: sutra.category.toString(),
                                    ),
                                  ),
                                )
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Color.fromARGB(241, 179, 93, 78),
                              ),
                            ),
                            title: Text(
                              sutra.title.toString(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(sutra.category.toString()),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("ຢືນຢັນການລົບ"),
                                      // ignore: prefer_const_constructors
                                      content: const Text(
                                          "ທ່ານຕ້ອງການລົບພຣະສູດນິ້ ຫຼື ບໍ່?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            sutraBox.deleteAt(index);
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromARGB(241, 179, 93, 78),
                              ),
                            ),

                            onTap: () => viewDetail(context, index),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddSutraList(
                title: 'ລາຍການທີ່ບັນທຶກ',
              ),
            ),
          );
        },
        label: const Text('ເພີ່ມ'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(241, 179, 93, 78),
      ),
    );
  }
}
