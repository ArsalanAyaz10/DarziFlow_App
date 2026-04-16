import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/models/checkpointModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckpointItem extends StatelessWidget {
  final CheckpointModel cp;

  const CheckpointItem({super.key, required this.cp});

  @override
  Widget build(BuildContext context) {
    IconData stateIcon;
    Color stateColor;

    if (cp.isApproved || cp.status == 'QC_APPROVED') {
      stateIcon = Icons.check_circle;
      stateColor = AppColors.primaryGreen;
    } else if (cp.isRejected || cp.status == 'QC_REJECTED') {
      stateIcon = Icons.cancel;
      stateColor = Colors.red;
    } else if (cp.isQcPending || cp.status == 'SUBMITTED') {
      stateIcon = Icons.schedule;
      stateColor = Colors.orange;
    } else if (cp.toBeSubmitted) {
      stateIcon = Icons.upload_file;
      stateColor = Colors.blue;
    } else {
      stateIcon = Icons.radio_button_unchecked;
      stateColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        splashColor: Colors.transparent,
        onTap: () => _showHistory(context, cp),
        child: Row(
          children: [
            Icon(stateIcon, color: stateColor, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cp.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (cp.isRejected || cp.status == 'QC_REJECTED')
                    const Text(
                      "Rejected: View feedback",
                      style: TextStyle(color: Colors.red, fontSize: 11),
                    )
                  else if (cp.isApproved || cp.status == 'QC_APPROVED')
                    const Text(
                      "Approved: Check Remarks",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 11,
                      ),
                    )
                  else if (cp.isQcPending || cp.status == 'SUBMITTED')
                    const Text(
                      "Awaiting Approval",
                      style: TextStyle(color: Colors.orange, fontSize: 11),
                    )
                  else
                    const Text(
                      "View history",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                ],
              ),
            ),
            if (cp.history.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.history,
                  size: 22,
                  color: Theme.of(context).colorScheme.outline,
                ),
                onPressed: () => _showHistory(context, cp),
              ),
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context, CheckpointModel cp) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.4,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "History: ${cp.name}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: cp.history.reversed
                        .map(
                          (h) => ListTile(
                            title: Text(
                              h.action,
                              style: TextStyle(
                                color:
                                    h.action.toLowerCase().contains("approve")
                                        ? AppColors.primaryGreen
                                        : (h.action.toLowerCase().contains("reject")
                                            ? Colors.red
                                            : Theme.of(context).colorScheme.onSurface),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(h.comment ?? "No comment"),
                            trailing: Text(
                              "${h.actedAt.hour.toString().padLeft(2, '0')}:${h.actedAt.minute.toString().padLeft(2, '0')}",
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }
}
