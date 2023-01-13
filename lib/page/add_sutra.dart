// ignore_for_file: avoid_print
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive/hive.dart';
import 'package:lao_tipitaka/main.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/sutraL_list.dart';

class AddSutraList extends StatefulWidget {
  const AddSutraList({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<AddSutraList> createState() => _AddSutraListState();
}

class _AddSutraListState extends State<AddSutraList>
    with TickerProviderStateMixin {
  String? category;
  String? content;
  int id = 0;
  late Box<Sutra> sutraBox;
  String? title;

  final _formkey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    sutraBox = Hive.box<Sutra>("sutra");
  }

// Create
  void saveSutra() {
    final isValid = _formkey.currentState?.validate();

    if (isValid != null && isValid) {
      _formkey.currentState?.save();
      sutraBox.add(
        Sutra(
          id: id,
          title: title.toString(),
          content: content.toString(),
          category: category.toString(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
          parent: AnimationController(
            vsync: this,
            duration: const Duration(seconds: 1),
          )..forward(),
          curve: Curves.fastOutSlowIn,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ເພີ່ມພຣະສູດ'),
          backgroundColor: const Color.fromARGB(255, 175, 93, 78),
        ),
        drawer: const NavigationDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FormBuilder(
                key: _formkey,
                onChanged: () => print("Form has been changed"),
                // ignore: prefer_const_literals_to_create_immutables
                initialValue: {
                  'number': "${Random().nextInt(100)}",
                },
                skipDisabled: true,
                child: Column(
                  children: <Widget>[
                    Visibility(
                      visible: false,
                      child: FormBuilderTextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'ລະຫັດ',
                          helperText: 'ໃສ່ລະຫັດ',
                        ),
                        onSaved: (value) {
                          id = int.parse(value.toString());
                        },
                        name: 'number',
                        enabled: false,
                      ),
                    ),
                    FormBuilderTextField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'ຊື່ພຣະສູດ',
                        helperText: 'ໃສ່ຊື່ພຣະສູດ',
                      ),
                      onSaved: (value) {
                        title = value.toString();
                      },
                      name: 'textfield',
                      enabled: true,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (val) {
                        if (val == null || val == "") {
                          return 'ກະລຸນາໃສ່ຊື່ພຣະສູດ';
                        }
                        return null;
                      },
                    ),
                    FormBuilderTextField(
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: 'ພຣະສູດ',
                        helperText: 'ໃສ່ພຣະສູດ',
                      ),
                      onSaved: (value) {
                        content = value.toString();
                      },
                      name: 'textfield',
                      enabled: true,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (val) {
                        if (val == null || val == "") {
                          return 'ກະລຸນາໃສ່ພຣະສູດ';
                        }
                        return null;
                      },
                    ),
                    FormBuilderTextField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'ໝວດທັມ',
                        helperText: 'ໃສ່ໝວດທັມ',
                      ),
                      onSaved: (value) {
                        category = value.toString();
                      },
                      name: 'textfield',
                      enabled: true,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (val) {
                        if (val == null || val == "") {
                          return 'ກະລຸນາໃສ່ໝວດທັມ';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final valid = (_formkey.currentState?.validate() ?? false);
            if (!valid) {
              showDialog(
                  context: context,
                  builder: (context) => const SimpleDialog(
                        contentPadding: EdgeInsets.all(20),
                        title: Text('ກະລຸນາກວດສອບຂໍ້ມູນ'),
                        children: [
                          Text('ກະລຸນາກວດສອບຂໍ້ມູນທີ່ທ່ານປ້ອນຄືນກ່ອນການບັນທຶກ')
                        ],
                      ));
            } else {
              saveSutra();
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  content: Text("ສຳເລັດ"),
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SutraList(title: "ລາຍການພຣະສູດ");
                  },
                ),
              );
            }
          },
          label: const Text('ບັນທຶກ'),
          icon: const Icon(Icons.save),
        ),
      ),
    );
  }
}
