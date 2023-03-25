// ignore_for_file: file_names, must_be_immutable, unused_local_variable
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/connectionUser.dart';
import 'package:lao_tipitaka/main.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/detail_sutra.dart';

class CategoryPage extends StatefulWidget {
  String category;
  List<Sutra> sutras;

  CategoryPage({
    super.key,
    required this.category,
    required this.sutras,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with TickerProviderStateMixin {
  late final sutraBox = Hive.box<Sutra>('sutra');
  late String searchText;
  late List<Sutra> searchResults;
  late FocusNode searchFocusNode;
  late String _selectedCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    Hive.openBox('settings');
    late final sutraBox = Hive.box<Sutra>("sutra");
    searchText = '';
    searchFocusNode = FocusNode();
    _categories =
        sutraBox.values.map((sutra) => sutra.category).toSet().toList();
    _categories.sort();
    _selectedCategory = _categories.isNotEmpty ? _categories.first : '';
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

  void onSelectCategory(String selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;
      if (_selectedCategory.isNotEmpty) {
        searchResults = sutraBox.values
            .where((sutra) => sutra.category == _selectedCategory)
            .toList();
      } else {
        searchResults = sutraBox.values.toList();
      }
    });
  }

  final DropdownMenuItem<String> _defaultCategory = const DropdownMenuItem(
    value: '',
    child: Text('ທັງໝົດ'),
  );

  List<DropdownMenuItem<String>> _getDropdownItems() {
    final dropdownItems = <DropdownMenuItem<String>>[];
    dropdownItems.add(_defaultCategory);
    for (final value in category) {
      if (_categories.contains(value)) {
        dropdownItems.add(
          DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        );
      }
    }
    return dropdownItems;
  }

  final category = [
    'ທັມໃນເບື້ອງຕົ້ນ',
    'ຄະຣາວາດຊັ້ນເລີດ',
    'ສາທະຍາຍທັມ',
    'ທານ',
    'ປະຖົມທັມ',
    'ຄູ່ມືໂສດາບັນ',
    'ທັມໃນທ່າມກາງ',
    'ແກ້ກັມ',
    'ສະຕິປັຕຖານ',
    'ອານາປານະສະຕິ',
    'ຂໍ້ປະຕິບັດວິ​ທີ​ທີ່​ງ່າຍ',
    'ອິນຊີສັງວອນ​',
    'ຕາມຮອຍທັມ',
    'ກ້າວຍ່າງຢ່າງພຸດທະ',
    'ຕາຖາຄົດ',
    'ປະຕິບັດສະມາທະ & ວິປັດຊະນາ',
    'ພົບພູມ',
    'ເດຍລະສານວິຊາ',
    'ສະກະທາຄາມີ',
    'ທັມໃນທີສຸດ',
    'ຈິດ ມະໂນ ວິນຍານ',
    'ສັຕ',
    'ອະນາຄາມີ',
    'ສັງໂຢດ',
    'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກຕົ້ນ',
    'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກປາຍ',
    'ພຸດທະປະຫວັດຈາກພຣະໂອດ',
    'ປະຕິຈະສະມຸບາດຈາກພຣະໂອດ'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchText.isEmpty
          ? AppBar(
              title: Text(widget.category),
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
                            await syncHiveWithFirebase();
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
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Row(
                children: [
                  Flexible(
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
                  const SizedBox(width: 5.0),
                  Visibility(
                    visible: searchController.text.isNotEmpty,
                    child: SizedBox(
                      width: 150,
                      child: Center(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          underline: Container(
                            height: 1,
                            color: const Color.fromARGB(241, 179, 93, 78),
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          items: _getDropdownItems(),
                          onChanged: (String? value) {
                            onSelectCategory(value!);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
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
                      itemCount: widget.sutras.length,
                      itemBuilder: ((context, index) {
                        final sutra = widget.sutras[index];
                        return GestureDetector(
                          onTap: () => viewDetail(
                              context, sutraBox.values.toList().indexOf(sutra)),
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
    );
  }
}
