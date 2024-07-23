// ignore_for_file: depend_on_referenced_packages, file_names, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
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
    fetchData(_searchTerm);

    // Request focus on the TextField when the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _setupAudio(int index, String audio) async {
    try {
      if (audio.isNotEmpty && audio != '/' && audio != _currentUrl) {
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
    _focusNode.dispose();
    _disposeAudioPlayer();

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
                    elevation: 8,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    shadowColor:
                        Color.fromARGB(255, 91, 50, 35).withOpacity(0.9),
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
                                                      _filteredData[index - 1]
                                                              [5]
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
                                                      _filteredData[index + 1]
                                                              [5]
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
