// ignore_for_file: deprecated_member_use, use_key_in_widget_constructors, file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'NavigationDrawer.dart';
import 'main.dart';
import 'package:flutter/services.dart';

class ContactInfoPage extends StatelessWidget {
  const ContactInfoPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ຂໍ້​ມູນ​ຕິດ​ຕໍ່'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Changed alignment
            children: [
              const SizedBox(height: 20),
              const Text(
                'ແອັບນີ້ແມ່ນແອັບຄຳສອນພຣະພຸດທະເຈົ້າ, ສ້າງຂື້ນເພື່ອເຜີຍແຜ່ໃຫ້ພວກເຮົາທັງຫຼາຍໄດ້ສຶກສາ ແລະ ປະຕິບັດຕາມ, ດັ່ງທີ່ພຣະຕະຖາຄົດກ່າວວ່າ "ທຳມະຍິ່ງເປີດເຜີຍຍິ່ງຮຸ່ງເຮືອງ" ເມື່ອໄດ້ສຶກສາ ແລະ ປະຕິບັດຕາມ ຈົນເຫັນທຳມະຊາດຕາມຄວາມເປັນຈິງ ກໍຈະຫຼຸດພົ້ນຈາກຄວາມທຸກທັງປວງ. "ທຳກໍດີ ວິໄນກໍດີ ທີ່ເຮົາສະແດງແລ້ວ ບັນຍັດໄວ້ດີແລ້ວ ທຳ ແລະ ວິໄນນັ້ນ ຈະເປັນສາດສະດາແທນຕໍ່ໄປ"',
                style: TextStyle(
                  fontSize: 20, // Adjusted font size
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ຕິດ​ຕໍ່​ພວກ​ເຮົາ',
                style: TextStyle(
                  fontSize: 30, // Increased font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.brown),
                    onPressed: () async {
                      await launchWhatsApp('+8562078287509');
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: '+8562078287509'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone number copied to clipboard'),
                        ),
                      );
                    },
                    child: const Text(
                      '+8562078287509',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.brown),
                    onPressed: () async {
                      await launchWhatsApp('+8562077801610');
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: '+8562077801610'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phone number copied to clipboard'),
                        ),
                      );
                    },
                    child: const Text(
                      '+8562077801610',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.email, color: Colors.brown),
                    onPressed: () async {
                      await launchEmail('souliyappsdev@gmail.com');
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: 'souliyappsdev@gmail.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                        ),
                      );
                    },
                    child: const Text(
                      'souliyappsdev@gmail.com',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.email, color: Colors.brown),
                    onPressed: () async {
                      await launchEmail('Katiya921@gmail.com');
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          const ClipboardData(text: 'Katiya921@gmail.com'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied to clipboard'),
                        ),
                      );
                    },
                    child: const Text(
                      'Katiya921@gmail.com',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Follow Us',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centered follow icons
                children: [
                  GestureDetector(
                    onTap: () {
                      _launchFacebookURL();
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.facebook, color: Colors.blue),
                        SizedBox(width: 10),
                        Text(
                          'Facebook',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors
                                  .blue), // Increased font size and changed color
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _launchFacebookURL() async {
  const url = 'https://www.facebook.com/profile.php?id=100077638042542';
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false, forceWebView: false);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launchWhatsApp(String phoneNumber) async {
  String url = "https://wa.me/$phoneNumber";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

Future<void> launchEmail(String email) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: email,
  );
  if (await canLaunch(emailLaunchUri.toString())) {
    await launch(emailLaunchUri.toString());
  } else {
    throw 'Could not launch email';
  }
}
