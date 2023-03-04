import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:path_provider/path_provider.dart' as path;

class MongoDatabase {
  static connect() async {
    // Initialize Hive
    final dir = await path.getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.initFlutter('hive_db');
    Hive.registerAdapter<Sutra>(SutraAdapter());

    // Initialize MongoDB Cloud
    final db = await Db.create(
        'mongodb+srv://Admin:Admin123@cluster0.kvjswr6.mongodb.net/sutra?retryWrites=true&w=majority');
    await db.open();
    final collection = db.collection('sutra');
    inspect(db);
    var status = await db.serverStatus();
    if (kDebugMode) {
      print(status);
    }
    if (kDebugMode) {
      print(await collection.find().toList());
    }

    syncHiveToMongo(collection);
    syncMongoToHive(collection);
  }
}

// Sync data from Hive to MongoDB Cloud
Future<void> syncHiveToMongo(DbCollection collection) async {
  final box = Hive.box<Sutra>("sutra");
  for (int i = 0; i < box.length; i++) {
    final key = box.keyAt(i);
    final value = box.get(key);
    final document = {'_id': key, 'value': value};
    await collection.update({'_id': key}, document, upsert: true);
  }
}

// Sync data from MongoDB Cloud to Hive
Future<void> syncMongoToHive(DbCollection collection) async {
  final box = Hive.box<Sutra>("sutra");
  final documents = await collection.find().toList();
  for (final document in documents) {
    final key = document['_id'];
    final value = document['value'];
    await box.put(key, value);
  }
}
