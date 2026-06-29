import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/operationModel.dart';
import 'package:dariziflow_app/features/Orders/widgets/operation_details.dart';
import 'package:flutter/material.dart';

class OrderTimeline extends StatelessWidget {
  final List<OperationModel> operations;
  final String? orderId;
  final String userRole;

  const OrderTimeline({
    super.key,
    required this.operations,
    this.orderId,
    this.userRole = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(operations.length, (index) {
        final op = operations[index];
        final bool hasRejection = op.checkpoints.any((cp) => cp.isRejected);
        final bool isQC = userRole.toUpperCase() == 'QC_MEMBER';
        final bool needsReview =
            isQC &&
            op.checkpoints.any(
              (cp) => cp.status == 'SUBMITTED' || cp.isQcPending,
            );
        final bool initiallyExpanded =
            hasRejection || (index == 0 && !op.isCompleted) || needsReview;

        return _OrderTimelineItem(
          op: op,
          orderId: orderId,
          userRole: userRole,
          initiallyExpanded: initiallyExpanded,
          operationIndex: index,
          allOperations: operations,
        );
      }),
    );
  }
}

class _OrderTimelineItem extends StatefulWidget {
  final OperationModel op;
  final String? orderId;
  final String userRole;
  final bool initiallyExpanded;
  final int operationIndex;
  final List<OperationModel> allOperations;

  const _OrderTimelineItem({
    required this.op,
    required this.orderId,
    required this.userRole,
    required this.initiallyExpanded,
    required this.operationIndex,
    required this.allOperations,
  });

  @override
  State<_OrderTimelineItem> createState() => _OrderTimelineItemState();
}

class _OrderTimelineItemState extends State<_OrderTimelineItem> {
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
    final bool isQC = widget.userRole.toUpperCase() == 'QC_MEMBER';
    final bool needsReview =
        isQC &&
        op.checkpoints.any((cp) => cp.status == 'SUBMITTED' || cp.isQcPending);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: _isExpanded ? Colors.transparent : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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
                      ? AppColors.primaryGreen.withValues(alpha: 0.5)
                      : (needsReview
                            ? Colors.orange.withValues(alpha: 0.5)
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
              collapsedIconColor: AppColors.primaryGreen,
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
                          ? AppColors.primaryGreen
                          : (needsReview ? Colors.orange : Colors.transparent),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone
                            ? AppColors.primaryGreen
                            : (needsReview
                                  ? Colors.orange
                                  : Colors.grey.withValues(alpha: 0.5)),
                      ),
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check
                          : (needsReview
                                ? Icons.rate_review
                                : Icons.radio_button_unchecked_sharp),
                      size: 16,
                      color: (isDone || needsReview)
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
                  fontSize: 15,
                ),
              ),
              children: [
                OperationDetails(
                  op: op,
                  orderId: widget.orderId,
                  userRole: widget.userRole,
                  operationIndex: widget.operationIndex,
                  allOperations: widget.allOperations,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
