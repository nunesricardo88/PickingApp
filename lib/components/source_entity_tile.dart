import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:provider/provider.dart';

class SourceEntityTile extends StatelessWidget {
  final Entity entity;

  const SourceEntityTile({required this.entity});

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingData = context.watch<PickingTask>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListTile(
            onTap: () async {
              await pickingData.setEntity(entity);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            dense: true,
            contentPadding: const EdgeInsets.only(
              left: 10.0,
              right: 20.0,
            ),
            title: Text(
              entity.name,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: kPrimaryColorDark,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
        Divider(
          color: Colors.black.withOpacity(0.3),
        ),
      ],
    );
  }
}
