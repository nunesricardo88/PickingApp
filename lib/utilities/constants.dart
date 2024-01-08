import 'package:flutter/material.dart';

//Enums
enum License {
  nenhuma,
  rialto,
  rrmp,
  greenkinetics,
}

enum StockMovement {
  none,
  outbound,
  inbound,
  transfer,
  inventory,
}

enum EntityType {
  cliente,
  fornecedor,
  interno,
}

enum BarCodeType {
  unknown,
  product,
  batch,
  container,
  location,
  document,
}

enum ErrorCode {
  none,
  quantityBelowZero,
  quantityAboveMax,
  insuficientStock,
  invalidBarcode,
  barcodeNotFound,
  documentNotFound,
  documentNotSuitable,
  locationNotFound,
  errorSavingDocument,
  productNotFound,
  batchNotFound,
  insufficientDataSubmitted,
  unknownError,
}

//Colors
const kPrimaryColor = Color.fromRGBO(96, 125, 139, 1);
const kPrimaryColorDark = Color.fromRGBO(69, 90, 100, 1);
const kPrimaryColorLight = Color.fromRGBO(237, 246, 250, 1);
const kIconColor = Color.fromRGBO(250, 250, 250, 1);
const kAccentColor = Color.fromRGBO(0, 150, 136, 1);
const kPrimaryTextColor = Color.fromRGBO(33, 33, 33, 1);
const kSecondaryTextColor = Color.fromRGBO(117, 117, 117, 1);
const kDividerColor = Color.fromRGBO(189, 189, 189, 1);
const kErrorColor = Color.fromRGBO(244, 67, 54, 1);
const kWhiteBackground = Color.fromRGBO(255, 255, 255, 1);
const kGreyBackground = Color.fromRGBO(230, 230, 230, 1);
const kInactiveColor = Color.fromRGBO(240, 240, 240, 1);

//Themes
final ThemeData defaultThemeData = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w500,
      fontSize: 32.0,
      letterSpacing: 0.0,
      color: kPrimaryColorDark,
    ),
    headlineMedium: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w500,
      fontSize: 28.0,
      letterSpacing: 0.0,
      color: kPrimaryColorDark,
    ),
    headlineSmall: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w500,
      fontSize: 24.0,
      letterSpacing: 0.0,
      color: kPrimaryColorDark,
    ),
    titleLarge: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w500,
      fontSize: 28.0,
      letterSpacing: 0.0,
      color: kPrimaryColorDark,
    ),
    titleMedium: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w500,
      fontSize: 22.0,
      letterSpacing: 0.15,
      color: kPrimaryColorDark,
    ),
    titleSmall: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w500,
      fontSize: 18.0,
      letterSpacing: 0.1,
      color: kPrimaryColorDark,
    ),
    labelLarge: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w400,
      fontSize: 22.0,
      letterSpacing: 0.1,
      color: kPrimaryColorDark,
    ),
    labelMedium: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w400,
      fontSize: 18.0,
      letterSpacing: 0.5,
      color: kPrimaryColorDark,
    ),
    labelSmall: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w400,
      fontSize: 16.0,
      letterSpacing: 0.5,
      color: kPrimaryColorDark,
    ),
    bodyLarge: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w300,
      fontSize: 18.0,
      letterSpacing: 0.15,
      color: kPrimaryColorDark,
    ),
    bodyMedium: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w400,
      fontSize: 16.0,
      letterSpacing: 0.25,
      color: kPrimaryColorDark,
    ),
    bodySmall: TextStyle(
      fontFamily: "Roboto",
      fontWeight: FontWeight.w300,
      fontSize: 14.0,
      letterSpacing: 0.4,
      color: kPrimaryColorDark,
    ),
  ),
);

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

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

const kPickTextFieldsInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.only(right: 10.0),
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: kPrimaryColorDark,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: kPrimaryColorDark,
    ),
  ),
  labelStyle: TextStyle(
    color: kPrimaryColor,
  ),
  filled: true,
  fillColor: kWhiteBackground,
);

const kLocationTextFieldInputDecoration = InputDecoration(
  contentPadding: EdgeInsets.zero,
  border: InputBorder.none,
  labelStyle: TextStyle(
    color: kPrimaryColor,
  ),
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
