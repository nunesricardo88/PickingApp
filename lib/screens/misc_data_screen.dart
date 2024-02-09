import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/models/misc_data_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class MiscDataScreen extends StatefulWidget {
  final List<MiscData> miscDataList;
  const MiscDataScreen({
    required this.miscDataList,
  });

  @override
  _MiscDataScreenState createState() => _MiscDataScreenState();
}

class _MiscDataScreenState extends State<MiscDataScreen> {
  bool canSave = false;
  final List<TextEditingController> _textEditingControllerList = [];

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() {
    for (final MiscData miscData in widget.miscDataList) {
      final TextEditingController textEditingController =
          TextEditingController();
      textEditingController.text = miscData.value;
      _textEditingControllerList.add(textEditingController);
    }
  }

  Widget buildTextField(int index) {
    final MiscData item = widget.miscDataList[index];
    final InputDecoration inputDecoration = InputDecoration(
      labelText: item.name,
      labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: kPrimaryColor,
          ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: kPrimaryColor,
          width: 2.0,
        ),
      ),
    );

    TextInputType textInputType;

    switch (item.type) {
      case 'String':
        textInputType = TextInputType.text;
        break;
      case 'Int':
        textInputType = TextInputType.number;
        break;
      case 'Double':
        textInputType = TextInputType.number;
        break;
      case 'Datetime':
        textInputType = TextInputType.datetime;
        break;
      default:
        textInputType = TextInputType.text;
        break;
    }

    if (item.isMandatory != null && item.isMandatory!) {
      return TextField(
        controller: _textEditingControllerList[index],
        keyboardType: textInputType,
        decoration: inputDecoration.copyWith(
          errorText: widget.miscDataList[index].value.isEmpty
              ? 'Campo obrigatório'
              : null,
        ),
        onChanged: (value) {
          setState(() {
            widget.miscDataList[index].value = value;
          });
        },
      );
    } else {
      return TextField(
        controller: _textEditingControllerList[index],
        keyboardType: textInputType,
        decoration: inputDecoration,
        onChanged: (value) {
          setState(() {
            widget.miscDataList[index].value = value;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    for (final TextEditingController textEditingController
        in _textEditingControllerList) {
      textEditingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kGreyBackground,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.angleLeft,
              color: kPrimaryColorLight,
            ),
          ),
        ),
        title: Text(
          'Formulário',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: kPrimaryColorLight,
                fontWeight: FontWeight.w500,
              ),
        ),
        titleSpacing: 0.0,
        elevation: 10,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outros dados',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: kPrimaryColor,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    'Preencha os dados do formulário abaixo',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.miscDataList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                      bottom: 5.0,
                    ),
                    child: buildTextField(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          canSave = true;
          for (int i = 0; i < widget.miscDataList.length; i++) {
            final MiscData miscData = widget.miscDataList[i];
            final String valueString = _textEditingControllerList[i].text;
            miscData.value = valueString;
            switch (miscData.type) {
              case 'String':
                if (miscData.isMandatory != null &&
                    miscData.isMandatory! &&
                    valueString.isEmpty) {
                  canSave = false;
                } else {
                  miscData.valueString = valueString;
                }
                break;
              case 'Int':
                miscData.valueInt = int.tryParse(valueString);
                break;
              case 'Double':
                miscData.valueDouble = double.tryParse(valueString);
                break;
              case 'Datetime':
                miscData.valueDatetime = DateTime.tryParse(valueString);
                break;
              default:
                miscData.valueString = valueString;
                break;
            }
          }
          if (canSave) {
            Navigator.pop(context, widget.miscDataList);
          }
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.check,
          color: kPrimaryColorLight,
        ),
      ),
    );
  }
}
