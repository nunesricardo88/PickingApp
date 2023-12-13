import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/screens/picking_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:provider/provider.dart';

class MenuItemCard extends StatefulWidget {
  final PickingTask pickingTask;
  final VoidCallback rebuildCallback;

  const MenuItemCard({
    required this.pickingTask,
    required this.rebuildCallback,
  });

  @override
  _MenuItemCardState createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  bool isDocUpdate = false;

  Future<bool> setupPickingTask() async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);
    pickingTask.update(widget.pickingTask);
    return true;
  }

  String getPendingItemsText() {
    final String description = widget.pickingTask.description;
    if (int.tryParse(description) != null) {
      final int pendingItems = int.parse(description);
      if (pendingItems == 1) {
        return '$pendingItems item pendente';
      } else {
        return '$pendingItems itens pendentes';
      }
    } else {
      return description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      shadowColor: Colors.transparent,
      child: MaterialButton(
        elevation: 0.0,
        color: kPrimaryColorLight,
        height: 75.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        onPressed: () async {
          final bool success = await setupPickingTask();
          if (success) {
            // ignore: use_build_context_synchronously
            await Navigator.pushNamed(context, PickingScreen.id);
          }
          widget.rebuildCallback();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pickingTask.name,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: kPrimaryTextColor,
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                Text(
                  getPendingItemsText(),
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                    color: kPrimaryTextColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right_outlined,
              color: kPrimaryColor.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}
