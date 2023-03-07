// ignore_for_file: unnecessary_const, non_constant_identifier_names, avoid_print, deprecated_member_use, prefer_const_constructors
import 'package:lao_tipitaka/connectionUser.dart';
import 'package:flutter/material.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/home.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final dir = await path.getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.initFlutter('hive_db');
  Hive.registerAdapter<Sutra>(SutraAdapter());
  await Hive.openBox<Sutra>("sutra");
  await Hive.openBox('settings');

  // Call the createHiveListener function
  syncHiveWithFirebase();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, child) {
        final isDark = box.get('isDark', defaultValue: false);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ຄຳສອນພຣະພຸດທະເຈົ້າ',
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const HomePage(title: 'ຄຳສອນພຣະພຸດທະເຈົ້າ'),
        );
      },
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
  final String urlTarn =
      "https://buddhaword.siteoly.com/%E0%BA%97%E0%BA%B2%E0%BA%99(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlPathomtham =
      "https://buddhaword.siteoly.com/%E0%BA%9B%E0%BA%B0%E0%BA%96%E0%BA%BB%E0%BA%A1%E0%BA%97%E0%BA%B1%E0%BA%A1(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlSodabun =
      "https://buddhaword.siteoly.com/%E0%BA%84%E0%BA%B9%E0%BB%88%E0%BA%A1%E0%BA%B7%E0%BB%82%E0%BA%AA%E0%BA%94%E0%BA%B2%E0%BA%9A%E0%BA%B1%E0%BA%99(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlBuddhawajana =
      "https://buddhaword.siteoly.com/%E0%BA%9E%E0%BA%B8%E0%BA%94%E0%BA%97%E0%BA%B0%E0%BA%A7%E0%BA%B0%E0%BA%88%E0%BA%B0%E0%BA%99%E0%BA%B0(%E0%BB%82%E0%BA%94%E0%BA%8D%E0%BA%9E%E0%BA%B2%E0%BA%9A%E0%BA%A5%E0%BA%A7%E0%BA%A1)(%E0%BA%9B%E0%BA%B7%E0%BB%89%E0%BA%A1)";
  final String urlKaekam =
      "https://buddhaword.siteoly.com/%E0%BB%81%E0%BA%81%E0%BB%89%E0%BA%81%E0%BA%B1%E0%BA%A1(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlStiputarn_4 =
      "https://buddhaword.siteoly.com/%E0%BA%AA%E0%BA%B0%E0%BA%95%E0%BA%B4%E0%BA%9B%E0%BA%B1%E0%BA%95%E0%BA%96%E0%BA%B2%E0%BA%99(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlRnapa =
      "https://buddhaword.siteoly.com/%E0%BA%AD%E0%BA%B2%E0%BA%99%E0%BA%B2%E0%BA%9B%E0%BA%B2%E0%BA%99%E0%BA%B0%E0%BA%AA%E0%BA%B0%E0%BA%95%E0%BA%B4(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlKorpatibutngaiy =
      "https://buddhaword.siteoly.com/%E0%BA%82%E0%BB%8D%E0%BB%89%E0%BA%9B%E0%BA%B0%E0%BA%95%E0%BA%B4%E0%BA%9A%E0%BA%B1%E0%BA%94%E0%BA%A7%E0%BA%B4%E2%80%8B%E0%BA%97%E0%BA%B5%E2%80%8B%E0%BA%97%E0%BA%B5%E0%BB%88%E2%80%8B%E0%BA%87%E0%BB%88%E0%BA%B2%E0%BA%8D%E2%80%8B(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlInseesungvone =
      "https://buddhaword.siteoly.com/%E0%BA%AD%E0%BA%B4%E0%BA%99%E0%BA%8A%E0%BA%B5%E0%BA%AA%E0%BA%B1%E0%BA%87%E0%BA%A7%E0%BA%AD%E0%BA%99%E2%80%8B(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlTarmhoytham =
      "https://buddhaword.siteoly.com/%E0%BA%95%E0%BA%B2%E0%BA%A1%E0%BA%AE%E0%BA%AD%E0%BA%8D%E0%BA%97%E0%BA%B1%E0%BA%A1%E2%80%8B(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlKaoyangyabuddha =
      "https://buddhaword.siteoly.com/%E0%BA%81%E0%BB%89%E0%BA%B2%E0%BA%A7%E0%BA%8D%E0%BB%88%E0%BA%B2%E0%BA%87%E0%BA%A2%E0%BB%88%E0%BA%B2%E0%BA%87%E0%BA%9E%E0%BA%B8%E0%BA%94%E0%BA%97%E0%BA%B0(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlTatarkod =
      "https://buddhaword.siteoly.com/%E0%BA%95%E0%BA%B2%E0%BA%96%E0%BA%B2%E0%BA%84%E0%BA%BB%E0%BA%94(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlSmataviputsna =
      "https://buddhaword.siteoly.com/%E0%BA%9B%E0%BA%B0%E0%BA%95%E0%BA%B4%E0%BA%9A%E0%BA%B1%E0%BA%94%E0%BA%AA%E0%BA%B0%E0%BA%A1%E0%BA%B2%E0%BA%97%E0%BA%B0&%E0%BA%A7%E0%BA%B4%E0%BA%9B%E0%BA%B1%E0%BA%94%E0%BA%8A%E0%BA%B0%E0%BA%99%E0%BA%B2(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlpobpoum =
      "https://buddhaword.siteoly.com/%E0%BA%9E%E0%BA%BB%E0%BA%9A%E0%BA%9E%E0%BA%B9%E0%BA%A1(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urldaylasarnvisa =
      "https://buddhaword.siteoly.com/%E0%BB%80%E0%BA%94%E0%BA%8D%E0%BA%A5%E0%BA%B0%E0%BA%AA%E0%BA%B2%E0%BA%99%E0%BA%A7%E0%BA%B4%E0%BA%8A%E0%BA%B2(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlskatakarmi =
      "https://buddhaword.siteoly.com/%E0%BA%AA%E0%BA%B0%E0%BA%81%E0%BA%B0%E0%BA%97%E0%BA%B2%E0%BA%84%E0%BA%B2%E0%BA%A1%E0%BA%B5(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urljitmanovinyarn =
      "https://buddhaword.siteoly.com/%E0%BA%88%E0%BA%B4%E0%BA%94%20%E0%BA%A1%E0%BA%B0%E0%BB%82%E0%BA%99%20%E0%BA%A7%E0%BA%B4%E0%BA%99%E0%BA%8D%E0%BA%B2%E0%BA%99(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlzut =
      "https://buddhaword.siteoly.com/%E0%BA%AA%E0%BA%B1%E0%BA%94(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlRnakarmi =
      "https://buddhaword.siteoly.com/%E0%BA%AD%E0%BA%B0%E0%BA%99%E0%BA%B2%E0%BA%84%E0%BA%B2%E0%BA%A1%E0%BA%B5(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlSangyort =
      "https://buddhaword.siteoly.com/%E0%BA%AA%E0%BA%B1%E0%BA%87%E0%BB%82%E0%BA%A2%E0%BA%94(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlpartton =
      "https://buddhaword.siteoly.com/%E0%BA%AD%E0%BA%B0%E0%BA%A3%E0%BA%B4%E0%BA%8D%E0%BA%B0%E0%BA%AA%E0%BA%B1%E0%BA%94%E0%BA%88%E0%BA%B2%E0%BA%81%E0%BA%9E%E0%BA%A3%E0%BA%B0%E0%BB%82%E0%BA%AD%E0%BA%94%20%E0%BA%9E%E0%BA%B2%E0%BA%81%E0%BA%95%E0%BA%BB%E0%BB%89%E0%BA%99(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlpartpaiy =
      "https://buddhaword.siteoly.com/%E0%BA%AD%E0%BA%B0%E0%BA%A3%E0%BA%B4%E0%BA%8D%E0%BA%B0%E0%BA%AA%E0%BA%B1%E0%BA%94%E0%BA%88%E0%BA%B2%E0%BA%81%E0%BA%9E%E0%BA%A3%E0%BA%B0%E0%BB%82%E0%BA%AD%E0%BA%94%20%E0%BA%9E%E0%BA%B2%E0%BA%81%E0%BA%9B%E0%BA%B2%E0%BA%8D(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlphutapawat =
      "https://buddhaword.siteoly.com/%E0%BA%9E%E0%BA%B8%E0%BA%94%E0%BA%97%E0%BA%B0%E0%BA%9B%E0%BA%B0%E0%BA%AB%E0%BA%A7%E0%BA%B1%E0%BA%94%E0%BA%88%E0%BA%B2%E0%BA%81%E0%BA%9E%E0%BA%A3%E0%BA%B0%E0%BB%82%E0%BA%AD%E0%BA%94(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlpatijasmobard =
      "https://buddhaword.siteoly.com/%E0%BA%9B%E0%BA%B0%E0%BA%95%E0%BA%B4%E0%BA%88%E0%BA%B0%E0%BA%AA%E0%BA%B0%E0%BA%A1%E0%BA%B8%E0%BA%9A%E0%BA%B2%E0%BA%94%E0%BA%88%E0%BA%B2%E0%BA%81%E0%BA%9E%E0%BA%A3%E0%BA%B0%E0%BB%82%E0%BA%AD%E0%BA%94(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlluambunyaiy =
      "https://buddhaword.siteoly.com/%E0%BA%A5%E0%BA%A7%E0%BA%A1%E0%BA%9E%E0%BA%B8%E0%BA%94%E0%BA%97%E0%BA%B0%E0%BA%A7%E0%BA%B0%E0%BA%88%E0%BA%B0%E0%BA%99%E0%BA%B0%E0%BA%9A%E0%BA%B1%E0%BA%99%E0%BA%A5%E0%BA%B0%E0%BA%8D%E0%BA%B2%E0%BA%8D(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urletc =
      "https://buddhaword.siteoly.com/%E0%BA%A5%E0%BA%A7%E0%BA%A1%E0%BA%9E%E0%BA%B8%E0%BA%94%E0%BA%97%E0%BA%B0%E0%BA%A7%E0%BA%B0%E0%BA%88%E0%BA%B0%E0%BA%99%E0%BA%B0%E0%BB%9D%E0%BA%A7%E0%BA%94%E0%BA%AD%E0%BA%B7%E0%BB%88%E0%BA%99%E0%BB%86(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";
  final String urlFAQ =
      "https://buddhaword.siteoly.com/%E0%BA%A5%E0%BA%B2%E0%BA%8D%E0%BA%81%E0%BA%B2%E0%BA%99%20FAQ%20%E0%BA%9E%E0%BA%B8%E0%BA%94%E0%BA%97%E0%BA%B0%E0%BA%A7%E0%BA%B0%E0%BA%88%E0%BA%B0%E0%BA%99%E0%BA%B0%E0%BA%88%E0%BA%B2%E0%BA%81%E0%BA%9E%E0%BA%A3%E0%BA%B0%E0%BB%82%E0%BA%AD%E0%BA%94(%E0%BA%AA%E0%BA%BD%E0%BA%87&%E0%BA%A7%E0%BA%B5%E0%BA%94%E0%BA%B5%E0%BB%82%E0%BA%AD)";

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

  void _openLinkTarn() async {
    if (await canLaunch(urlTarn)) {
      await launch(urlTarn);
    } else {
      throw 'Could not launch $urlTarn';
    }
  }

  void _openPathomtham() async {
    if (await canLaunch(urlPathomtham)) {
      await launch(urlPathomtham);
    } else {
      throw 'Could not launch $urlPathomtham';
    }
  }

  void _openSodabun() async {
    if (await canLaunch(urlSodabun)) {
      await launch(urlSodabun);
    } else {
      throw 'Could not launch $urlSodabun';
    }
  }

  void _openBuddhawajana() async {
    if (await canLaunch(urlBuddhawajana)) {
      await launch(urlBuddhawajana);
    } else {
      throw 'Could not launch $urlBuddhawajana';
    }
  }

  void _openurlKaekam() async {
    if (await canLaunch(urlKaekam)) {
      await launch(urlKaekam);
    } else {
      throw 'Could not launch $urlKaekam';
    }
  }

  void _openurlStiputarn_4() async {
    if (await canLaunch(urlStiputarn_4)) {
      await launch(urlStiputarn_4);
    } else {
      throw 'Could not launch $urlStiputarn_4';
    }
  }

  void _openurlRnapa() async {
    if (await canLaunch(urlRnapa)) {
      await launch(urlRnapa);
    } else {
      throw 'Could not launch $urlRnapa';
    }
  }

  void _openurlKorpatibutngaiy() async {
    if (await canLaunch(urlKorpatibutngaiy)) {
      await launch(urlKorpatibutngaiy);
    } else {
      throw 'Could not launch $urlKorpatibutngaiy';
    }
  }

  void _openurlInseesungvone() async {
    if (await canLaunch(urlInseesungvone)) {
      await launch(urlInseesungvone);
    } else {
      throw 'Could not launch $urlInseesungvone';
    }
  }

  void _openurlTarmhoytham() async {
    if (await canLaunch(urlTarmhoytham)) {
      await launch(urlTarmhoytham);
    } else {
      throw 'Could not launch $urlTarmhoytham';
    }
  }

  void _openurlKaoyangyabuddha() async {
    if (await canLaunch(urlKaoyangyabuddha)) {
      await launch(urlKaoyangyabuddha);
    } else {
      throw 'Could not launch $urlKaoyangyabuddha';
    }
  }

  void _openurlTatarkod() async {
    if (await canLaunch(urlTatarkod)) {
      await launch(urlTatarkod);
    } else {
      throw 'Could not launch $urlTatarkod';
    }
  }

  void _openurlSmataviputsna() async {
    if (await canLaunch(urlSmataviputsna)) {
      await launch(urlSmataviputsna);
    } else {
      throw 'Could not launch $urlSmataviputsna';
    }
  }

  void _openurlpobpoum() async {
    if (await canLaunch(urlpobpoum)) {
      await launch(urlpobpoum);
    } else {
      throw 'Could not launch $urlpobpoum';
    }
  }

  void _openurldaylasarnvisa() async {
    if (await canLaunch(urldaylasarnvisa)) {
      await launch(urldaylasarnvisa);
    } else {
      throw 'Could not launch $urldaylasarnvisa';
    }
  }

  void _openurlskatakarmi() async {
    if (await canLaunch(urlskatakarmi)) {
      await launch(urlskatakarmi);
    } else {
      throw 'Could not launch $urlskatakarmi';
    }
  }

  void _openurljitmanovinyarn() async {
    if (await canLaunch(urljitmanovinyarn)) {
      await launch(urljitmanovinyarn);
    } else {
      throw 'Could not launch $urljitmanovinyarn';
    }
  }

  void _openurlzut() async {
    if (await canLaunch(urlzut)) {
      await launch(urlzut);
    } else {
      throw 'Could not launch $urlzut';
    }
  }

  void _openurlRnakarmi() async {
    if (await canLaunch(urlRnakarmi)) {
      await launch(urlRnakarmi);
    } else {
      throw 'Could not launch $urlRnakarmi';
    }
  }

  void _openurlSangyort() async {
    if (await canLaunch(urlSangyort)) {
      await launch(urlSangyort);
    } else {
      throw 'Could not launch $urlSangyort';
    }
  }

  void _openurlpartton() async {
    if (await canLaunch(urlpartton)) {
      await launch(urlpartton);
    } else {
      throw 'Could not launch $urlpartton';
    }
  }

  void _openurlpartpaiy() async {
    if (await canLaunch(urlpartpaiy)) {
      await launch(urlpartpaiy);
    } else {
      throw 'Could not launch $urlpartpaiy';
    }
  }

  void _openurlphutapawat() async {
    if (await canLaunch(urlphutapawat)) {
      await launch(urlphutapawat);
    } else {
      throw 'Could not launch $urlphutapawat';
    }
  }

  void _openurlpatijasmobard() async {
    if (await canLaunch(urlpatijasmobard)) {
      await launch(urlpatijasmobard);
    } else {
      throw 'Could not launch $urlpatijasmobard';
    }
  }

  void _openurlluambunyaiy() async {
    if (await canLaunch(urlluambunyaiy)) {
      await launch(urlluambunyaiy);
    } else {
      throw 'Could not launch $urlluambunyaiy';
    }
  }

  void _openurletc() async {
    if (await canLaunch(urletc)) {
      await launch(urletc);
    } else {
      throw 'Could not launch $urletc';
    }
  }

  void _openurlFAQ() async {
    if (await canLaunch(urlFAQ)) {
      await launch(urlFAQ);
    } else {
      throw 'Could not launch $urlFAQ';
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
                'ພຣະສູດ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomePage(
                      title: 'ຄຳສອນພຣະພຸດທະເຈົ້າ',
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
                'ປື້ມ & ເເຜນຜັງ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkBooks(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.open_in_browser_rounded, color: _checkColor)
                  : Icon(Icons.open_in_browser_outlined, color: _checkColor),
              title: const Text(
                'ພຣະສູດ Web',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkWebapp(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.filter_vintage, color: _checkColor)
                  : Icon(Icons.sunny, color: _checkColor),
              title: const Text(
                'ພຣະທັມ',
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
                'ປະຕິທິນທັມ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () => _openLinkCalendar(),
            ),
            ListTile(
              leading: _isChecked
                  ? Icon(Icons.video_library, color: _checkColor)
                  : Icon(Icons.video_collection_outlined, color: _checkColor),
              title: const Text(
                'ອະນັດຕາ',
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
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ທານ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openLinkTarn(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ປະຖົມທັມ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openPathomtham(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ຄູ່ມືໂສດາບັນ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openSodabun(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ພຸດທະວະຈະນະ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openBuddhawajana(),
                    ),
                  ],
                ),
                const Divider(
                  color: Color.fromARGB(255, 221, 220, 217),
                  thickness: 1,
                  height: 1,
                ),
                ExpansionTile(
                  title: Text(
                    'ທັມໃນທ່າມກາງ',
                    style: TextStyle(fontSize: 18),
                  ),
                  children: [
                    ListTile(
                      title: Text(
                        'ແກ້ກັມ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlKaekam(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ສະຕິປັຕຖານ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlStiputarn_4(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ອານາປານະສະຕິ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlRnapa(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ຂໍ້ປະຕິບັດວິ​ທີ​ທີ່​ງ່າຍ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlKorpatibutngaiy(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ອິນຊີສັງວອນ​',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlInseesungvone(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ຕາມຮອຍທັມ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlTarmhoytham(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ກ້າວຍ່າງຢ່າງພຸດທະ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlKaoyangyabuddha(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ຕາຖາຄົດ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlTatarkod(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ປະຕິບັດສະມາທະ&ວິປັດຊະນາ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlSmataviputsna(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ພົບພູມ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlpobpoum(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ເດຍລະສານວິຊາ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurldaylasarnvisa(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ສະກະທາຄາມີ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlskatakarmi(),
                    ),
                  ],
                ),
                const Divider(
                  color: Color.fromARGB(255, 221, 220, 217),
                  thickness: 1,
                  height: 1,
                ),
                ExpansionTile(
                  title: Text(
                    'ທັມໃນທີສຸດ',
                    style: TextStyle(fontSize: 18),
                  ),
                  children: [
                    ListTile(
                      title: Text(
                        'ຈິດ ມະໂນ ວິນຍານ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurljitmanovinyarn(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ສັດ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlzut(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ອະນາຄາມີ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlRnakarmi(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ສັງໂຢດ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlSangyort(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກຕົ້ນ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlpartton(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ອະຣິຍະສັດຈາກພຣະໂອດ ພາກປາຍ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlpartpaiy(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ພຸດທະປະຫວັດຈາກພຣະໂອດ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlphutapawat(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ປະຕິຈະສະມຸບາດຈາກພຣະໂອດ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlpatijasmobard(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ລວມພຸດທະວະຈະນະບັນລະຍາຍ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlluambunyaiy(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ລວມພຸດທະວະຈະນະໝວດອື່ນໆ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurletc(),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 221, 220, 217),
                      thickness: 1,
                      height: 1,
                    ),
                    ListTile(
                      title: Text(
                        'ລາຍການ FAQ ພຸດທະວະຈະນະຈາກພຣະໂອດ',
                        style: TextStyle(fontSize: 18),
                      ),
                      onTap: () => _openurlFAQ(),
                    ),
                  ],
                ),
              ],
            ),
            // const Divider(
            //   color: Colors.black54,
            // ),
            // ListTile(
            //   leading: _isChecked
            //       ? Icon(Icons.add, color: _checkColor)
            //       : Icon(Icons.add_outlined, color: _checkColor),
            //   title: const Text(
            //     'ເພີ່ມພຣະສູດ',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            //   ),
            //   onTap: () => Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(
            //       builder: (context) => const SutraList(
            //         title: 'ລາຍການພຣະສູດ',
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
}
