// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, deprecated_member_use, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/home.dart';
import 'package:lao_tipitaka/page/sutraL_list.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await path.getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.initFlutter('hive_db');

  Hive.registerAdapter<Sutra>(SutraAdapter());

  await Hive.openBox<Sutra>("sutra");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lao-Tipitaka',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Lao-Tipitaka'),
    );
  }
}

class NavigationDrawer extends StatefulWidget {
  const NavigationDrawer({super.key});

  @override
  State<NavigationDrawer> createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  late final bool _isChecked = false;
  late final Color _checkColor = const Color.fromARGB(255, 175, 93, 78);

  // Menu
  final String urlWebapp = "https://dhama-sutra.netlify.app";
  final String urlBooks =
      "https://drive.google.com/drive/folders/1z6vIdR-fzXxxhCM-rjqq8F7ZHLNlP5E3?usp=sharing";
  final String urlDhamma =
      "https://buddhaword.vercel.app/4d1689680be74b6f96071c8dda16db9e";
  final String urlEnglish = "https://buddhaword-english.blogspot.com";
  final String urlCalendar = "https://bit.ly/LaosCalendar";
  final String urlArnuta = "https://arnuta.blogspot.com/";
  final String urlChat = "https://chat.whatsapp.com/CZ7j5fhSatK37v76zmmVCK";

  void _openLinkWebapp() async {
    if (await canLaunch(urlWebapp)) {
      await launch(urlWebapp);
    } else {
      throw 'Could not launch $urlWebapp';
    }
  }

  void _openLinkBooks() async {
    if (await canLaunch(urlBooks)) {
      await launch(urlBooks);
    } else {
      throw 'Could not launch $urlBooks';
    }
  }

  void _openLinkDhamma() async {
    if (await canLaunch(urlDhamma)) {
      await launch(urlDhamma);
    } else {
      throw 'Could not launch $urlDhamma';
    }
  }

  void _openLinkEnglish() async {
    if (await canLaunch(urlEnglish)) {
      await launch(urlEnglish);
    } else {
      throw 'Could not launch $urlEnglish';
    }
  }

  void _openLinkCalendar() async {
    if (await canLaunch(urlCalendar)) {
      await launch(urlCalendar);
    } else {
      throw 'Could not launch $urlCalendar';
    }
  }

  void _openLinkArnuta() async {
    if (await canLaunch(urlArnuta)) {
      await launch(urlArnuta);
    } else {
      throw 'Could not launch $urlArnuta';
    }
  }

  void _openLinkChat() async {
    if (await canLaunch(urlChat)) {
      await launch(urlChat);
    } else {
      throw 'Could not launch $urlChat';
    }
  }

  // Sound
  final String urlSoundKarawatSunlert =
      "https://buddhaword.siteoly.com/%E0%BA%84%E0%BA%B0%E0%BA%A3%E0%BA%B2%E0%BA%A7%E0%BA%B2%E0%BA%AA%E0%BA%8A%E0%BA%B1%E0%BB%89%E0%BA%99%E0%BB%80%E0%BA%A5%E0%BA%B5%E0%BA%94(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlSathayaiytham =
      "https://buddhaword.siteoly.com/%E0%BA%AA%E0%BA%B2%E0%BA%97%E0%BA%B0%E0%BA%8D%E0%BA%B2%E0%BA%8D%E0%BA%97%E0%BA%B1%E0%BA%A1(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";

  void _openSoundKarawatSunlert() async {
    if (await canLaunch(urlSoundKarawatSunlert)) {
      await launch(urlSoundKarawatSunlert);
    } else {
      throw 'Could not launch $urlSoundKarawatSunlert';
    }
  }

  void _openLinkSathayaiytham() async {
    if (await canLaunch(urlSathayaiytham)) {
      await launch(urlSathayaiytham);
    } else {
      throw 'Could not launch $urlSathayaiytham';
    }
  }

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            buildHeader(context),
            buildMenuItems(context),
          ],
        )),
      );

  Widget buildHeader(BuildContext context) => Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      );

  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 0, //verticalSpacing
          children: [
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.library_books, color: _checkColor)
                  : Icon(Icons.library_books_outlined, color: _checkColor),
              title: const Text(
                'ພຣະສູດ 📖',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(
                      title: 'Lao-Tipitaka',
                    ),
                  ),
                ),
              },
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.book, color: _checkColor)
                  : Icon(Icons.book_outlined, color: _checkColor),
              title: const Text(
                'ປື້ມ & ເເຜນຜັງ 📚',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkBooks(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.open_in_browser_rounded, color: _checkColor)
                  : Icon(Icons.open_in_browser_outlined, color: _checkColor),
              title: const Text(
                'ພຣະສູດ Web🌐',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkWebapp(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.filter_vintage, color: _checkColor)
                  : Icon(Icons.sunny, color: _checkColor),
              title: const Text(
                '🌸ພຣະທັມ🌸',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkDhamma(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.language, color: _checkColor)
                  : Icon(Icons.language_outlined, color: _checkColor),
              title: const Text(
                'Buddhaword English',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkEnglish(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.calendar_month, color: _checkColor)
                  : Icon(Icons.calendar_month_outlined, color: _checkColor),
              title: const Text(
                'ປະຕິທິນທັມ 🗓️',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkCalendar(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.video_library, color: _checkColor)
                  : Icon(Icons.video_collection_outlined, color: _checkColor),
              title: const Text(
                'ອະນັດຕາ 📺',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkArnuta(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.whatsapp, color: _checkColor)
                  : Icon(Icons.whatsapp_outlined, color: _checkColor),
              title: const Text(
                'ສົນທະນາທັມ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkChat(),
            ),
            ExpansionTile(
              leading: Icon(Icons.hearing,
                  color: const Color.fromARGB(241, 179, 93, 78)),
              title: Text(
                'ສຽງທັມ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              children: [
                ExpansionTile(
                  title: Text(
                    'ທັມໃນເບື້ອງຕົ້ນ',
                    style: TextStyle(fontSize: 18),
                  ),
                  children: [
                    ListTile(
                      title: Text(
                        'ຄະຣາວາດຊັ້ນເລີດ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openSoundKarawatSunlert(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ສາທະຍາຍທັມ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openLinkSathayaiytham(),
                    ),
                  ],
                ),
                const Divider(
                  color: Color.fromARGB(255, 221, 220, 217),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(
                  height: 5,
                ),
                ListTile(
                  title: Text(
                    'ທັມໃນທ່າມກາງ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Color.fromARGB(255, 221, 220, 217),
                  thickness: 1,
                  height: 1,
                ),
                const SizedBox(
                  height: 5,
                ),
                ListTile(
                  title: Text(
                    'ທັມໃນທີສຸດ',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  height: 1,
                ),
              ],
            ),
            const Divider(
              color: Colors.black54,
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.add, color: _checkColor)
                  : Icon(Icons.add_outlined, color: _checkColor),
              title: const Text(
                'ເພີ່ມພຣະສູດ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const SutraList(
                    title: 'ລາຍການພຣະສູດ',
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
