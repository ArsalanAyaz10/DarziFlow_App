import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/features/orders/widgets/operation_details.dart';
import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  final List<OperationModel> operations;
  final String? orderId;

  const OrderTimeline({super.key, required this.operations, this.orderId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(operations.length, (index) {
        final op = operations[index];
        final bool hasRejection = op.checkpoints.any((cp) => cp.isRejected);
        final bool isDone = op.isCompleted;

        return Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            collapsedIconColor: AppColors.primaryGreen,
            splashColor: Colors.transparent,
            dense: true,
            initiallyExpanded: hasRejection || (index == 0 && !op.isCompleted),
            tilePadding: EdgeInsets.zero,
            leading: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.primaryGreen : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? AppColors.primaryGreen
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Icon(
                    isDone ? Icons.check : Icons.radio_button_unchecked_sharp,
                    size: 16,
                    color: isDone ? Colors.white : Colors.grey,
                  ),
                ),
              ],
            ),
            title: Text(
              op.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            children: [
              OperationDetails(op: op, orderId: orderId)
            ],
          ),
        );
      }),
    );
  }
}
