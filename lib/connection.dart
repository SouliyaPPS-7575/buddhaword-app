// ignore_for_file: avoid_function_literals_in_foreach_calls, deprecated_member_use, avoid_print
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/model/sutra.dart';

// Check for internet connectivity
Future<bool> checkInternetConnectivity() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    return true;
  } else {
    return false;
  }
}

void initializeFirebase() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up Firebase database
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000);

  // Set up Firestore database
  final firestore = FirebaseFirestore.instance;

  final box = await Hive.openBox<Sutra>('sutra');

  box.watch().listen((event) async {
    final List<Sutra> sutraList = box.values.toList();
    final List data = sutraList.map((sutra) => sutra.toJson()).toList();

    try {
      await firestore.collection('sutra').doc('data').set({'data': data});
    } catch (e) {
      print('Error syncing data to Firestore: $e');
    }
  });
}

// Sync Hive database with Firebase when connected to internet
void syncHiveWithFirebase() async {
  if (await checkInternetConnectivity()) {
    initializeFirebase();
  }
}
