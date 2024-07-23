// ignore_for_file: library_private_types_in_public_api, file_names, prefer_const_constructors, unnecessary_null_comparison
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import '../../layouts/NavigationDrawer.dart';
import '../../themes/ThemeProvider.dart';
import 'BookReadingScreenPage.dart';
import 'DetailPage.dart';

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

  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentUrl;

  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _filteredData = _filterData(widget.searchTerm);
    _searchController.text = widget.searchTerm;
  }

  Future<void> _setupAudio(int index, String audio) async {
    try {
      if (audio != null && audio != '/' && audio != _currentUrl) {
        await _player.setUrl(audio);
        _currentUrl = audio;

        _playerStateSubscription?.cancel();
        _durationSubscription?.cancel();
        _positionSubscription?.cancel();

        _playerStateSubscription =
            _player.playerStateStream.listen((playerState) {
          setState(() {
            _isPlaying = playerState.playing;
            if (playerState.processingState == ProcessingState.completed) {
              // Automatically play the next audio when current audio finishes
              if (index < _filteredData.length - 1) {
                final nextAudio = _filteredData[index + 1][5].toString();
                _playPauseAudio(index + 1, nextAudio);
              }
            }
          });
        });

        _durationSubscription = _player.durationStream.listen((duration) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        });

        _positionSubscription = _player.positionStream.listen((position) {
          setState(() {
            _position = position;
          });
        });

        setState(() {
          _currentlyPlayingIndex = index;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing player: $e');
      }
    }
  }

  Future<void> _disposeAudioPlayer() async {
    await _playerStateSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _player.pause();
    _player.dispose();
  }

  Future<void> _playPauseAudio(int index, String audioUrl) async {
    if (_currentlyPlayingIndex == index) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } else {
      await _setupAudio(index, audioUrl); // Setup the new audio
      await _player.play(); // Play the audio immediately after setup
    }
  }

  void _seek(Duration position) {
    _player.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _disposeAudioPlayer();

    super.dispose();
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
                final audio = rowData[5].toString();

                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  shadowColor: Color.fromARGB(255, 91, 50, 35).withOpacity(0.9),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(
                            top: 1.5), // Add top margin here
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    10), // Space between the button and title
                            if (audio != '/')
                              CircleAvatar(
                                radius:
                                    22, // Smaller radius for a smaller button
                                backgroundColor: Colors
                                    .transparent, // Transparent background for CircleAvatar
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.brown.shade600,
                                        Colors.brown.shade600,
                                        Colors.brown.shade600,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      _currentlyPlayingIndex == index &&
                                              _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white, // Icon color
                                    ),
                                    iconSize: 20, // Smaller icon size
                                    onPressed: () async {
                                      await _playPauseAudio(index, audio);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      subtitle: audio != '/'
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_currentlyPlayingIndex == index)
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.skip_previous),
                                            onPressed: () {
                                              if (index > 0) {
                                                final previousAudio =
                                                    _filteredData[index - 1][5]
                                                        .toString();
                                                _playPauseAudio(
                                                    index - 1, previousAudio);
                                              }
                                            },
                                          ),
                                          Expanded(
                                            child: Slider(
                                              min: 0.0,
                                              max: _duration.inMilliseconds
                                                  .toDouble(),
                                              value: _position.inMilliseconds
                                                  .toDouble()
                                                  .clamp(
                                                      0.0,
                                                      _duration.inMilliseconds
                                                          .toDouble()),
                                              onChanged: (value) {
                                                _seek(Duration(
                                                    milliseconds: value
                                                        .toInt()
                                                        .clamp(
                                                            0,
                                                            _duration
                                                                .inMilliseconds)));
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.skip_next),
                                            onPressed: () {
                                              if (index <
                                                  _filteredData.length - 1) {
                                                final nextAudio =
                                                    _filteredData[index + 1][5]
                                                        .toString();
                                                _playPauseAudio(
                                                    index + 1, nextAudio);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(_formatDuration(_position)),
                                            Text(_formatDuration(
                                                _duration - _position)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            )
                          : null,
                      onTap: () {
                        // Navigate to detail page or perform other actions
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              id: id,
                              title: title,
                              details: detailLink,
                              category: category,
                              audio: audio,
                              onFavoriteChanged: () => setState(() {}),
                            ),
                          ),
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
      floatingActionButton: _filteredData.isNotEmpty
          ? FloatingActionButton(
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
              tooltip: 'ອ່ານປຶ້ມ',
              child: const Icon(Icons.auto_stories_outlined),
            )
          : null,
    );
  }
}
