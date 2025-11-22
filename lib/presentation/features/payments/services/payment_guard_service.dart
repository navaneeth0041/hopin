import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/trip_payment_provider.dart';
import 'package:hopin/data/services/payment_reminder_service.dart';
import 'package:hopin/presentation/features/payments/screens/unpaid_trips_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentGuardService {
  static final PaymentReminderService _reminderService =
      PaymentReminderService();

  static Future<bool> checkPaymentStatusBeforeAction(
    BuildContext context, {
    required String actionType,
  }) async {
    final paymentProvider = Provider.of<TripPaymentProvider>(
      context,
      listen: false,
    );

    final status = await paymentProvider.checkPaymentStatus();

    if (status['hasUnpaidTrips'] == true) {
      final unpaidTrips = paymentProvider.unpaidTripDetails;
      final totalUnpaid = unpaidTrips.fold<double>(
        0,
        (sum, trip) => sum + ((trip['amount'] as double?) ?? 0),
      );

      if (context.mounted) {
        await _showBlockedDialog(
          context,
          actionType: actionType,
          unpaidTrips: unpaidTrips,
          totalUnpaid: totalUnpaid,
        );
      }

      return false;
    }

    return true;
  }

  static Future<void> _showBlockedDialog(
    BuildContext context, {
    required String actionType,
    required List<Map<String, dynamic>> unpaidTrips,
    required double totalUnpaid,
  }) async {
    final tripsWithStatus = await Future.wait(
      unpaidTrips.map((trip) async {
        final tripId = trip['tripId'] as String;

        String? creatorId;
        String? creatorPhone;
        try {
          final tripDoc = await FirebaseFirestore.instance
              .collection('trips')
              .doc(tripId)
              .get();
          if (tripDoc.exists) {
            creatorId = tripDoc.data()?['createdBy'];
            creatorPhone = tripDoc.data()?['creatorDetails']?['phone'];
          }
        } catch (e) {
          //
        }

        bool canSendReminder = false;
        DateTime? lastReminderTime;

        if (creatorId != null) {
          canSendReminder = await _reminderService.canSendReminder(
            tripId: tripId,
            creatorId: creatorId,
          );
          lastReminderTime = await _reminderService.getLastReminderTime(
            tripId: tripId,
            creatorId: creatorId,
          );
        }

        return {
          ...trip,
          'creatorId': creatorId,
          'creatorPhone': creatorPhone,
          'canSendReminder': canSendReminder,
          'lastReminderTime': lastReminderTime,
        };
      }),
    );

    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PaymentBlockedDialog(
        actionType: actionType,
        unpaidTrips: tripsWithStatus,
        totalUnpaid: totalUnpaid,
      ),
    );
  }
}

class _PaymentBlockedDialog extends StatefulWidget {
  final String actionType;
  final List<Map<String, dynamic>> unpaidTrips;
  final double totalUnpaid;

  const _PaymentBlockedDialog({
    required this.actionType,
    required this.unpaidTrips,
    required this.totalUnpaid,
  });

  @override
  State<_PaymentBlockedDialog> createState() => _PaymentBlockedDialogState();
}

class _PaymentBlockedDialogState extends State<_PaymentBlockedDialog> {
  final PaymentReminderService _reminderService = PaymentReminderService();
  final Map<String, bool> _sendingReminders = {};
  final Map<String, bool> _reminderSent = {};

  Future<void> _sendReminder(Map<String, dynamic> trip) async {
    final tripId = trip['tripId'] as String;
    final creatorId = trip['creatorId'] as String?;
    final creatorName = trip['creatorName'] as String? ?? 'the creator';
    final amount = (trip['amount'] as double?) ?? 0.0;

    if (creatorId == null) {
      _showSnackBar(
        'Cannot send reminder: Creator information not found',
        isError: true,
      );
      return;
    }

    setState(() => _sendingReminders[tripId] = true);

    try {
      final result = await _reminderService.sendPaymentReminder(
        tripId: tripId,
        creatorId: creatorId,
        creatorName: creatorName,
        amount: amount,
      );

      if (result['success']) {
        setState(() {
          _reminderSent[tripId] = true;
          trip['canSendReminder'] = false;
          trip['lastReminderTime'] = DateTime.now();
        });
        _showSnackBar('Reminder sent to $creatorName successfully');
      } else {
        _showSnackBar(
          result['error'] ?? 'Failed to send reminder',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      setState(() => _sendingReminders[tripId] = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.accentRed : AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getReminderButtonText(Map<String, dynamic> trip) {
    final tripId = trip['tripId'] as String;

    if (_reminderSent[tripId] == true) {
      return 'Reminder Sent ✓';
    }

    final lastTime = trip['lastReminderTime'] as DateTime?;
    if (lastTime == null) return 'Notify Creator';

    final hoursSince = DateTime.now().difference(lastTime).inHours;
    if (hoursSince >= 24) return 'Notify Again';

    return 'Notified ${hoursSince}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTotalUnpaid(),
              const SizedBox(height: 20),
              _buildTripsList(),
              const SizedBox(height: 20),
              _buildInfoBox(),
              const SizedBox(height: 20),
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accentRed.withOpacity(0.2),
                AppColors.accentOrange.withOpacity(0.2),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.block, color: AppColors.accentRed, size: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          'Payment Required',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.actionType == 'create'
              ? 'You cannot create new trips with pending payments'
              : 'You cannot join new trips with pending payments',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalUnpaid() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentRed.withOpacity(0.1),
            AppColors.accentOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentRed.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Total Outstanding',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${widget.totalUnpaid.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.accentRed,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.unpaidTrips.length} ${widget.unpaidTrips.length == 1 ? 'trip' : 'trips'} pending',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: widget.unpaidTrips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildTripCard(widget.unpaidTrips[index]);
        },
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final tripId = trip['tripId'] as String;
    final destination = trip['tripDestination'] ?? 'Unknown';
    final amount = (trip['amount'] as double?) ?? 0.0;
    final creatorName = trip['creatorName'] ?? 'Unknown';
    final creatorPhone = trip['creatorPhone'] as String?;
    final tripDate = trip['tripDate'] as DateTime?;
    final canSend = (trip['canSendReminder'] as bool?) ?? false;
    final isSending = _sendingReminders[tripId] ?? false;
    final wasSent = _reminderSent[tripId] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: wasSent
              ? AppColors.accentGreen.withOpacity(0.3)
              : AppColors.divider.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.accentRed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            creatorName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (creatorPhone != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 10,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            creatorPhone,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentRed,
                    ),
                  ),
                  if (tripDate != null)
                    Text(
                      DateFormat('MMM dd').format(tripDate),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canSend && !isSending && !wasSent
                  ? () => _sendReminder(trip)
                  : null,
              icon: isSending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Icon(
                      wasSent
                          ? Icons.check
                          : canSend
                          ? Icons.notifications_active
                          : Icons.schedule,
                      size: 16,
                    ),
              label: Text(
                _getReminderButtonText(trip),
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: wasSent
                    ? AppColors.accentGreen
                    : canSend
                    ? AppColors.primaryYellow
                    : AppColors.divider,
                foregroundColor: wasSent || canSend
                    ? Colors.black
                    : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.accentBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'How to resolve?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '1. Complete the payment to creator\n2. Use "Notify Creator" button\n3. Wait for confirmation (24h reminder cooldown)',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Understood',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnpaidTripsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View All',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
