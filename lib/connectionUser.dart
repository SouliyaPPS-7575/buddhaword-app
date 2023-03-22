// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:fluttertoast/fluttertoast.dart';

const String kSutraCollection = 'sutra';
const String kDataDocument = 'data';

// Sync Hive database with Firebase when connected to internet
Future<void> syncHiveWithFirebase(BuildContext context) async {
  if (await checkInternetConnectivity(context)) {
    await Firebase.initializeApp();
    // code to sync data with Firebase Firestore
    Fluttertoast.showToast(
      msg: 'Synced data to Firestore successfully!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }
}

// Check for internet connectivity
Future<bool> checkInternetConnectivity(BuildContext context) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  bool isConnected = false;
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    isConnected = true;
  }

  if (!isConnected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text(
              'Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
  return isConnected;
}

// Initialize Firebase and sync Firestore with Hive data
Future<void> initializeFirebase() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Set up Firebase database
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);

    // Set up Firestore database
    final firestore = FirebaseFirestore.instance;

    // Sync Firestore with Hive data
    final docRef = firestore.collection(kSutraCollection).doc(kDataDocument);

    docRef.snapshots().listen((docSnapshot) async {
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        final documents = data?['data'];

        // Open Hive box and clear all data
        final box = await Hive.openBox<Sutra>('sutra');
        await box.clear();

        // Convert Firestore documents to Hive data and store in Hive
        for (final doc in documents) {
          final sutra = Sutra(
            id: doc['id'],
            title: doc['title'],
            content: doc['content'],
            category: doc['category'],
          );
          await box.put(doc['id'], sutra);
        }
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }
}
