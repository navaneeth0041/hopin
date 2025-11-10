import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/report_model.dart';
import 'package:intl/intl.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryIcon(),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.categoryDisplayName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(report.createdAt),
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 13,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                DateFormat('h:mm a').format(report.createdAt),
                                style: TextStyle(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.8,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    _buildStatusBadge(),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.textSecondary.withOpacity(0.1),
                        AppColors.textSecondary.withOpacity(0.3),
                        AppColors.textSecondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  report.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                if (report.status == ReportStatus.submitted) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accentRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: AppColors.accentRed.withOpacity(0.1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: AppColors.primaryYellow,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryYellow,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    IconData icon;
    Color color;

    switch (report.category) {
      case ReportCategory.safetyConcern:
        icon = Icons.dangerous_outlined;
        color = AppColors.accentRed;
        break;
      case ReportCategory.driverIssue:
        icon = Icons.person_off_outlined;
        color = AppColors.accentOrange;
        break;
      case ReportCategory.vehicleProblem:
        icon = Icons.directions_car_outlined;
        color = AppColors.accentBlue;
        break;
      case ReportCategory.paymentDispute:
        icon = Icons.payment_outlined;
        color = AppColors.accentGreen;
        break;
      case ReportCategory.routeProblem:
        icon = Icons.route_outlined;
        color = AppColors.primaryYellow;
        break;
      default:
        icon = Icons.report_outlined;
        color = AppColors.textSecondary;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (report.status) {
      case ReportStatus.submitted:
        backgroundColor = AppColors.accentBlue.withOpacity(0.15);
        textColor = AppColors.accentBlue;
        icon = Icons.schedule_outlined;
        break;
      case ReportStatus.underReview:
        backgroundColor = AppColors.accentOrange.withOpacity(0.15);
        textColor = AppColors.accentOrange;
        icon = Icons.pending_outlined;
        break;
      case ReportStatus.resolved:
        backgroundColor = AppColors.accentGreen.withOpacity(0.15);
        textColor = AppColors.accentGreen;
        icon = Icons.check_circle_outline;
        break;
      case ReportStatus.closed:
        backgroundColor = AppColors.textSecondary.withOpacity(0.15);
        textColor = AppColors.textSecondary;
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            report.statusDisplayName,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
