import 'package:hive/hive.dart';

part 'sutra.g.dart';

@HiveType(typeId: 0)
class Sutra extends HiveObject {
  @HiveField(0, defaultValue: 0)
  final int id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String content;
  @HiveField(3)
  final String category;
  Sutra(
      {required this.id,
      required this.title,
      required this.content,
      required this.category});

  toJson() {}
}
