// ignore_for_file: file_names
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/model/sutra.dart';

const String kSutraCollection = 'sutra';
const String kDataDocument = 'data';


// Sync Hive database with Firebase when connected to internet
Future<void> syncHiveWithFirebase() async {
  if (await checkInternetConnectivity()) {
    initializeFirebase();
  }
}

// Check for internet connectivity
Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  return connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi;
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

    // Open Hive box and retrieve data
    final box = await Hive.openBox<Sutra>('sutra');
    final data = box.values.toList();

    final documents = data
        .map((item) => {
              'id': FirebaseFirestore.instance
                  .collection(kSutraCollection)
                  .doc()
                  .id,
              'title': item.title,
              'content': item.content,
              'category': item.category,
            })
        .toList();

    final docRef = firestore.collection(kSutraCollection).doc(kDataDocument);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await docRef.set({'data': documents});
    } else {
      await docRef.update({'data': documents});
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }
}
