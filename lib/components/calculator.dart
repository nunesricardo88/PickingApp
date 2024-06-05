// ignore_for_file: avoid_dynamic_calls
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class Calculator extends StatefulWidget {
  final double calculatedValue;
  final Function callBackValue;

  const Calculator({
    required this.calculatedValue,
    required this.callBackValue,
    super.key,
  });

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  double _currentValue = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    setState(() => _currentValue = widget.calculatedValue);
  }

  @override
  Widget build(BuildContext context) {
    final SimpleCalculator calc = SimpleCalculator(
      value: _currentValue,
      onChanged: (key, value, expression) {
        if (expression == null) return;

        //Remove BlankSpaces (CodeUnit 160)
        final String expressionParsed =
            expression.replaceAll(String.fromCharCode(160), '');

        if (RegExp(r'^[0-9,]+$').hasMatch(expressionParsed) || key == '=') {
          widget.callBackValue(value);
        }
      },
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 320.0,
        maxHeight: 320.0,
      ),
      child: calc,
    );
  }
}
