// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'CategoryListPage.dart';
import 'NavigationDrawer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Buddha Nature',
            theme: ThemeData(
              primarySwatch: Colors.brown,
              fontFamily: 'NotoSerifLao',
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.brown,
              fontFamily: 'NotoSerifLao',
            ),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  List<List<dynamic>> _data = [];
  List<String> _categories = [];
  List<List<dynamic>> _filteredData = [];
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    fetchData(_searchTerm);
  }

  Future<void> fetchData(String searchTerm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cachedData');

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.none) {
      try {
        final response = await http.get(Uri.parse(
            'https://sheets.googleapis.com/v4/spreadsheets/1mKtgmZ_Is4e6P3P5lvOwIplqx7VQ3amicgienGN9zwA/values/Sheet1!1:1000000?key=AIzaSyDFjIl-SEHUsgK0sjMm7x0awpf8tTEPQjs'));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List<dynamic> sheetValues =
              jsonResponse['values'] as List<dynamic>;

          final List<List<dynamic>> values = sheetValues
              .skip(1)
              .map((row) => List<dynamic>.from(row))
              .toList();

          _data = values;
          prefs.setString('cachedData', json.encode(_data));

          // Update data with fetched values
          updateData(searchTerm); // Update data here
        } else {
          if (kDebugMode) {
            print('Failed to load data: ${response.statusCode}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching data: $e');
        }
      }
    } else {
      // If no internet, load data from cache
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> cachedValues = json.decode(cachedData);
        _data = cachedValues.cast<List<dynamic>>();

        // Update data with cached values
        updateData(searchTerm); // Update data here
      }
    }
  }

  void updateData(String searchTerm) {
    _categories = _data
        .map((row) => row.length > 4 ? row[4].toString() : '')
        .toSet()
        .toList();

    _filteredData = _data
        .where((row) {
          return row.any((cell) =>
              cell.toString().toLowerCase().contains(searchTerm.toLowerCase()));
        })
        .where((row) => row.isNotEmpty && row[0] != '0')
        .toList();

    setState(() {
      _filteredData = _filteredData.reversed.toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 3 : (screenWidth > 900 ? 5 : 4);
    double aspectRatio = screenWidth < 900 ? 0.8 : 1;
    double cardHeight = screenWidth < 900 ? 200.0 : 250.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddha Nature'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (isDarkMode) {
                  themeProvider.toggleTheme(isDarkMode);
                },
                activeColor: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 17.0),
              decoration: InputDecoration(
                hintText: 'ຄົ້ນຫາສຸດຕັນຕະສູນຍະຕາສູດ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchTerm = '';
                            updateData(_searchTerm); // Update data directly
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                  updateData(
                      _searchTerm); // Update data when search term changes
                });
              },
            ),
            const SizedBox(height: 2),
            Expanded(
              child: _searchTerm.isEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 1.0,
                        crossAxisSpacing: 1.0,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final imageAsset = 'assets/$category.jpg';
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryListPage(
                                  data: _data,
                                  selectedCategory: category,
                                  searchTerm: _searchTerm,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: AspectRatio(
                              aspectRatio: aspectRatio,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(2),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: aspectRatio,
                                        child: FutureBuilder<bool>(
                                          future: _checkAssetExists(imageAsset),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              // Loading state
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasData &&
                                                snapshot.data!) {
                                              // Asset exists, load it
                                              return Image.asset(
                                                imageAsset,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: cardHeight,
                                              );
                                            } else {
                                              // Asset doesn't exist, load default image
                                              return Image.asset(
                                                'assets/default_image.jpg',
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: cardHeight,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: _filteredData.length,
                      itemBuilder: (context, index) {
                        final rowData = _filteredData[index];
                        final title = rowData[1].toString();
                        final detailLink = rowData[3].toString();
                        final category = rowData[4].toString();

                        return Card(
                          child: ListTile(
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18, // Adjust the font size as needed
                                fontWeight:
                                    FontWeight.bold, // Make the title bold
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    title: title,
                                    details: detailLink,
                                    category: category,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkAssetExists(String assetName) async {
    try {
      // Load the asset as a byte list
      final ByteData data = await rootBundle.load(assetName);
      return data.buffer.asUint8List().isNotEmpty; // If not empty, asset exists
    } catch (e) {
      return false; // Error loading asset, asset doesn't exist
    }
  }
}

class DetailPage extends StatefulWidget {
  final String title;
  final String details;
  final String category;

  const DetailPage({
    required this.title,
    required this.details,
    required this.category,
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  double _fontSize = 18.0;
  bool _isFavorited = false; // Add this line

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    // Load the favorite state based on both title and detailLink
    setState(() {
      _isFavorited = prefs.getBool(
              '${widget.title}_${widget.details}_${widget.category}') ??
          false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorited = !_isFavorited;
      // Save the current state of _isFavorited for the title and detailLink
      prefs.setBool(
          '${widget.title}_${widget.details}_${widget.category}', _isFavorited);

      // Load the current favorites list, add/remove the title and detailLink, and save it back
      List<String> currentFavorites = prefs.getStringList('favorites') ?? [];
      if (_isFavorited) {
        currentFavorites.add(
            json.encode({
          'title': widget.title,
          'details': widget.details,
          'category': widget.category
        }));
      } else {
        currentFavorites.removeWhere((item) {
          Map<String, dynamic> current = json.decode(item);
          return current['title'] == widget.title &&
              current['details'] == widget.details &&
              current['category'] == widget.category;
        });
      }
      prefs.setStringList('favorites', currentFavorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ສຸດຕັນຕະ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (isDarkMode) {
                  themeProvider.toggleTheme(isDarkMode);
                },
                activeColor: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SelectableText(
                  widget.title,
                  textAlign: TextAlign.center,
                  toolbarOptions: const ToolbarOptions(
                    copy: true,
                    cut: true,
                    paste: true,
                    selectAll: true,
                  ),
                  showCursor: true,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Colors.black, thickness: 1, height: 1),
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: _fetchData(widget.details),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: SelectableText.rich(
                        TextSpan(
                          children: parseContent(widget.details),
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
                          fontSize: _fontSize,
                          height: 1.8,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return Container();
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            child: FloatingActionButton(
              heroTag: 'fab1',
              onPressed: _increaseFontSize,
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
            onPressed: _decreaseFontSize,
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

  Future<String> _fetchData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize += 2.0;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = _fontSize > 2.0 ? _fontSize - 2.0 : _fontSize;
    });
  }
}

List<TextSpan> parseContent(String content) {
  final List<TextSpan> children = [];

  final List<String> chunks = content.split(RegExp(r'<\/?b>'));

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

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    notifyListeners();
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  List<List<dynamic>> _data = [];
  List<List<dynamic>> _filteredData = [];
  String _searchTerm = '';
  String _selectedCategory = ''; // Define _selectedCategory

  @override
  void initState() {
    super.initState();
    fetchData(_searchTerm);
  }

  Future<void> fetchData(String searchTerm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cachedData');

    if (cachedData != null && cachedData.isNotEmpty) {
      final List<dynamic> cachedValues = json.decode(cachedData);
      _data = cachedValues.cast<List<dynamic>>();
    }

    // Call updateData without _selectedCategory
    updateData(searchTerm, _selectedCategory);
  }

  void updateData(String searchTerm, String selectedCategory) {
    _filteredData = _data
        .where((row) {
          return row.any((cell) =>
              cell.toString().toLowerCase().contains(searchTerm.toLowerCase()));
        })
        .where((row) => row.isNotEmpty && row[0] != '0')
        .where((row) =>
            selectedCategory.isEmpty ||
            row.length > 4 && row[4] == selectedCategory)
        .toList();

    setState(() {
      _filteredData = _filteredData.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ຄົ້ນຫາ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (isDarkMode) {
                  themeProvider.toggleTheme(isDarkMode);
                },
                activeColor: Theme.of(context).colorScheme.secondary,
              );
            },
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context)
                      .size
                      .width), // Constrain width of the row
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 17.0),
                      decoration: InputDecoration(
                        hintText: 'ຄົ້ນຫາ...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchTerm = '';
                                    fetchData(_searchTerm);
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchTerm = value;
                          fetchData(_searchTerm);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory.isNotEmpty
                          ? _selectedCategory
                          : null,
                      decoration: InputDecoration(
                        hintText: 'ໝວດທັມ',
                        suffixIcon: _selectedCategory.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedCategory = '';
                                    if (_searchTerm.isEmpty) {
                                      updateData(
                                          _searchTerm, _selectedCategory);
                                    } else {
                                      fetchData(_searchTerm);
                                    }
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue ?? '';
                          if (_searchTerm.isEmpty) {
                            updateData(_searchTerm, _selectedCategory);
                          } else {
                            fetchData(_searchTerm);
                          }
                        });
                      },
                      items: _data.isEmpty
                          ? null
                          : _data
                              .map((row) =>
                                  row.length > 4 ? row[4].toString() : '')
                              .toSet()
                              .toList()
                              .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  final rowData = _filteredData[index];
                  final title = rowData[1].toString();
                  final detailLink = rowData[3].toString();
                  final category = rowData[4].toString();

                  return Card(
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18, // Adjust the font size as needed
                          fontWeight: FontWeight.bold, // Make the title bold
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              title: title,
                              details: detailLink,
                              category: category,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
