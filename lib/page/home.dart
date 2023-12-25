import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/connectionUser.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/detail_sutra.dart';
import '../main.dart';
import 'CategoryPage.dart';

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
  late String _selectedCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();

    Hive.openBox('settings');

    sutraBox = Hive.box<Sutra>("sutra");
    searchText = '';
    searchFocusNode = FocusNode();
    _categories =
        sutraBox.values.map((sutra) => sutra.category).toSet().toList();
    _categories.sort();
    _selectedCategory = _categories.isNotEmpty ? _categories.first : '';
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

  final DropdownMenuItem<String> _defaultCategory = const DropdownMenuItem(
    value: '',
    child: Text('ທັງໝົດ'),
  );

  // List<DropdownMenuItem<String>> _getDropdownItems() {
  //   final dropdownItems = <DropdownMenuItem<String>>[];
  //   dropdownItems.add(_defaultCategory);
  //   dropdownItems.addAll(_categories.map((value) {
  //     return DropdownMenuItem<String>(
  //       value: value,
  //       child: Text(value),
  //     );
  //   }));
  //   return dropdownItems;
  // }

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

  // create a list of Sutra Category from the list of Sutra

  // List<String> _getSutraCategories(List<Sutra> sutras) {
  //   final categories = <String>[];
  //   for (final sutra in sutras) {
  //     if (!categories.contains(sutra.category)) {
  //       categories.add(sutra.category);
  //     }
  //   }
  //   return categories;
  // }

  List<String> _getSutraCategories(List<Sutra> sutras) {
    final categories = <String>[];
    for (final c in category) {
      if (sutras.any((s) => s.category == c)) {
        categories.add(c);
      }
    }
    return categories;
  }

  String _getImageUrlForCategory(String category) {
    switch (category) {
      case 'ທັມໃນເບື້ອງຕົ້ນ':
        return 'https://i.ibb.co/jVbqh2t/a-HR0c-HM6-Ly9z-Lmlz-YW5vb2su-Y29t-L2hl-Lz-Avd-WQv-Mi8x-NDg3-My9mb29k-LW1vbmsuan-Bn.jpg';
      case 'ຄະຣາວາດຊັ້ນເລີດ':
        return 'https://i.ibb.co/6nGdjY1/s.png';
      case 'ສາທະຍາຍທັມ':
        return 'https://i.ibb.co/J7pwgkv/Screenshot-20230326-094953.png';
      case 'ທານ':
        return 'https://i.ibb.co/BKPDv9w/Screenshot-20230326-094043.png';
      case 'ປະຖົມທັມ':
        return 'https://i.ibb.co/Nxz78bz/Screenshot-20230326-094632.png';
      case 'ຄູ່ມືໂສດາບັນ':
        return 'https://i.ibb.co/8bZ583L/Screenshot-20230326-095038.png';
      case 'ສິນ':
        return 'https://i.ibb.co/1YCCycR/shutterstock-1135790816-scaled.jpg';
      case 'ອານິສົງ':
        return 'https://i.ibb.co/GPRYmHM/Screenshot-2023-07-30-at-18-57-22.png';
      case 'ກາຍຍະຄະຕາສະຕິ':
        return 'https://i.ibb.co/Wz5qDnG/walking-meditation.jpg';
      case 'ອະຣິຍະສັດ 4':
        return 'https://i.ibb.co/5nKyvwF/Copy.jpg';
      case 'ທຳມະຊາດ':
        return 'https://i.ibb.co/YpgZsn8/381164666-330414002889865-75299089530994275-n.jpg';
      case 'ອິດທິບາດ 4':
        return 'https://i.ibb.co/vvPBg7Y/1694526230352.jpg';
      case 'ທັມໃນທ່າມກາງ':
        return 'https://i.ibb.co/rQVN5gb/333710936-895573414918821-1390168713848511569-n.jpg';
      case 'ກໍາ':
        return 'https://i.ibb.co/smG9GL5/b.png';
      case 'ສະຕິປັຕຖານ':
        return 'https://i.ibb.co/qjd0N3h/Screenshot-20230326-112627.png';
      case 'ອານາປານະສະຕິ':
        return 'https://i.ibb.co/QHnfvR2/Screenshot-20230326-113727.png';
      case 'ຂໍ້ປະຕິບັດວິ​ທີ​ທີ່​ງ່າຍ':
        return 'https://i.ibb.co/3TJSWr2/Screenshot-20230326-112954.png';
      case 'ອິນຊີສັງວອນ​':
        return 'https://i.ibb.co/YBvVZCb/Screenshot-20230326-114630.png';
      case 'ຕາມຮອຍທັມ':
        return 'https://i.ibb.co/MsvTjDT/Screenshot-20230326-114326.png';
      case 'ກ້າວຍ່າງຢ່າງພຸດທະ':
        return 'https://i.ibb.co/q03S41Z/Screenshot-20230326-114803.png';
      case 'ຕາຖາຄົດ':
        return 'https://i.ibb.co/QvRbHbK/Screenshot-20230326-115407.png';
      case 'ປະຕິບັດສະມາທະ & ວິປັດຊະນາ':
        return 'https://i.ibb.co/7Jq7D0s/Screenshot-20230326-115502.png';
      case 'ພົບພູມ':
        return 'https://i.ibb.co/r08d6g0/Screenshot-20230326-125704.png';
      case 'ເດຍລະສານວິຊາ':
        return 'https://i.ibb.co/zSPD3C3/Screenshot-20230326-125812.png';
      case 'ສະກະທາຄາມີ':
        return 'https://i.ibb.co/KN2J32z/Screenshot-20230326-130318.png';
      case 'ທັມໃນທີສຸດ':
        return 'https://i.ibb.co/BL959bd/333683918-1225479851721961-8705720774520409168-n.jpg';
      case 'ຈິດ ມະໂນ ວິນຍານ':
        return 'https://i.ibb.co/h9KCF9M/Screenshot-20230326-131539.png';
      case 'ສັຕ':
        return 'https://i.ibb.co/3Mb6MgJ/Screenshot-20230326-131642.png';
      case 'ອະນາຄາມີ':
        return 'https://i.ibb.co/x154jqS/Screenshot-20230326-131740.png';
      case 'ສັງໂຢດ':
        return 'https://i.ibb.co/9w34zLD/Screenshot-20230326-132016.png';
      case 'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກຕົ້ນ':
        return 'https://i.ibb.co/bgPLgPJ/Screenshot-20230326-133812.png';
      case 'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກປາຍ':
        return 'https://i.ibb.co/wsCyWPx/Screenshot-20230326-133227.png';
      case 'ພຸດທະປະຫວັດຈາກພຣະໂອດ':
        return 'https://i.ibb.co/tKJ6Qhj/Screenshot-20230326-134149.png';
      case 'ປະຕິຈະສະມຸບາດຈາກພຣະໂອດ':
        return 'https://i.ibb.co/4MjfXHL/Screenshot-20230326-133458.png';
      default:
        return '';
    }
  }

  // ignore: unused_element
  // String _getImageAssetForCategory(String category) {
  //   switch (category) {
  //     case 'ທັມໃນເບື້ອງຕົ້ນ':
  //       return 'assets/images/1.jpg';
  //     case 'ຄະຣາວາດຊັ້ນເລີດ':
  //       return 'assets/images/2.png';
  //     case 'ສາທະຍາຍທັມ':
  //       return 'assets/images/3.png';
  //     case 'ທານ':
  //       return 'assets/images/4.png';
  //     case 'ປະຖົມທັມ':
  //       return 'assets/images/5.png';
  //     case 'ຄູ່ມືໂສດາບັນ':
  //       return 'assets/images/6.png';
  //     case 'ທັມໃນທ່າມກາງ':
  //       return 'assets/images/7.jpg';
  //     case 'ກໍາ':
  //       return 'assets/images/8.png';
  //     case 'ສະຕິປັຕຖານ':
  //       return 'assets/images/9.png';
  //     case 'ອານາປານະສະຕິ':
  //       return 'assets/images/10.png';
  //     case 'ຂໍ້ປະຕິບັດວິ​ທີ​ທີ່​ງ່າຍ':
  //       return 'assets/images/11.png';
  //     case 'ອິນຊີສັງວອນ​':
  //       return 'assets/images/12.png';
  //     case 'ຕາມຮອຍທັມ':
  //       return 'assets/images/13.png';
  //     case 'ກ້າວຍ່າງຢ່າງພຸດທະ':
  //       return 'assets/images/14.png';
  //     case 'ຕາຖາຄົດ':
  //       return 'assets/images/15.png';
  //     case 'ປະຕິບັດສະມາທະ & ວິປັດຊະນາ':
  //       return 'assets/images/16.png';
  //     case 'ພົບພູມ':
  //       return 'assets/images/17.png';
  //     case 'ເດຍລະສານວິຊາ':
  //       return 'assets/images/18.png';
  //     case 'ສະກະທາຄາມີ':
  //       return 'assets/images/19.png';
  //     case 'ທັມໃນທີສຸດ':
  //       return 'assets/images/20.jpg';
  //     case 'ຈິດ ມະໂນ ວິນຍານ':
  //       return 'assets/images/21.png';
  //     case 'ສັຕ':
  //       return 'assets/images/22.png';
  //     case 'ອະນາຄາມີ':
  //       return 'assets/images/23.png';
  //     case 'ສັງໂຢດ':
  //       return 'assets/images/24.png';
  //     case 'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກຕົ້ນ':
  //       return 'assets/images/25.png';
  //     case 'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກປາຍ':
  //       return 'assets/images/26.png';
  //     case 'ພຸດທະປະຫວັດຈາກພຣະໂອດ':
  //       return 'assets/images/27.png';
  //     case 'ປະຕິຈະສະມຸບາດຈາກພຣະໂອດ':
  //       return 'assets/images/28.png';
  //     default:
  //       return '';
  //   }
  // }

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
      appBar: searchText.isEmpty
          ? AppBar(
              title: Text(widget.title),
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
                    return LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double screenWidth = constraints.maxWidth;
                        int crossAxisCount = screenWidth < 600 ? 3 : 5;
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.8,
                          ),
                          itemCount:
                              _getSutraCategories(sutraBox.values.toList())
                                  .length,
                          itemBuilder: ((context, index) {
                            final category = _getSutraCategories(
                                sutraBox.values.toList())[index];
                            String imageUrl = _getImageUrlForCategory(category);
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryPage(
                                    category: category,
                                    sutras: sutraBox.values
                                        .toList()
                                        .where((sutra) =>
                                            sutra.category == category)
                                        .toList(),
                                  ),
                                ),
                              ),
                              child: Card(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              )
                                            : Image.network(
                                                "https://i.ibb.co/HrJQV2g/Logo-App-Buddhaword.jpg",
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  category,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    );

                    //
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


   // All List Items
                    // return ListView.builder(
                    //   itemCount: sutraBox.length,
                    //   itemBuilder: ((context, index) {
                    //     final sutra = sutraBox.getAt(index) as Sutra;
                    //     return GestureDetector(
                    //       onTap: () => viewDetail(context, index),
                    //       child: Card(
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(8.0),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text(
                    //                 sutra.title.toString(),
                    //                 style: const TextStyle(
                    //                   fontSize: 20,
                    //                   fontWeight: FontWeight.bold,
                    //                 ),
                    //               ),
                    //               const SizedBox(height: 8),
                    //               Row(
                    //                 mainAxisAlignment: MainAxisAlignment.end,
                    //                 children: [
                    //                   Expanded(
                    //                     child: Text(
                    //                       sutra.category.toString(),
                    //                       style: const TextStyle(
                    //                         fontSize: 16,
                    //                         color: Colors.grey,
                    //                       ),
                    //                       textAlign: TextAlign.right,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   }),
                    // );
