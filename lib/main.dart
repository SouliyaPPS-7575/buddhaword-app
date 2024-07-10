// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, depend_on_referenced_packages, use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';

import 'package:app_upgrade_flutter_sdk/app_upgrade_flutter_sdk.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layouts/NavigationDrawer.dart';
import 'pages/BookReadingScreenPage.dart';
import 'pages/CategoryListPage.dart';
import 'pages/DetailPage.dart';
import 'pages/RandomImagePage.dart';
import 'themes/ThemeProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppInfo appInfo = AppInfo(
        appId: 'com.buddha.lao_tipitaka',
        appName: 'buddha nature', // Your app name
        appVersion: '5.0.0', // Your app version
        platform: 'android', // App Platform, android or ios
        environment:
            'production', // Environment in which app is running, production, staging or development etc.
        appLanguage: 'es' //Your app language ex: en, es etc. //Optional
        );

    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'ທັມມະ',
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
              // home: MyHomePage(),
              home: AppUpgradeAlert(
                  xApiKey:
                      'ZmRmNjE3ZDQtZmQwYS00OTgxLWIzZjAtNGE5Mzk4YWU1ZTYx', // Your x-api-key
                  appInfo: appInfo,
                  child: MyHomePage()));
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

  Future<void> fetchDataFromAPI(String searchTerm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse(
          'https://sheets.googleapis.com/v4/spreadsheets/1mKtgmZ_Is4e6P3P5lvOwIplqx7VQ3amicgienGN9zwA/values/Sheet1!1:1000000?key=AIzaSyDFjIl-SEHUsgK0sjMm7x0awpf8tTEPQjs'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> sheetValues =
            jsonResponse['values'] as List<dynamic>;

        final List<List<dynamic>> values =
            sheetValues.skip(1).map((row) => List<dynamic>.from(row)).toList();

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
  }

  Future<void> fetchData(String searchTerm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('cachedData');

    bool hasInternet =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;

    if (!hasInternet) {
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> cachedValues = json.decode(cachedData);
        _data = cachedValues.cast<List<dynamic>>();

        // Update data with cached values
        updateData(searchTerm); // Update data here
      }
    }

    if (cachedData == null || cachedData.isEmpty || hasInternet) {
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
        // If no internet, load data from cache
        if (cachedData != null && cachedData.isNotEmpty) {
          final List<dynamic> cachedValues = json.decode(cachedData);
          _data = cachedValues.cast<List<dynamic>>();

          // Update data with cached values
          updateData(searchTerm); // Update data here
        }
      }
    } else {
      // If no internet, load data from cache
      if (cachedData.isNotEmpty) {
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
        title: const Text('ທັມມະ'),
        actions: [
          _filteredData.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.auto_stories_outlined,
                      color: Colors.white),
                  onPressed: () {
                    // Implement your action here, e.g., navigate to book reading screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookReadingScreenPage(
                          filteredData: _filteredData,
                          onFavoriteChanged: () => setState(() {}),
                        ),
                      ),
                    );
                  },
                )
              : const SizedBox(),
          const SizedBox(width: 12),
          IconButton(
            icon: _filteredData.isEmpty
                ? const SizedBox(
                    width: 20.0, // Custom width
                    height: 20.0, // Custom height
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white), // Change color here
                      strokeWidth: 2.0, // Optional: change the stroke width
                    ),
                  )
                : const Icon(Icons.update_outlined),
            onPressed: () async {
              await fetchDataFromAPI(_searchTerm);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Information has been successfully updated'),
                  duration: Duration(seconds: 2),
                  backgroundColor:
                      Colors.green, // Set the background color to green
                ),
              );
            },
          ),
          const SizedBox(width: 8),
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
      body: _filteredData.isEmpty
          ? RandomImagePage()
          : Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 17.0),
                    decoration: InputDecoration(
                      hintText: 'ຄົ້ນຫາພຣະສູດ...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchTerm = '';
                                  updateData(
                                      _searchTerm); // Update data directly
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(2),
                                            ),
                                            child: AspectRatio(
                                              aspectRatio: aspectRatio,
                                              child: FutureBuilder<bool>(
                                                future: _checkAssetExists(
                                                    imageAsset),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                              final id = rowData[0].toString();
                              final title = rowData[1].toString();
                              final detailLink = rowData[3].toString();
                              final category = rowData[4].toString();
                              final audio = rowData[5].toString();

                              return Card(
                                child: ListTile(
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize:
                                          18, // Adjust the font size as needed
                                      fontWeight: FontWeight
                                          .bold, // Make the title bold
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                          id: id,
                                          title: title,
                                          details: detailLink,
                                          category: category,
                                          audio: audio,
                                          onFavoriteChanged: () {
                                            fetchData(_searchTerm);
                                          },
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
