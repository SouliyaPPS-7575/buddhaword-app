// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, file_names, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layouts/NavigationDrawer.dart';
import '../themes/ThemeProvider.dart';
import 'BookReadingScreenPage.dart';
import 'DetailPage.dart';
import 'SearchPage.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _favorites = [];
  List<String> _filteredFavorites = []; // Add a list for filtered favorites
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();

  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Load the list of favorites
      _favorites = prefs.getStringList('favorites') ?? [];
      _filteredFavorites =
          _favorites; // Initialize filtered favorites with all favorites
    });
  }

  void _filterFavorites(String query) {
    setState(() {
      _searchTerm = query;
      _filteredFavorites = _favorites.where((favorite) {
        final itemData = jsonDecode(favorite);
        final id = itemData['id'].toLowerCase();
        final title = itemData['title'].toLowerCase();
        final detail = itemData['details'].toLowerCase(); // Get details
        final category = itemData['category'].toLowerCase(); // Get category
        return id.contains(query.toLowerCase()) ||
            title.contains(
                query.toLowerCase()) || // Check if title contains query
            detail.contains(
                query.toLowerCase()) || // Check if detail contains query
            category.contains(
                query.toLowerCase()); // Check if category contains query
      }).toList();
    });
  }

  void _onFavoriteChanged() {
    _loadFavorites();
  }

  Future<void> _deleteAllFavorites() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("ລຶບລາຍການທີ່ຖືກໃຈທັງໝົດບໍ?"),
          content: const Text("ທ່ານແນ່ໃຈບໍ່ວ່າຕ້ອງການລຶບລາຍການທີ່ຖືກໃຈທັງໝົດ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("ຍົກເລີກ"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("ລຶບ"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('favorites');

                setState(() {
                  _favorites.clear();
                  _filteredFavorites.clear();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ພຣະສູດຖືກໃຈ',
          style: TextStyle(fontSize: 18), // Adjust the font size as needed
        ),
        actions: _favorites
                .isNotEmpty // Show delete button only if favorites is not empty
            ? [
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
                const SizedBox(width: 6), // Custom space
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteAllFavorites,
                ),
                const SizedBox(width: 6), // Custom space
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
              ]
            : [
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
                const SizedBox(width: 10), // Custom space
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
      body: _favorites.isEmpty
          ? const Center(child: Text('No favorites added.'))
          : Padding(
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
                              suffixIcon: _searchTerm.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchTerm = '';
                                          _filterFavorites(_searchTerm);
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _filterFavorites(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final item = _filteredFavorites[index];
                        // Assuming each item is a JSON string, parse it
                        final itemData = jsonDecode(item);
                        final id = itemData['id'];
                        final title = itemData['title'];
                        final detailLink = itemData['details'];
                        final category = itemData['category'];
                        return Card(
                          child: ListTile(
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                                    onFavoriteChanged: _onFavoriteChanged,
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
      floatingActionButton: _filteredFavorites.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                // Implement your action here, e.g., navigate to book reading screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookReadingScreenPage(
                      filteredData: _filteredFavorites.map((fav) {
                        return [
                          jsonDecode(fav)['id'],
                          jsonDecode(fav)['title'],
                          jsonDecode(fav)['author'],  // Assuming this should be 'author' instead of a duplicate 'title'
                          jsonDecode(fav)['details'],
                          jsonDecode(fav)['category'],
                        ];
                      }).toList(),
                      onFavoriteChanged: () => setState(() {}),
                    ),
                  ),
                );
              },
              tooltip: 'ອ່ານປຶ້ມ',
              child: const Icon(Icons.auto_stories_outlined),
            )
          : null,
    );
  }
}
