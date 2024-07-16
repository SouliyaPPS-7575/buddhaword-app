// ignore_for_file: depend_on_referenced_packages, file_names, use_key_in_widget_constructors, library_private_types_in_public_api, unrelated_type_equality_checks

import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../layouts/NavigationDrawer.dart';
import '../themes/ThemeProvider.dart';
import 'SearchPage.dart';

class DetailPage extends StatefulWidget {
  final String id;
  final String title;
  final String details;
  final String category;
  final String audio;

  final VoidCallback onFavoriteChanged; // Add this line

  const DetailPage({
    required this.id,
    required this.title,
    required this.details,
    required this.category,
    required this.audio,
    required this.onFavoriteChanged, // Add this line
  });

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  double _fontSize = 18.0;
  double get fontSize => _fontSize;

  bool _isFavorited = false; // Add this line

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  bool hasInternet =
      Connectivity().checkConnectivity() != ConnectivityResult.none;

  @override
  void initState() {
    super.initState();

    _loadFavoriteState();
    _loadFontSizeFromSharedPreferences();

    if (hasInternet && widget.audio != '/') {
      _initializePlayer();
    }
  }

  void _initializePlayer() async {
    try {
      await audioPlayer.setSourceUrl(widget.audio);

      _playerStateSubscription =
          audioPlayer.onPlayerStateChanged.listen((playerState) {
        setState(() {
          isPlaying = playerState == PlayerState.playing;
        });
      });

      _durationSubscription =
          audioPlayer.onDurationChanged.listen((newDuration) {
        setState(() {
          duration = newDuration;
        });
      });

      _positionSubscription =
          audioPlayer.onPositionChanged.listen((newPosition) {
        setState(() {
          position = newPosition;
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing audio player: $e');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();

    audioPlayer.dispose();

    // Cancel subscriptions here to avoid LateInitializationError
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
  }

  void _disposeAudioPlayer() {
    // clear state playing audio
    audioPlayer.stop();

    // Cancel subscriptions here to avoid LateInitializationError
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
  }

  Future<void> _playPauseAudio() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      String? url = widget.audio;
      await audioPlayer.play(UrlSource(url));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  Future<void> _loadFavoriteState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Check if the current detail is in favorites
      List<String>? currentFavorites = prefs.getStringList('favorites');
      if (currentFavorites != null) {
        _isFavorited = currentFavorites.any((item) {
          Map<String, dynamic> current = json.decode(item);
          return current['id'] == widget.id &&
              current['title'] == widget.title &&
              current['details'] == widget.details &&
              current['category'] == widget.category &&
              current['audio'] == widget.audio;
        });
      } else {
        _isFavorited = false;

        // Initialize the favorites list
        prefs.setStringList('favorites', []);

        // Initialize the favorite state for the current detail

        prefs.setBool(
            '${widget.id}_${widget.title}_${widget.details}_${widget.category}_${widget.audio}',
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
          '${widget.id}_${widget.title}_${widget.details}_${widget.category}_${widget.audio}',
          _isFavorited);

      List<String> currentFavorites = prefs.getStringList('favorites') ?? [];
      if (_isFavorited) {
        currentFavorites.add(json.encode({
          'id': widget.id,
          'title': widget.title,
          'details': widget.details,
          'category': widget.category,
          'audio': widget.audio
        }));
      } else {
        currentFavorites.removeWhere((item) {
          Map<String, dynamic> current = json.decode(item);
          return current['id'] == widget.id &&
              current['title'] == widget.title &&
              current['details'] == widget.details &&
              current['category'] == widget.category &&
              current['audio'] == widget.audio;
        });
      }
      prefs.setStringList('favorites', currentFavorites);

      widget.onFavoriteChanged(); // Notify the parent widget
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ພຣະສູດ',
          style: TextStyle(fontSize: 18), // Adjust the font size as needed
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            _disposeAudioPlayer();

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
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              _disposeAudioPlayer();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 4),
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
              Column(
                children: [
                  if (widget.audio != '/' && hasInternet)
                    Center(
                      child: CircleAvatar(
                        radius: 25,
                        child: IconButton(
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 30,
                          onPressed: _playPauseAudio,
                        ),
                      ),
                    ),
                  if (isPlaying || position > Duration.zero)
                    Slider(
                      min: 0.0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await audioPlayer.seek(position);

                        await audioPlayer.resume();

                        setState(() {
                          this.position = position;
                        });
                      },
                    ),
                  if (isPlaying || position > Duration.zero)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTime(position)),
                          Text(formatTime(duration - position)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder<String>(
                future: _fetchData(widget.details),
                builder: (context, snapshot) {
                  if (!snapshot.hasData && !snapshot.hasError) {
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
              const SizedBox(height: 150),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 100,
            height: 48,
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
          SizedBox(
            width: 50,
            height: 48,
            child: FloatingActionButton(
              heroTag: 'fab2',
              onPressed: _decreaseFontSize,
              backgroundColor: const Color(0xFFF5F5F5),
              child: const Icon(
                Icons.remove,
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
                color: Color.fromARGB(241, 179, 93, 78),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareDetailLink() {
    final shareText =
        '${widget.title}\n\n https://buddha-nature.web.app/#/details/${widget.id}';

    Share.share(shareText, subject: widget.title);
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

  Future<void> _copyContentToClipboard() async {
    String copiedText = widget.details
        .replaceAll(RegExp(r'<\/?b>'), ''); // Remove <b> and </b> tags
    Clipboard.setData(ClipboardData(text: copiedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Content copied to clipboard')),
    );
  }

  Future<void> _loadFontSizeFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double fontSize = prefs.getDouble('fontSize') ?? 18.0;

    setState(() {
      _fontSize = fontSize;
    });
  }

  Future<void> _saveFontSizeToSharedPreferences(double fontSize) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize += 2.0;
    });

    _saveFontSizeToSharedPreferences(_fontSize);
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = _fontSize > 2.0 ? _fontSize - 2.0 : _fontSize;
    });

    _saveFontSizeToSharedPreferences(_fontSize);
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
