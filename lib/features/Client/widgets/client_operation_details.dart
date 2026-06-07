import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/features/Orders/widgets/checkpoint_item.dart';
import 'package:flutter/material.dart';

class ClientOperationDetails extends StatelessWidget {
  final OperationModel op;
  final String? orderId;

  const ClientOperationDetails({
    super.key,
    required this.op,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final currentCP = op.checkpoints.isNotEmpty ? op.checkpoints.last : null;
    if (currentCP == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 45, bottom: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: op.checkpoints.map(
          (cp) => CheckpointItem(
            cp: cp,
            orderId: orderId,
            isClientView: true,
            showActions: false,
          ),
        ).toList(),
      ),
    );
  }
}
