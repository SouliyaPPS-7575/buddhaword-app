// ignore_for_file: prefer_const_constructors, must_be_immutable, file_names, library_private_types_in_public_api, prefer_const_constructors_in_immutables

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../layouts/NavigationDrawer.dart';
import '../../themes/ThemeProvider.dart';
import 'PlayVideoPage.dart';
import 'VideoPage.dart';

class CategoryListPage extends StatefulWidget {
  final List<List<dynamic>> data;
  final String selectedCategory;
  final String searchTerm;

  CategoryListPage({
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
  final Map<String, YoutubePlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _filteredData = _filterData(widget.searchTerm).reversed.toList();
    _searchController.text = widget.searchTerm;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controllers.forEach((key, controller) => controller.close());
    super.dispose();
  }

  List<List<dynamic>> _filterData(String searchTerm) {
    return widget.data
        .where((row) =>
            row.length > 3 &&
            row[3] == widget.selectedCategory &&
            row.any((cell) => cell
                .toString()
                .toLowerCase()
                .contains(searchTerm.toLowerCase())))
        .toList();
  }

  Widget _buildVideoCard(BuildContext context, int index) {
    if (_filteredData.isEmpty ||
        index >= _filteredData.length ||
        _filteredData[index].length < 5) {
      return SizedBox.shrink();
    }

    final id = _filteredData[index][0].toString();
    final title = _filteredData[index][1].toString();
    final details = _filteredData[index][2].toString();
    final category = _filteredData[index][3].toString();
    final videoLinks = _filteredData[index][4].toString();

    // Check if the link is from YouTube or Facebook
    final isYouTube =
        videoLinks.contains('youtube.com') || videoLinks.contains('youtu.be');
    final isFacebook = videoLinks.contains('facebook.com');

    if (isYouTube) {
      final videoId = YoutubePlayerController.convertUrlToId(videoLinks.trim());

      if (videoId == null) {
        return SizedBox.shrink(); // Skip invalid video links
      }

      // Get the thumbnail URL from YouTube
      final thumbnailUrl =
          'https://corsproxy.io/?https://img.youtube.com/vi/$videoId/hqdefault.jpg';

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayVideoPage(
                id: id,
                title: title,
                details: details,
                category: category,
                link: videoLinks,
              ),
            ),
          );
        },
        child: Card(
          elevation: 8,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          shadowColor: Color.fromARGB(255, 91, 50, 35).withOpacity(0.9),
          child: Column(
            children: [
              // Display the thumbnail image using an HTML img tag
              Container(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15.0)),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15.0)),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),
              ListTile(
                title: Padding(
                  padding: const EdgeInsets.only(top: 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                          overflow: TextOverflow.ellipsis, // Handle overflow
                          maxLines: 2, // Limit to one line
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
    } else if (isFacebook) {
      // For Facebook videos, we can embed them directly or use a thumbnail
      // Here, we'll use a generic thumbnail and link to the Facebook video
      Future<String?> getFacebookVideoThumbnailUrl(
          String videoId, String accessToken) async {
        final url =
            'https://graph.facebook.com/v20.0/$videoId?fields=thumbnails&access_token=$accessToken';

        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final thumbnailsData = data['thumbnails']?['data'];

          if (thumbnailsData != null && thumbnailsData.isNotEmpty) {
            // Get the URI from the first thumbnail in the list
            final firstThumbnail = thumbnailsData[0];
            return firstThumbnail['uri'];
          }
        }

        return null;
      }

      final uri = Uri.parse(videoLinks);
      final videoId = uri.pathSegments.last;

      return FutureBuilder<String?>(
        future: getFacebookVideoThumbnailUrl(videoId, accessToken),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No thumbnail available'));
          }

          final thumbnailUrl = snapshot.data!;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayVideoPage(
                    id: id,
                    title: title,
                    details: details,
                    category: category,
                    link: videoLinks,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 8,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              shadowColor: Color.fromARGB(255, 91, 50, 35).withOpacity(0.9),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15.0)),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Padding(
                      padding: const EdgeInsets.only(top: 0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
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
        },
      );
    } else {
      return SizedBox.shrink(); // Skip non-video links
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedCategory,
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPage(title: '',),
              ),
            );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 17.0, letterSpacing: 0.5),
              decoration: InputDecoration(
                hintText: 'ຄົ້ນຫາ...',
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
            child: isTabletOrDesktop
                ? GridView.builder(
                    padding: EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 16 / 12.5,
                    ),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) =>
                        _buildVideoCard(context, index),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) =>
                        _buildVideoCard(context, index),
                  ),
          ),
        ],
      ),
    );
  }
}
