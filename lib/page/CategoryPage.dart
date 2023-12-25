// ignore_for_file: file_names, must_be_immutable, unused_local_variable, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/connectionUser.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/detail_sutra.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
          audio: sutra.audio.toString(),
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
    'ສິນ',
    'ອານິສົງ',
    'ກາຍຍະຄະຕາສະຕິ',
    'ອະຣິຍະສັດ 4',
    'ທຳມະຊາດ',
    'ອິດທິບາດ 4',
    'ທັມໃນທ່າມກາງ',
    'ກໍາ',
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
      key: _scaffoldKey,
      appBar: searchText.isEmpty
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(widget.category),
              backgroundColor: const Color.fromARGB(241, 179, 93, 78),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                const SizedBox(width: 10),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          late String url;
          switch (widget.category) {
            case 'ທັມໃນເບື້ອງຕົ້ນ':
              url = 'https://online.fliphtml5.com/pdhgx/nkee/';
              break;
            case 'ຄະຣາວາດຊັ້ນເລີດ':
              url = 'https://online.fliphtml5.com/pdhgx/cjhz/';
              break;
            case 'ສາທະຍາຍທັມ':
              url = 'https://online.fliphtml5.com/pdhgx/gwyc/';
              break;
            case 'ທານ':
              url = 'https://online.fliphtml5.com/pdhgx/dpgf/';
              break;
            case 'ປະຖົມທັມ':
              url = 'https://online.fliphtml5.com/pdhgx/yysj/';
              break;
            case 'ຄູ່ມືໂສດາບັນ':
              url = 'https://online.fliphtml5.com/pdhgx/gipc/';
              break;
            case 'ທັມໃນທ່າມກາງ':
              url = 'https://online.fliphtml5.com/pdhgx/vury/';
              break;
            case 'ກໍາ':
              url = 'https://online.fliphtml5.com/pdhgx/fwqg/';
              break;
            case 'ສະຕິປັຕຖານ':
              url = 'https://online.fliphtml5.com/pdhgx/zsqp/';
              break;
            case 'ອານາປານະສະຕິ':
              url = 'https://online.fliphtml5.com/pdhgx/rrbn/';
              break;
            case 'ຂໍ້ປະຕິບັດວິ​ທີ​ທີ່​ງ່າຍ':
              url = 'https://online.fliphtml5.com/pdhgx/brlf/';
              break;
            case 'ອິນຊີສັງວອນ​':
              url = 'https://online.fliphtml5.com/pdhgx/xkyd/';
              break;
            case 'ຕາມຮອຍທັມ':
              url = 'https://online.fliphtml5.com/pdhgx/xysv/';
              break;
            case 'ກ້າວຍ່າງຢ່າງພຸດທະ':
              url = 'https://online.fliphtml5.com/pdhgx/rhco/';
              break;
            case 'ຕາຖາຄົດ':
              url = 'https://online.fliphtml5.com/pdhgx/ubsc/';
              break;
            case 'ປະຕິບັດສະມາທະ & ວິປັດຊະນາ':
              url =
                  'https://drive.google.com/file/d/102Qsw2x--roLKbF0iZZEgZeh7gN2ll95/view?usp=sharing';
              break;
            case 'ພົບພູມ':
              url =
                  'https://drive.google.com/file/d/1bYarvzI-g8TLFSfCPrHXR8soOSeEbJPE/view?usp=sharing';
              break;
            case 'ເດຍລະສານວິຊາ':
              url = 'https://online.fliphtml5.com/pdhgx/iqja/';
              break;
            case 'ສະກະທາຄາມີ':
              url = 'https://online.fliphtml5.com/pdhgx/zkqf/';
              break;
            case 'ທັມໃນທີສຸດ':
              url = 'https://online.fliphtml5.com/pdhgx/ncaq/';
              break;
            case 'ຈິດ ມະໂນ ວິນຍານ':
              url = 'https://online.fliphtml5.com/pdhgx/cvqh/';
              break;
            case 'ສັຕ':
              url = 'https://online.fliphtml5.com/pdhgx/dqxo/';
              break;
            case 'ອະນາຄາມີ':
              url =
                  'https://drive.google.com/file/d/1oWyN1REEvJI0wrO7jlwOPZzwX2c-LutE/view?usp=sharing';
              break;
            case 'ສັງໂຢດ':
              url = 'https://online.fliphtml5.com/pdhgx/wmok/';
              break;
            case 'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກຕົ້ນ':
              url =
                  'https://drive.google.com/file/d/1bmjODq-SUjqMpQuCPB96YCy6q4F2ZRWv/view?usp=sharing';
              break;
            case 'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກປາຍ':
              url =
                  'https://drive.google.com/file/d/1MBm1qOvR9nZfJG9tQL2pwVi03s2UTRjO/view?usp=sharing';
              break;
            case 'ພຸດທະປະຫວັດຈາກພຣະໂອດ':
              url =
                  'https://drive.google.com/file/d/1SwwbWKaLZ3dAlK8n7DvSIcH-XmqwQpwy/view?usp=sharing';
              break;
            case 'ປະຕິຈະສະມຸບາດຈາກພຣະໂອດ':
              url =
                  'https://drive.google.com/file/d/11EINzGAtVA0xOUXcWA8OmPsqFdB0q_WH/view?usp=sharing';
              break;
            default:
              throw 'Invalid category';
          }

          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
        backgroundColor: const Color.fromARGB(241, 179, 93, 78),
        child: const Icon(Icons.auto_stories_outlined),
      ),
    );
  }
}
