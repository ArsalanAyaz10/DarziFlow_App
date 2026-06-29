import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/features/Client/widgets/client_operation_details.dart';
import 'package:flutter/material.dart';

class ClientOrderTimeline extends StatelessWidget {
  final List<OperationModel> operations;
  final String? orderId;

  const ClientOrderTimeline({
    super.key,
    required this.operations,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(operations.length, (index) {
        final op = operations[index];
        final bool hasRejection = op.checkpoints.any((cp) => cp.isRejected);
        final bool isPendingApproval = op.status == 'CLIENT_APPROVAL_PENDING';
        final bool initiallyExpanded =
            hasRejection ||
            (index == 0 && !op.isCompleted) ||
            isPendingApproval;

        return _ClientOrderTimelineItem(
          op: op,
          orderId: orderId,
          initiallyExpanded: initiallyExpanded,
        );
      }),
    );
  }
}

class _ClientOrderTimelineItem extends StatefulWidget {
  final OperationModel op;
  final String? orderId;
  final bool initiallyExpanded;

  const _ClientOrderTimelineItem({
    required this.op,
    required this.orderId,
    required this.initiallyExpanded,
  });

  @override
  State<_ClientOrderTimelineItem> createState() =>
      _ClientOrderTimelineItemState();
}

class _ClientOrderTimelineItemState extends State<_ClientOrderTimelineItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final op = widget.op;
    final bool isDone = op.isCompleted;
    final bool isPendingApproval = op.status == 'CLIENT_APPROVAL_PENDING';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: _isExpanded ? Colors.transparent : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isExpanded
              ? Colors.transparent
              : theme.dividerColor.withValues(alpha: 0.8),
          width: 1.0,
        ),
      ),
      child: Stack(
        children: [
          if (_isExpanded)
            Positioned(
              left: 27, // 12 tilePadding + 15 (half of 30 icon width)
              top: 44, // starts just below the icon circle
              bottom: 12, // runs down to the bottom of the card details
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: isDone
                      ? AppColors.atelierSilkGreen.withValues(alpha: 0.5)
                      : (isPendingApproval
                            ? AppColors.atelierAmber.withValues(alpha: 0.5)
                            : theme.dividerColor.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          Theme(
            data: theme.copyWith(
              dividerColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: ExpansionTile(
              collapsedIconColor: AppColors.atelierSilkGreen,
              splashColor: Colors.transparent,
              dense: true,
              initiallyExpanded: widget.initiallyExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isExpanded = expanded;
                });
              },
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.atelierSilkGreen
                          : (isPendingApproval
                                ? AppColors.atelierAmber
                                : Colors.transparent),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone
                            ? AppColors.atelierSilkGreen
                            : (isPendingApproval
                                  ? AppColors.atelierAmber
                                  : Colors.grey.withValues(alpha: 0.5)),
                      ),
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check
                          : (isPendingApproval
                                ? Icons.pending_actions
                                : Icons.radio_button_unchecked_sharp),
                      size: 16,
                      color: (isDone || isPendingApproval)
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              title: Text(
                op.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              children: [
                ClientOperationDetails(op: op, orderId: widget.orderId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
