import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/main.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/detail_sutra.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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

  void viewDetail(BuildContext context, int index) {
    final sutra = sutraBox.getAt(index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailSutra(
          index: index,
          title: sutra!.title.toString(),
          content: sutra.content.toString(),
          category: sutra.category.toString(),
        ),
      ),
    );
  }

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
              title: Text(widget.title),
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
                    if (searchText.isNotEmpty) {
                      return ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: ((context, index) {
                          final sutra = searchResults[index];
                          return GestureDetector(
                            onTap: () => viewDetail(
                              context,
                              sutraBox.values.toList().indexOf(sutra),
                            ),
                            child: Card(
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
                    } else {
                      return ListView.builder(
                        itemCount: sutraBox.length,
                        itemBuilder: ((context, index) {
                          final sutra = sutraBox.getAt(index) as Sutra;
                          return GestureDetector(
                            onTap: () => viewDetail(context, index),
                            child: Card(
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
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
