// ignore_for_file: file_names, import_of_legacy_library_into_null_safe
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/connectionAdmin.dart';
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
    Hive.openBox('settings');

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
          id: sutra.id.toString(),
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
              actions: [
                ValueListenableBuilder(
                  valueListenable: Hive.box('settings').listenable(),
                  builder: (context, box, child) {
                    final isDark = box.get('isDark', defaultValue: false);
                    return Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sync),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('ເກັບຂໍ້ມູນໄວ້ໃນ Cloud'),
                                content: const Text(
                                    'ທ່ານຕ້ອງການເເກ້ໄຂຂໍ້ມູນ ຫຼື ບໍ?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  TextButton(
                                    child: const Text('Sync'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await syncHiveWithFirebase();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Switch(
                          activeColor: Colors.black87,
                          activeTrackColor: Colors.black87,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white,
                          value: isDark,
                          onChanged: (val) {
                            box.put('isDark', val);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            )
          : null,
      drawer: const NavigationDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                style: const TextStyle(fontSize: 17.0),
                focusNode: searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'ຄົ້ນຫາ...',
                  prefixIcon: const Icon(Icons.search),
                  hoverColor: const Color.fromARGB(241, 179, 93, 78),
                  fillColor: const Color.fromARGB(241, 179, 93, 78),
                  focusColor: const Color.fromARGB(241, 179, 93, 78),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () => {
                            searchController.clear(),
                            performSearch(''),
                          },
                          icon: const Icon(Icons.clear),
                          splashRadius: 20.0,
                        )
                      : null,
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
                                    id: sutra.id.toString(),
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
                                        onPressed: () async {
                                          try {
                                            sutraBox.deleteAt(index);
                                            await syncHiveWithFirebase();
                                            // ignore: use_build_context_synchronously
                                            Navigator.of(context).pop();
                                          } catch (error) {
                                            // Handle the error here, such as displaying an error message in an alert dialog
                                            if (kDebugMode) {
                                              print(
                                                  'Error deleting data: $error');
                                            }
                                            if (error is SocketException) {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Error'),
                                                    content: const Text(
                                                        'Please check your internet connection and try again.'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text('OK'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            } else {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Error'),
                                                    content: const Text(
                                                        'An error occurred while deleting data.'),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text('OK'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          }
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
