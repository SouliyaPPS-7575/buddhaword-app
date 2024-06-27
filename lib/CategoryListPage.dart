// ignore_for_file: library_private_types_in_public_api, file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NavigationDrawer.dart';
import 'main.dart';

class CategoryListPage extends StatefulWidget {
  final List<List<dynamic>> data;
  final String selectedCategory;
  final String searchTerm;

  const CategoryListPage({
    Key? key,
    required this.data,
    required this.selectedCategory,
    required this.searchTerm,
  }) : super(key: key);

  @override
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late List<List<dynamic>> _filteredData;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = _filterData(widget.searchTerm);
    _searchController.text = widget.searchTerm;
  }

  List<List<dynamic>> _filterData(String searchTerm) {
    return widget.data
        .where((row) =>
            row.length > 4 &&
            row[4] == widget.selectedCategory &&
            row.any((cell) => cell
                .toString()
                .toLowerCase()
                .contains(searchTerm.toLowerCase())))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCategory),
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
          // Add a switch to toggle dark mode
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Switch(
                value: themeProvider.isDarkMode,
                onChanged: (isDarkMode) {
                  themeProvider.toggleTheme(isDarkMode);
                },
                activeColor: Theme.of(context)
                    .colorScheme
                    .secondary, // Set the color of the switch when active
              );
            },
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
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
                            _filteredData = _filterData('');
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _filteredData = _filterData(value);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                final rowData = _filteredData[index];
                final id = rowData[0].toString();
                final title = rowData[1]
                    .toString(); // Assuming the first column contains the title
                final detailLink = rowData[3]
                    .toString(); // Assuming the second column contains the detail link
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
                      // Navigate to detail page or perform other actions
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                              id: id,
                              title: title,
                              details: detailLink,
                              category: category),
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
    );
  }
}
