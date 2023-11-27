import 'package:flutter/material.dart';

//Colors
const kPrimaryColor = Color(0xFF607D8B);
const kPrimaryColorLight = Color(0xFFCFD8DC);
const kIcons = Color(0xFFFAFAFA);
const kPrimaryColorDark = Color(0xFF455A64);
const kPrimaryTextColor = Color(0xFF212121);
const kSecondaryTextColor = Color(0xFF757575);
const kDividerColor = Color(0xFFA5A5A5);
const kTileBackground = Color(0xBBCFD8DC);
const kAccentColor = Color(0xFF455A64);
const kErrorColor = Color(0xFFDE5246);
const kGreenColor = Color(0xFF28F290);
const kYellowColor = Color(0xFFFFE371);
const kRedColor = Color(0xFFFFB5B5);
const kDefaultAccentColor = Color(0xFF1D7FCD);
const kAlternativeAccentColor = Color(0xFF1DBB76);

enum PickingTask {
  nenhuma,
  expedir,
  preparar,
  receber,
  produzir,
  anularProducao,
  consumirMP,
  devolverMP,
  inventario,
  palete,
  devolverFornecedor,
  devolverCliente,
  transferenciaArmazem,
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
    color: kIcons,
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
