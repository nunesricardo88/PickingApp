// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';

class Calculator extends StatefulWidget {
  final double calculatedValue;
  final Function callBackValue;

  const Calculator({
    required this.calculatedValue,
    required this.callBackValue,
    Key? key,
  }) : super(key: key);

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
      hideExpression: true,
      onChanged: (key, value, expression) {
        setState(() {
          _currentValue = value ?? 0.0;
        });
        widget.callBackValue(_currentValue);
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
