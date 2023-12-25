// ignore_for_file: avoid_print, unnecessary_string_interpolations, unused_local_variable
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lao_tipitaka/connectionUser.dart';
import 'package:lao_tipitaka/model/sutra.dart';
import 'package:lao_tipitaka/page/sutraL_list.dart';
import 'package:html_editor_enhanced/html_editor.dart';

import '../main.dart';

class EditSutraList extends StatefulWidget {
  const EditSutraList(
      {Key? key,
      required this.index,
      required this.id,
      required this.title,
      required this.content,
      required this.category,
      required this.audio})
      : super(key: key);
  final int index;
  final String id;
  final String title;
  final String content;
  final String category;
  final String audio;

  @override
  State<EditSutraList> createState() => _EditSutraListState();
}

class _EditSutraListState extends State<EditSutraList>
    with TickerProviderStateMixin {
  String? category;
  String? content;
  String? audio;
  late String id =
      FirebaseFirestore.instance.collection(kSutraCollection).doc().id;
  late Box<Sutra> sutraBox;
  String? title;

  final _formkey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    _idController.text = widget.id;
    _titleController.text = widget.title;
    _audioController.text = widget.audio;
    _contentController.text = widget.content;
    _categoryController.text = widget.category;

    super.initState();
    sutraBox = Hive.box<Sutra>("sutra");
    Hive.openBox('settings');
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

// Create
  void saveSutra() {
    final isValid = _formkey.currentState?.validate();

    if (isValid != null && isValid) {
      _formkey.currentState?.save();
      sutraBox.add(
        Sutra(
          id: id.toString(),
          title: title.toString(),
          audio: audio.toString(),
          content: content.toString(),
          category: category.toString(),
        ),
      );
    }
  }

  void editSutra() {
    final isValid = _formkey.currentState?.validate();

    final value = Sutra(
      id: _idController.text,
      title: _titleController.text,
      audio: _audioController.text,
      content: _contentController.text,
      category: _categoryController.text,
    );

    Hive.box<Sutra>('sutra').putAt(widget.index, value);
  }

  final HtmlEditorController controller = HtmlEditorController();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _audioController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ເເກ້ໄຂພຣະສູດ'),
        backgroundColor: const Color.fromARGB(241, 179, 93, 78),
        actions: [
          ValueListenableBuilder(
            valueListenable: Hive.box('settings').listenable(),
            builder: (context, box, child) {
              final isDark = box.get('isDark', defaultValue: false);
              return Switch(
                activeColor: Colors.black87,
                activeTrackColor: Colors.black87,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white,
                value: isDark,
                onChanged: (val) {
                  box.put('isDark', val);
                },
              );
            },
          ),
        ],
      ),
      drawer: const NavigationDrawer(),
      body: SingleChildScrollView(
        child: InteractiveViewer(
          maxScale: 4.0,
          minScale: 0.5,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: FormBuilder(
                  key: _formkey,
                  onChanged: () => print("Form has been changed"),
                  skipDisabled: true,
                  child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: false,
                        child: FormBuilderTextField(
                          controller: _idController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ລະຫັດ',
                            helperText: 'ໃສ່ລະຫັດ',
                          ),
                          onSaved: (value) {
                            id = value.toString();
                          },
                          name: 'number',
                          enabled: false,
                        ),
                      ),
                      FormBuilderTextField(
                        controller: _titleController,
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
                      // FormBuilderDropdown(
                      //   // controller: _categoryController,
                      //   decoration: const InputDecoration(
                      //     labelText: 'ໝວດທັມ',
                      //     helperText: 'ໃສ່ໝວດທັມ',
                      //   ),
                      //   name: "dropdown",
                      //   onSaved: (value) {
                      //     category = value.toString();
                      //   },
                      //   autovalidateMode: AutovalidateMode.always,
                      //   enabled: true,
                      //   validator: (val) {
                      //     if (val == null || val == "") {
                      //       return 'ກະລຸນາໃສ່ໝວດທັມ';
                      //     }
                      //     return null;
                      //   },
                      //   items:
                      //       ['ທັມໃນເບື້ອງຕົ້ນ', 'ທັມໃນທ່າມກາງ', 'ທັມໃນທີສຸດ']
                      //           .map((category) => DropdownMenuItem(
                      //                 value: category,
                      //                 child: Text('$category'),
                      //               ))
                      //           .toList(),
                      // ),
                      FormBuilderTextField(
                        controller: _categoryController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          labelText: 'ໝວດທັມ',
                          helperText: 'ໃສ່ໝວດທັມ',
                        ),
                        name: "textfield",
                        onSaved: (value) {
                          category = value.toString();
                        },
                        autovalidateMode: AutovalidateMode.always,
                        enabled: true,
                        validator: (val) {
                          if (val == null || val == "") {
                            return 'ກະລຸນາໃສ່ໝວດທັມ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              child: FormBuilderTextField(
                                controller: _contentController,
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  height: 2.0,
                                ),
                                keyboardType: TextInputType.multiline,
                                decoration: const InputDecoration(
                                  labelText: 'ພຣະສູດ',
                                  helperText: 'ໃສ່ພຣະສູດ',
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 9, // <-- SEE HERE
                                minLines: 4, // <-- SEE HERE
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
                            ),
                          ],
                        ),
                      ),
                      // SingleChildScrollView(
                      //   child: Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: <Widget>[
                      //       HtmlEditor(
                      //         controller: controller,
                      //         htmlEditorOptions: const HtmlEditorOptions(
                      //           hint: 'ໃສ່ພຣະສູດ...',
                      //           shouldEnsureVisible: true,
                      //         ),
                      //         otherOptions: const OtherOptions(
                      //           height: 400,
                      //         ),
                      //         htmlToolbarOptions: const HtmlToolbarOptions(
                      //           toolbarPosition:
                      //               ToolbarPosition.aboveEditor, //by default
                      //           toolbarType:
                      //               ToolbarType.nativeScrollable, //by default
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              FloatingActionButton.extended(
                heroTag: 'fab1',
                onPressed: () {
                  final valid = (_formkey.currentState?.validate() ?? false);
                  if (!valid) {
                    showDialog(
                        context: context,
                        builder: (context) => const SimpleDialog(
                              contentPadding: EdgeInsets.all(20),
                              title: Text('ກະລຸນາກວດສອບຂໍ້ມູນ'),
                              children: [
                                Text(
                                    'ກະລຸນາກວດສອບຂໍ້ມູນທີ່ທ່ານປ້ອນຄືນກ່ອນການບັນທຶກ')
                              ],
                            ));
                  } else {
                    editSutra();

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
                backgroundColor: const Color.fromARGB(241, 179, 93, 78),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
