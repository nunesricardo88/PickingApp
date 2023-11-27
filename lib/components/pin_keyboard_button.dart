import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class PinKeyboardButton extends StatelessWidget {
  const PinKeyboardButton(
      {this.title, this.onTap, this.isDelete, this.isEnabled = true,});

  final String? title;
  final VoidCallback? onTap;
  final bool? isDelete;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled ? onTap : () {},
      child: Container(
        width: 5.0,
        height: 5.0,
        decoration: const BoxDecoration(),
        alignment: Alignment.center,
        child: isDelete!
            ? Opacity(
                opacity: isEnabled ? 1.0 : 0.5,
                child: IconButton(
                  onPressed: onTap,
                  icon: const FaIcon(
                    FontAwesomeIcons.deleteLeft,
                    color: kPrimaryColorDark,
                  ),
                ),
              )
            : Opacity(
                opacity: isEnabled ? 1.0 : 0.5,
                child: Text(
                  title!,
                  style: TextStyle(
                    fontSize: title == 'Limpar' ? 18 : 25,
                    color: title == 'Limpar'
                        ? kPrimaryColorDark.withOpacity(0.7)
                        : kPrimaryColorDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }
}
