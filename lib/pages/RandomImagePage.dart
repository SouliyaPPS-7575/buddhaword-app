// ignore_for_file: file_names

import 'dart:math';

import 'package:flutter/material.dart';

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
              'assets/ພິຈາລະນາທາງປັນຍາ/loading_desktop.png',
              'assets/ເຫັນທຳ/loading_desktop_tablet.jpg',
            ];

            List<String> tabletImages = [
              'assets/ພິຈາລະນາທາງປັນຍາ/loading_tablet.png',
              'assets/ເຫັນທຳ/loading_mobile.jpg',
            ];

            List<String> mobileImages = [
              'assets/ພິຈາລະນາທາງປັນຍາ/loading_mobile.png',
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

            return Image.asset(
              imagePath,
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            );
          },
        ),
      ),
    );
  }
}
