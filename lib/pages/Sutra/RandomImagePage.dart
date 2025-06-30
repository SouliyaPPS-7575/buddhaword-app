// ignore_for_file: file_names, prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';

import '../../main.dart';

class RandomImagePage extends StatelessWidget {
  // Generate a random key for each instance to ensure it rebuilds
  final Key randomKey = ValueKey(Random().nextInt(10000));

  RandomImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double screenHeight = constraints.maxHeight;

            // Determine if the device is a desktop
            bool isDesktop =
                screenWidth >= 1024; // Adjust this breakpoint as needed

            // Lists of image paths for each device type
            List<String> desktopImages = [
              'assets/ເຫັນທຳ/loading_desktop_tablet.jpg',
            ];

            List<String> tabletImages = [
              'assets/ເຫັນທຳ/loading_mobile.jpg',
            ];

            List<String> mobileImages = [
              'assets/ເຫັນທຳ/loading_mobile.jpg',
            ];

            // Select the list of images based on the screen size
            List<String> selectedImages;
            if (isDesktop) {
              selectedImages = desktopImages;
            } else if (screenWidth >= 600 || screenHeight <= 1366) {
              selectedImages = tabletImages;
            } else {
              selectedImages = mobileImages;
            }

            // Choose a random image from the selected list
            String imagePath =
                selectedImages[Random().nextInt(selectedImages.length)];

            // Set image size to match screen dimensions
            double imageWidth = screenWidth;
            double imageHeight = screenHeight;

            return Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: imageWidth,
                  height: imageHeight,
                  fit: BoxFit
                      .cover, // Ensures the image covers the entire screen
                ),
                Positioned(
                  bottom: 50, // Position the button at the bottom center
                  left: screenWidth / 2 - 135,
                    child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(
                        title: 'ພຣະສູດ & ສຽງ',
                        ),
                      ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      foregroundColor: Colors.white, // Set text color to white
                    ),
                    child: Center(
                      child: Text(
                      'Skip Offline Mode (ໃຊ້ໂໝດອ໋ອບໄລນ໌)',
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.5,
                        color: Colors.white, // Ensure text is white
                      ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
