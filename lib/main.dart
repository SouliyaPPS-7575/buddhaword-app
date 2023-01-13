// ignore_for_file: unnecessary_const

import 'package:flutter/material.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/books.dart';
import 'package:lao_tipitaka/page/home.dart';
import 'package:lao_tipitaka/page/sutraL_list.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';

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
                '📚📖 ປື້ມ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const BookList(),
                  ),
                ),
              },
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
            const ExpansionTile(
              leading: Icon(Icons.category,
                  color: const Color.fromARGB(255, 175, 93, 78)),
              title: Text(
                'ໝວດທັມ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              children: [
                ListTile(
                  title: Text(
                    'ທັມໃນເບື້ອງຕົ້ນ',
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
                  height: 5,
                ),
              ],
            ),
          ],
        ),
      );
}
