// ignore_for_file: file_names, avoid_web_libraries_in_flutter, unnecessary_null_comparison, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layouts/NavigationDrawer.dart';
import '../themes/ThemeProvider.dart';
import 'DetailPage.dart';
import 'SearchPage.dart';

class BookReadingScreenPage extends StatefulWidget {
  final List<List<dynamic>> filteredData;
  final int initialPageIndex;
  final VoidCallback onFavoriteChanged; // Add this line

  const BookReadingScreenPage({
    Key? key,
    required this.filteredData,
    this.initialPageIndex = 0,
    required this.onFavoriteChanged, // Add this line
  }) : super(key: key);

  @override
  State<BookReadingScreenPage> createState() => _BookReadingScreenPageState();
}

class _BookReadingScreenPageState extends State<BookReadingScreenPage> {
  double _fontSize = 18.0;

  late PageController _pageController;
  int _currentPageIndex = 0;

  // check if the item is favorited on local storage data or not
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();

    _loadFavoriteState();

    _currentPageIndex = widget.initialPageIndex;
    _pageController = PageController(initialPage: widget.initialPageIndex);
    _pageController.addListener(() {
      _onPageChanged(_pageController.page!.toInt());
    });
  }

  String getCurrentID() {
    return widget.filteredData[_currentPageIndex][0].toString();
  }

  String getCurrentTitle() {
    return widget.filteredData[_currentPageIndex][1].toString();
  }

  String getCurrentDetail() {
    return widget.filteredData[_currentPageIndex][3].toString();
  }

  String getCurrentCategory() {
    return widget.filteredData[_currentPageIndex][4].toString();
  }

  String getCurrentAudio() {
    return widget.filteredData[_currentPageIndex][5].toString();
  }

  Future<void> _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Check if the current detail is in favorites
      List<String>? currentFavorites = prefs.getStringList('favorites');
      if (currentFavorites != null) {
        _isFavorited = currentFavorites.any((item) {
          Map<String, dynamic> current = json.decode(item);
          return current['id'] == getCurrentID() &&
              current['title'] == getCurrentTitle() &&
              current['details'] == getCurrentDetail() &&
              current['category'] == getCurrentCategory() &&
              current['audio'] == getCurrentAudio();
        });
      } else {
        _isFavorited = false;

        // Initialize the favorites list
        prefs.setStringList('favorites', []);

        // Initialize the favorite state for the current detail

        prefs.setBool(
            '${getCurrentID()}_${getCurrentTitle()}_${getCurrentDetail()}_${getCurrentCategory()}',
            false);

        // Notify the parent widget
        widget.onFavoriteChanged();

        // Load the favorite state again
        _loadFavoriteState();

        // Return to avoid calling the setState method
        return;
      }
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorited = !_isFavorited;
      prefs.setBool(
          '${getCurrentID()}_${getCurrentTitle()}_${getCurrentDetail()}_${getCurrentCategory()}',
          _isFavorited);

      List<String> currentFavorites = prefs.getStringList('favorites') ?? [];
      if (_isFavorited) {
        currentFavorites.add(json.encode({
          'id': getCurrentID(),
          'title': getCurrentTitle(),
          'details': getCurrentDetail(),
          'category': getCurrentCategory(),
          'audio': getCurrentAudio(),
        }));
      } else {
        currentFavorites.removeWhere((item) {
          Map<String, dynamic> current = json.decode(item);
          return current['id'] == getCurrentID() &&
              current['title'] == getCurrentTitle() &&
              current['details'] == getCurrentDetail() &&
              current['category'] == getCurrentCategory() &&
              current['audio'] == getCurrentAudio();
        });
      }
      prefs.setStringList('favorites', currentFavorites);

      widget.onFavoriteChanged(); // Notify the parent widget
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
    _loadFavoriteState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ພຣະສູດ',
          style: TextStyle(fontSize: 17), // Adjust the font size as needed
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // If the current route is the initial route, handle the back action differently
              Navigator.of(context).maybePop();
            }
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
          const SizedBox(width: 5),
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
          const SizedBox(width: 5),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 5),
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
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.filteredData.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final title = widget.filteredData[index][1].toString();
          final detailLink = widget.filteredData[index][3].toString();

          return SingleChildScrollView(
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
                      title,
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
                    future: _fetchData(detailLink),
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
                              children: parseContent(detailLink),
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
                  const SizedBox(height: 150),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100, // Adjusted width for custom size
            height: 48, // Adjusted height for custom size
            child: FloatingActionButton(
              heroTag: 'fab1',
              onPressed: _increaseFontSize,
              backgroundColor: const Color(0xFFF5F5F5),
              child: const Icon(
                Icons.add,
                size: 24, // Optional: Adjust icon size if needed
                color: Color.fromARGB(241, 179, 93, 78),
              ),
            ),
          ),
          SizedBox(
            width: 50, // Adjusted width for custom size
            height: 48, // Adjusted height for custom size
            child: FloatingActionButton(
              heroTag: 'fab2',
              onPressed: _decreaseFontSize,
              backgroundColor: const Color(0xFFF5F5F5),
              child: const Icon(
                Icons.remove,
                size: 24, // Optional: Adjust icon size if needed
                color: Color.fromARGB(241, 179, 93, 78),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 48, // Adjusted width for custom size
            height: 48, // Adjusted height for custom size
            child: FloatingActionButton(
              heroTag: 'fab3',
              onPressed: _copyContentToClipboard,
              backgroundColor: const Color(0xFFF5F5F5),
              child: const Icon(
                Icons.content_copy,
                size: 24, // Optional: Adjust icon size if needed
                color: Color.fromARGB(241, 179, 93, 78),
              ),
            ),
          ),
          const SizedBox(width: 1),
          SizedBox(
            width: 48, // Adjusted width for custom size
            height: 48, // Adjusted height for custom size
            child: FloatingActionButton(
              heroTag: 'fab4',
              onPressed: _shareDetailLink,
              backgroundColor: const Color(0xFFF5F5F5),
              child: const Icon(
                Icons.share,
                size: 24, // Optional: Adjust icon size if needed
                color: Color.fromARGB(241, 179, 93, 78),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareDetailLink() {
    final currentTitle = getCurrentTitle();

    final currentRoute =
        'https://buddha-nature.web.app/#/details/${widget.filteredData[_currentPageIndex][0]}';

    final shareText = '$currentTitle\n $currentRoute';

    Share.share(shareText, subject: currentTitle);
  }

  Future<void> _copyContentToClipboard() async {
    String detailText = widget.filteredData[_currentPageIndex][3].toString();
    String cleanedText = detailText.replaceAll(
        RegExp(r'<\/?b>'), ''); // Remove <b> and </b> tags
    Clipboard.setData(ClipboardData(text: cleanedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content copied to clipboard')),
    );
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
