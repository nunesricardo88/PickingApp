import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class DocumentLinePropertyTile extends StatelessWidget {
  const DocumentLinePropertyTile({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: kPrimaryColorDark,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: kPrimaryColorDark,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
