// ignore_for_file: depend_on_referenced_packages, file_names, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../layouts/NavigationDrawer.dart';
import '../../themes/ThemeProvider.dart';
import 'DetailPage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<List<dynamic>> _data = [];
  List<List<dynamic>> _filteredData = [];
  String _searchTerm = '';
  String _selectedCategory = ''; // Define _selectedCategory

  @override
  void initState() {
    super.initState();
    fetchData(_searchTerm);

    // Request focus on the TextField when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
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
              padding: const EdgeInsets.all(8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
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
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory.isNotEmpty
                              ? _selectedCategory
                              : null,
                          decoration: InputDecoration(
                            hintText: 'ໝວດທັມ',
                            suffixIcon: _selectedCategory.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedCategory, // Display selected category value
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCategory = '';
                                            if (_searchTerm.isEmpty) {
                                              updateData(_searchTerm,
                                                  _selectedCategory);
                                            } else {
                                              fetchData(_searchTerm);
                                            }
                                          });
                                        },
                                      ),
                                    ],
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
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: ListView.builder(
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
                          fontSize: 18, // Adjust the font size as needed
                          fontWeight: FontWeight.bold, // Make the title bold
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
                                // Update data when favorite state changes
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
}
