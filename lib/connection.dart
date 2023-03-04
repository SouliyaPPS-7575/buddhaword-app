// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/model/sutra.dart';

const String kSutraCollection = 'sutra';
const String kDataDocument = 'data';

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

    // Convert Hive data to Firestore documents
    final documents = data
        .map((item) => {
              'id': item.id,
              'title': item.title,
              'content': item.content,
              'category': item.category,
            })
        .toList();

    // Sync Firestore with Hive data
    await firestore.runTransaction((transaction) async {
      final docRef = firestore.collection(kSutraCollection).doc(kDataDocument);
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'data': documents});
      } else {
        transaction.update(docRef, {'data': documents});
      }
    });

    // can add map data to firestore
    await firestore.collection('sutra').add({'data': documents});

    // Sync Hive with Firestore data
    box.watch().listen((event) async {
      final List<Sutra> sutraList = box.values.toList();
      final List data = sutraList.map((sutra) => sutra.toJson()).toList();
      try {
        await firestore.runTransaction((transaction) async {
          final docRef =
              firestore.collection(kSutraCollection).doc(kDataDocument);
          final snapshot = await transaction.get(docRef);
          final newData = {'data': data};
          if (!snapshot.exists) {
            transaction.set(docRef, newData);
          } else {
            final currentData = snapshot.data();
            final mergedData = {...?currentData, ...newData};
            transaction.update(docRef, mergedData);
          }
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error syncing data to Firestore: $e');
        }
      }
    });
  } catch (e) {
    if (kDebugMode) {
      print('Error initializing Firebase: $e');
    }
  }
}

// Sync Hive database with Firebase when connected

// Sync Hive database with Firebase when connected to internet
void syncHiveWithFirebase() async {
  if (await checkInternetConnectivity()) {
    initializeFirebase();
  }
}
