// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, file_names, avoid_web_libraries_in_flutter, unnecessary_null_comparison, unrelated_type_equality_checks, deprecated_member_use, depend_on_referenced_packages

import 'dart:async'; // Import Timer
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../layouts/NavigationDrawer.dart';
import '../../main.dart';
import '../../themes/ThemeProvider.dart';
import '../Books/BooksPage.dart';
import '../Sutra/ContactInfoPage.dart';
import '../Sutra/FavoritePage.dart';
import '../Sutra/RandomImagePage.dart';
import '../Video/VideoPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  Timer? _timer;
  int _currentIndex = 0;

  List<List<dynamic>> _data = [];

  List<String> imageUrls = [];

  bool hasInternet =
      Connectivity().checkConnectivity() != ConnectivityResult.none;

  @override
  void initState() {
    super.initState();

    _initialize();

    // Start the auto-scroll timer with a slight delay
    Future.delayed(Duration(milliseconds: 500), _startAutoSlide);
  }

  Future<void> _initialize() async {
    await fetchDataHomeFromAPI();
    await fetchDataFromAPI();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients &&
          _pageController.position.hasPixels &&
          _pageController.position.viewportDimension > 0) {
        _currentIndex = (_currentIndex + 1) % imageUrls.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose();
    super.dispose();
  }

  Future<void> saveToSharedPreferences(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  Future<dynamic> getFromSharedPreferences(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  Future<void> fetchDataHomeFromAPI() async {
    bool hasInternet =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;

    try {
      if (hasInternet) {
        final response = await http.get(Uri.parse(
            'https://sheets.googleapis.com/v4/spreadsheets/1mKtgmZ_Is4e6P3P5lvOwIplqx7VQ3amicgienGN9zwA/values/slide!1:1000000?key=AIzaSyDFjIl-SEHUsgK0sjMm7x0awpf8tTEPQjs'));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List<dynamic> sheetValues =
              jsonResponse['values'] as List<dynamic>;

          final List<List<dynamic>> values = sheetValues
              .skip(1)
              .map((row) => List<dynamic>.from(row))
              .toList();

          _data = values;

          // Storing data in shared_preferences
          await saveToSharedPreferences('slideLocalData', json.encode(_data));

          setState(() {
            // Update the UI
            imageUrls = _data
                .map((row) => row[2] as String)
                .where((url) => url.isNotEmpty)
                .toList();
          });
        } else {
          if (kDebugMode) {
            print('Failed to load data: ${response.statusCode}');
          }
        }
      } else {
        // Retrieve data from shared_preferences
        final cachedData = await getFromSharedPreferences('slideLocalData');
        if (cachedData != null && cachedData.isNotEmpty) {
          final List<dynamic> cachedValues = json.decode(cachedData);
          _data = cachedValues.cast<List<dynamic>>();
          setState(() {
            imageUrls = _data
                .map((row) => row[2] as String)
                .where((url) => url.isNotEmpty)
                .toList();
          });
          return; // Return here to avoid further execution
        }
      }
    } catch (e) {
      if (!hasInternet) {
        final cachedData = await getFromSharedPreferences('slideLocalData');
        if (cachedData != null && cachedData.isNotEmpty) {
          final List<dynamic> cachedValues = json.decode(cachedData);
          _data = cachedValues.cast<List<dynamic>>();
          return; // Return here to avoid further execution
        }
      } else {
        final cachedData = await getFromSharedPreferences('slideLocalData');
        if (cachedData != null && cachedData.isNotEmpty) {
          final List<dynamic> cachedValues = json.decode(cachedData);
          _data = cachedValues.cast<List<dynamic>>();
        }
      }
    }
  }

  Future<void> fetchDataFromAPI() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? cachedData = prefs.getString('cachedData');

    bool hasInternet =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;

    if (!hasInternet) {
      if (cachedData != null && cachedData.isNotEmpty) {
        final List<dynamic> cachedValues = json.decode(cachedData);
        _data = cachedValues.cast<List<dynamic>>();
      }
    }

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

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ທັມມະ',
          style: TextStyle(fontSize: 17, letterSpacing: 0.5),
        ),
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
      body: _data.isEmpty
          ? RandomImagePage()
          : Column(
              children: [
                // Image Slider
                SizedBox(
                  height: isTabletOrDesktop ? 400 : 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Open full-screen image viewer when the image is tapped
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FullScreenImageView(
                                  imageUrl: imageUrls[index]),
                            ),
                          );
                        },
                        child: Image.network(
                          imageUrls[index],
                          fit:
                              isTabletOrDesktop ? BoxFit.contain : BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: isTabletOrDesktop ? 30 : 20),
                // Menu Items
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount;

                      if (constraints.maxWidth >= 600) {
                        // Tablet and Desktop screen
                        crossAxisCount = 9;
                      } else {
                        // Mobile screen
                        crossAxisCount = 3;
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          children: List.generate(
                            menuItems(context).length,
                            (index) {
                              final menuItem = menuItems(context)[index];
                              return MenuItemCard(
                                image: menuItem.image,
                                onTap: menuItem.onTap,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

const String urlDhamma =
    "https://buddhaword.vercel.app/4d1689680be74b6f96071c8dda16db9e";
const String urlEnglish = "https://buddhaword-english.blogspot.com";
const String urlNews =
    "https://www.facebook.com/profile.php?id=100077638042542";
const String urlChat = "https://chat.whatsapp.com/CZ7j5fhSatK37v76zmmVCK";

void _openLinkDhamma() async {
  if (await canLaunch(urlDhamma)) {
    await launch(urlDhamma);
  } else {
    throw 'Could not launch $urlDhamma';
  }
}

void _openLinkEnglish() async {
  if (await canLaunch(urlEnglish)) {
    await launch(urlEnglish);
  } else {
    throw 'Could not launch $urlEnglish';
  }
}

void _openLinkNews() async {
  if (await canLaunch(urlNews)) {
    await launch(urlNews);
  } else {
    throw 'Could not launch $urlNews';
  }
}

void _openLinkChat() async {
  if (await canLaunch(urlChat)) {
    await launch(urlChat);
  } else {
    throw 'Could not launch $urlChat';
  }
}

class MenuItem {
  final dynamic image;
  final VoidCallback onTap;

  MenuItem({required this.image, required this.onTap});
}

List<MenuItem> menuItems(BuildContext context) => [
      MenuItem(
        image: 'assets/home/ພຣະສູດ_ສຽງທຳ.jpg',
        onTap: () => {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MyHomePage(
                title: 'ພຣະສູດ & ສຽງ',
              ),
            ),
          ),
        },
      ),
      MenuItem(
        image: 'assets/home/ພຣະສູດທີ່ຖືກໃຈ.jpg',
        onTap: () => {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => FavoritePage(),
            ),
          ),
        },
      ),
      MenuItem(
        image: 'assets/home/ປື້ມ_ແຜນຜັງ.jpg',
        onTap: () => {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BooksPage(),
            ),
          ),
        },
      ),
      MenuItem(
        image: 'assets/home/ພຣະທຳ.jpg',
        onTap: () => _openLinkDhamma(),
      ),
      MenuItem(
        image: 'assets/home/video.jpg',
        onTap: () => {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => VideoPage(
                title: 'ວີດີໂອ Video',
              ),
            ),
          ),
        },
      ),
      MenuItem(
        image: 'assets/home/Buddha_Word_English.jpg',
        onTap: () => _openLinkEnglish(),
      ),
      MenuItem(
        image: 'assets/home/ຂ່າວສານ.jpg',
        onTap: () => _openLinkNews(),
      ),
      MenuItem(
        image: 'assets/home/ສົນທະນາທຳ.jpg',
        onTap: () => _openLinkChat(),
      ),
      MenuItem(
        image: 'assets/home/ຂໍ້ມູນຕິດຕໍ່.jpg',
        onTap: () => {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ContactInfoPage(),
            ),
          ),
        },
      ),
    ];

class MenuItemCard extends StatelessWidget {
  final String image;
  final VoidCallback onTap;

  const MenuItemCard({
    required this.image,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: 4,
        margin: EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image widget
            Expanded(
              child: Image.asset(
                image,
                width: double.infinity, // Full width
                height: double.infinity, // Full height
                fit: BoxFit.cover, // Cover the entire space
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({required this.imageUrl, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
