import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/trip_payment_provider.dart';
import 'package:hopin/data/services/payment_reminder_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnpaidTripsScreen extends StatefulWidget {
  const UnpaidTripsScreen({super.key});

  @override
  State<UnpaidTripsScreen> createState() => _UnpaidTripsScreenState();
}

class _UnpaidTripsScreenState extends State<UnpaidTripsScreen> {
  final PaymentReminderService _reminderService = PaymentReminderService();
  bool _isLoading = true;
  final Map<String, bool> _sendingReminders = {};
  final Map<String, DateTime?> _lastReminderTimes = {};

  @override
  void initState() {
    super.initState();
    _loadUnpaidTrips();
  }

  Future<void> _loadUnpaidTrips() async {
    final provider = Provider.of<TripPaymentProvider>(context, listen: false);
    await provider.checkPaymentStatus();

    for (final trip in provider.unpaidTripDetails) {
      final tripId = trip['tripId'] as String?;
      if (tripId != null) {
        final creatorId = await _getCreatorId(tripId);
        if (creatorId != null) {
          final lastTime = await _reminderService.getLastReminderTime(
            tripId: tripId,
            creatorId: creatorId,
          );
          _lastReminderTimes[tripId] = lastTime;
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _getCreatorId(String tripId) async {
    try {
      final tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();
      return tripDoc.data()?['createdBy'];
    } catch (e) {
      return null;
    }
  }

  Future<void> _sendReminder(Map<String, dynamic> trip) async {
    final tripId = trip['tripId'] as String;
    final amount = (trip['amount'] as double?) ?? 0.0;

    setState(() => _sendingReminders[tripId] = true);

    try {
      final tripDoc = await FirebaseFirestore.instance
          .collection('trips')
          .doc(tripId)
          .get();

      if (!tripDoc.exists) {
        throw Exception('Trip not found');
      }

      final tripData = tripDoc.data()!;
      final creatorId = tripData['createdBy'] as String;
      final creatorName = tripData['creatorName'] as String;

      final result = await _reminderService.sendPaymentReminder(
        tripId: tripId,
        creatorId: creatorId,
        creatorName: creatorName,
        amount: amount,
      );

      if (mounted) {
        if (result['success']) {
          _lastReminderTimes[tripId] = DateTime.now();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'Reminder sent successfully',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.accentGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(result['error'] ?? 'Failed to send reminder'),
                  ),
                ],
              ),
              backgroundColor: AppColors.accentRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _sendingReminders[tripId] = false);
      }
    }
  }

  String _getReminderButtonText(String tripId) {
    final lastTime = _lastReminderTimes[tripId];
    if (lastTime == null) return 'Notify Creator';

    final hoursSince = DateTime.now().difference(lastTime).inHours;
    if (hoursSince >= 24) return 'Notify Again';

    final hoursRemaining = 24 - hoursSince;
    return 'Notified ${hoursRemaining}h ago';
  }

  bool _canSendReminder(String tripId) {
    final lastTime = _lastReminderTimes[tripId];
    if (lastTime == null) return true;

    final hoursSince = DateTime.now().difference(lastTime).inHours;
    return hoursSince >= 24;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pending Payments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            )
          : Consumer<TripPaymentProvider>(
              builder: (context, provider, child) {
                final unpaidTrips = provider.unpaidTripDetails;

                if (unpaidTrips.isEmpty) {
                  return _buildEmptyState();
                }

                final totalUnpaid = unpaidTrips.fold<double>(
                  0,
                  (sum, trip) => sum + ((trip['amount'] as double?) ?? 0),
                );

                return RefreshIndicator(
                  onRefresh: _loadUnpaidTrips,
                  color: AppColors.primaryYellow,
                  backgroundColor: AppColors.cardBackground,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCard(unpaidTrips.length, totalUnpaid),
                        _buildInfoSection(),
                        _buildTripsList(unpaidTrips),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.accentGreen,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Caught Up!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You have no pending payments.\nYou\'re free to create or join trips.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int tripCount, double totalAmount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentRed.withOpacity(0.2),
            AppColors.accentOrange.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentRed.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    Text(
                      '$tripCount',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentRed,
                      ),
                    ),
                    Text(
                      tripCount == 1 ? 'Trip' : 'Trips',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.block, color: AppColors.accentOrange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Clear pending payments to create or join new trips',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
              const SizedBox(width: 12),
              const Text(
                'What to do?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            '1. Complete the payment',
            'Transfer the amount to the trip creator',
          ),
          const SizedBox(height: 10),
          _buildInfoItem(
            '2. Use "Notify Creator" button',
            'Send a reminder to mark your payment as received',
          ),
          const SizedBox(height: 10),
          _buildInfoItem(
            '3. Wait for confirmation',
            'The creator will mark your payment once verified',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: AppColors.primaryYellow,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'You can send one reminder per trip every 24 hours',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primaryYellow,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripsList(List<Map<String, dynamic>> trips) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Trips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: trips.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildTripCard(trips[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final tripId = trip['tripId'] as String;
    final destination = trip['tripDestination'] ?? 'Unknown';
    final amount = (trip['amount'] as double?) ?? 0.0;
    final creatorName = trip['creatorName'] ?? 'Unknown';
    final tripDate = trip['tripDate'] as DateTime?;
    final isSending = _sendingReminders[tripId] ?? false;
    final canSend = _canSendReminder(tripId);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentRed.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.accentRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Organized by $creatorName',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount Due',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentRed,
                      ),
                    ),
                  ],
                ),
                if (tripDate != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Trip Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(tripDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canSend && !isSending
                  ? () => _sendReminder(trip)
                  : null,
              icon: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Icon(
                      canSend ? Icons.notifications_active : Icons.schedule,
                      size: 18,
                    ),
              label: Text(_getReminderButtonText(tripId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: canSend
                    ? AppColors.primaryYellow
                    : AppColors.divider,
                foregroundColor: canSend
                    ? Colors.black
                    : AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
