// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, must_be_immutable, file_names, unrelated_type_equality_checks, avoid_web_libraries_in_flutter, unnecessary_null_comparison, use_build_context_synchronously, sized_box_for_whitespace, unused_local_variable, prefer_const_constructors_in_immutables, depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../layouts/NavigationDrawer.dart';
import '../../themes/ThemeProvider.dart';
import 'RandomImagePage.dart';
import 'VideoPage.dart';

class PlayVideoPage extends StatefulWidget {
  final String? id;
  final String? title;
  final String? details;
  final String? category;
  final String? link;

  PlayVideoPage({
    super.key,
    this.id,
    this.title,
    this.details,
    this.category,
    this.link,
  });

  @override
  _PlayVideoPageState createState() => _PlayVideoPageState();
}

class _PlayVideoPageState extends State<PlayVideoPage> {
  List<List<dynamic>> _data = [];

  String? _videoLink;

  String _videoTitle = '';

  InAppWebViewController? _webviewController;

  bool hasInternet = false;

  @override
  void initState() {
    super.initState();

    _videoTitle = widget.title ?? ''; // Initialize the title

    _checkConnectivity();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant PlayVideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.id != oldWidget.id || widget.link != oldWidget.link) {
      _videoTitle = widget.title ?? ''; // Update title when widget updates
      _initializeVideoLink(widget.link);
    }
  }

  Future<void> _initialize() async {
    await _checkConnectivity();
    _checkRouteAndFetchData();
    _initializeVideoLink(widget.link);
  }

  Future<void> _initializeVideoLink(String? videoLink) async {
    if (videoLink != null && videoLink.isNotEmpty) {
      setState(() {
        _videoLink = videoLink;
        _loadVideoInInAppWebView(
            videoLink, MediaQuery.of(context).size.width > 600 ? 130 : 500);
      });
    }
  }

  void _loadVideoInInAppWebView(String videoLink, double height) {
    if (_webviewController == null) {
      // The InAppWebViewController is not initialized
      return;
    }

    String url = '';
    if (videoLink.contains('youtube.com') || videoLink.contains('youtu.be')) {
      final videoYoutubeLink = convertYoutubeLink(videoLink);
      final videoId = YoutubePlayerController.convertUrlToId(videoYoutubeLink);
      if (videoId != null) {
        url = 'https://www.youtube.com/embed/$videoId';
      }
    } else if (videoLink.contains('facebook.com')) {
      url = getFacebookEmbedUrl(videoLink, height);
    }

    if (url.isNotEmpty) {
      _webviewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
    }
  }

  String getFacebookEmbedUrl(String videoLink, double height) {
    final uri = Uri.parse(videoLink);
    final videoId = uri.pathSegments.last; // Extract video ID
    return 'https://www.facebook.com/plugins/video.php?height=${height.toInt()}&href=${Uri.encodeComponent(videoLink)}';
  }

  String convertYoutubeLink(String shortLink) {
    // Extract the video ID and parameters
    final uri = Uri.parse(shortLink);
    final videoId = uri.pathSegments[0];
    final params = uri.query;

    // Construct the embed link
    return 'https://www.youtube.com/embed/$videoId?$params';
  }

  Future<void> _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      hasInternet = result != ConnectivityResult.none;
    });
  }

  Future<void> _checkRouteAndFetchData() async {
    if (hasInternet) {
      await fetchDataFromAPI();
    } else {
      await _loadDataFromSharedPreferences();
    }
  }

  Future<void> _loadDataFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('videoLocalData');
      if (cachedData != null && cachedData.isNotEmpty) {
        setState(() {
          _data =
              json.decode(cachedData).cast<List<dynamic>>().reversed.toList();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data from SharedPreferences: $e');
      }
    }
  }

  Future<dynamic> getFromSharedPreferences(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting from SharedPreferences: $e');
      }
    }
    return null;
  }

  Future<void> saveToSharedPreferences(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value.toString());
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to SharedPreferences: $e');
      }
    }
  }

  Future<void> fetchDataFromAPI() async {
    try {
      final response = await http.get(Uri.parse(
          'https://sheets.googleapis.com/v4/spreadsheets/1mKtgmZ_Is4e6P3P5lvOwIplqx7VQ3amicgienGN9zwA/values/video!1:1000000?key=AIzaSyDFjIl-SEHUsgK0sjMm7x0awpf8tTEPQjs'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> sheetValues =
            jsonResponse['values'] as List<dynamic>;

        final List<List<dynamic>> values =
            sheetValues.skip(1).map((row) => List<dynamic>.from(row)).toList();

        setState(() {
          _data = values.reversed.toList();
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('videoLocalData', json.encode(_data));
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

  Widget _buildVideoCard(BuildContext context, int index) {
    if (_data.isEmpty || index >= _data.length || _data[index].length < 5) {
      return SizedBox
          .shrink(); // Prevents RangeError by returning an empty widget
    }

    if (_data.isNotEmpty && index < _data.length) {
      final id = _data[index][0].toString();
      final title = _data[index][1].toString();
      final details = _data[index][2].toString();
      final category = _data[index][3].toString();
      final videoLinks = _data[index][4].toString();

      final videoId = YoutubePlayerController.convertUrlToId(videoLinks.trim());

      // Check if the link is from YouTube or Facebook
      final isYouTube =
          videoLinks.contains('youtube.com') || videoLinks.contains('youtu.be');
      final isFacebook = videoLinks.contains('facebook.com');

      if (isYouTube) {
        final videoId =
            YoutubePlayerController.convertUrlToId(videoLinks.trim());

        if (videoId == null) {
          return SizedBox.shrink(); // Skip invalid video links
        }

        final thumbnailUrl =
            'https://corsproxy.io/?https://img.youtube.com/vi/$videoId/hqdefault.jpg';

        return GestureDetector(
          onTap: () {
            setState(() {
              _videoTitle = title; // Update title
              _videoLink = videoLinks;
              _initializeVideoLink(videoLinks);
            });
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
                    color: Colors.black,
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
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
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
                setState(() {
                  _videoTitle = title; // Update title
                  _videoLink = videoLinks;
                  _initializeVideoLink(videoLinks);
                });
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
    } else {
      return SizedBox.shrink();
    }
  }

  void _shareVideoLink() {
    final url =
        'https://buddha-nature.web.app/#/playVideo/${widget.id}?videoLinks=${Uri.encodeComponent(_videoLink!)}';

    String? title = _data.firstWhere(
      (row) => row.isNotEmpty && row[0] == widget.id,
      orElse: () => [],
    )[1];

    final shareText = '$title\n $url';

    if (_videoLink != null) {
      Share.share(shareText, subject: title);
    } else {
      if (kDebugMode) {
        print('Video link is null, cannot share.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safeguard: Ensure videoModel has enough elements before accessing
    final videoModel = _data.firstWhere(
      (row) => row.isNotEmpty && row[0] == widget.id,
      orElse: () => [],
    );

    return _videoLink == null
        ? RandomImagePage()
        : Scaffold(
            appBar: AppBar(
              title: Text(
                _videoTitle, // Use the updated title
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => VideoPage(
                        title: '',
                      ),
                    ),
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: _shareVideoLink,
                ),
                const SizedBox(width: 10),
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
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Define a base aspect ratio for the video player
                const double aspectRatio = 16 / 9;

                // Set different heights for mobile and tablet/desktop
                double videoPlayerHeight;
                double videoListHeight;

                if (constraints.maxWidth < 600) {
                  // Considered mobile
                  videoPlayerHeight = constraints.maxHeight * 0.6;
                  videoListHeight = constraints.maxHeight - videoPlayerHeight;
                } else {
                  // Considered tablet/desktop
                  videoPlayerHeight = constraints.maxHeight *
                      0.6; // Custom height for desktop (50% of screen height)
                  videoListHeight = constraints.maxHeight - videoPlayerHeight;
                }

                final double videoWidth = constraints.maxWidth;

                final isTabletOrDesktop =
                    MediaQuery.of(context).size.width > 600;

                final String videoLink = convertYoutubeLink(_videoLink!);

                // Assume getFromLocalStorage is a function that returns the list of videos
                final videoLocalData =
                    getFromSharedPreferences('videoLocalData');

                return Column(
                  children: [
                    // Video Player
                    Container(
                      width: double.infinity,
                      height: videoPlayerHeight,
                      child: InAppWebView(
                        initialUrlRequest:
                            URLRequest(url: Uri.parse(videoLink)),
                        initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                            mediaPlaybackRequiresUserGesture: true,
                            useOnLoadResource:
                                true, // Ensure all resources are loaded
                          ),
                        ),
                        onWebViewCreated: (controller) {
                          _webviewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          if (kDebugMode) {
                            print('Loading: $url');
                          }
                        },
                        onLoadStop: (controller, url) {
                          if (kDebugMode) {
                            print('Loaded: $url');
                          }
                        },
                      ),
                    ),

                    // Divider between video player and video list
                    const Divider(
                      height: 1,
                      thickness: 1,
                    ),
                    // Video List
                    Expanded(
                      child: isTabletOrDesktop
                          ? GridView.builder(
                              padding: EdgeInsets.all(5.0),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    (constraints.maxWidth / 300).floor(),
                                crossAxisSpacing: 16.0,
                                mainAxisSpacing: 16.0,
                                childAspectRatio: 16 / 12.5,
                              ),
                              itemCount: _data.length,
                              itemBuilder: (context, index) =>
                                  _buildVideoCard(context, index),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(5.0),
                              itemCount: _data.length,
                              itemBuilder: (context, index) =>
                                  _buildVideoCard(context, index),
                            ),
                    )
                  ],
                );
              },
            ),
          );
  }
}
