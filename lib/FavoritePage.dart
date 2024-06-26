// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages, file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NavigationDrawer.dart';
import 'main.dart';

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
        final title = itemData['title'].toLowerCase();
        final detail = itemData['details'].toLowerCase(); // Get details
        final category = itemData['category'].toLowerCase(); // Get category
        return title.contains(
                query.toLowerCase()) || // Check if title contains query
            detail.contains(
                query.toLowerCase()) || // Check if detail contains query
            category.contains(
                query.toLowerCase()); // Check if category contains query
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ພຣະສູດທີຖືກໃຈ'),
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
