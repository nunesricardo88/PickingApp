import 'package:flutter/material.dart';

//Colors
const kPrimaryColor = Color.fromRGBO(96, 125, 139, 1);
const kPrimaryColorDark = Color.fromRGBO(69, 90, 100, 1);
const kPrimaryColorLight = Color.fromRGBO(207, 216, 220, 1);
const kIconColor = Color.fromRGBO(250, 250, 250, 1);
const kAccentColor = Color.fromRGBO(0, 150, 136, 1);
const kPrimaryTextColor = Color.fromRGBO(33, 33, 33, 1);
const kSecondaryTextColor = Color.fromRGBO(117, 117, 117, 1);
const kDividerColor = Color.fromRGBO(189, 189, 189, 1);
const kErrorColor = Color.fromRGBO(244, 67, 54, 1);
const kAlertDialogColor = Color.fromRGBO(250, 250, 250, 1);

//Enums
enum License {
  nenhuma,
  rialto,
  rrmp,
  greenkinetics,
}

enum PickingTaskType {
  nenhuma,
  expedicao,
  rececao,
  producao,
  consumo,
  transferencia,
  devolucao,
  inventario,
  outros,
}

enum EntityType {
  cliente,
  fornecedor,
  interno,
}

enum BarCodeType {
  ean8,
  upcA,
  ean13,
  itf14,
  dossier,
  gs1,
  sscc,
  ref,
  location,
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

//TextStyles
const kAppBarTextStyle = TextStyle(
  fontFamily: 'Roboto',
  color: kPrimaryColorLight,
);

const kButtonTextStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 16.0,
  fontWeight: FontWeight.w400,
);

const kContentLabelTextStyleSemiBold = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 18.0,
  fontWeight: FontWeight.w500,
  color: kPrimaryColorDark,
);

const kContentLabel2TextStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
  color: kPrimaryColorDark,
);

const kContentTextStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 18.0,
  fontWeight: FontWeight.normal,
  color: kPrimaryColorDark,
);

const kTileText = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 16.0,
  fontWeight: FontWeight.normal,
  color: kPrimaryTextColor,
);

const kTileFieldTitle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 16.0,
  fontWeight: FontWeight.w500,
  color: kPrimaryColor,
);

const kTileFieldLabel = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  color: kSecondaryTextColor,
);

const kTileFieldContent = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
  color: kPrimaryTextColor,
);

//Input Decorations
const kSearchFieldInputDecoration = InputDecoration(
  labelText: 'Procurar...',
  labelStyle: TextStyle(
    color: kPrimaryColorDark,
  ),
  alignLabelWithHint: true,
  border: UnderlineInputBorder(),
  focusedBorder: UnderlineInputBorder(),
);

BoxDecoration get pinPutDecoration {
  return BoxDecoration(
    color: kIconColor,
    borderRadius: BorderRadius.circular(30.0),
    boxShadow: [
      BoxShadow(
        offset: const Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: kPrimaryColor.withOpacity(0.5),
      ),
    ],
  );
}
