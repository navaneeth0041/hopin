import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/trip_payment_model.dart';
import 'package:hopin/presentation/features/payments/widgets/payment_details_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _payments = [];
  String _filter = 'all'; // all, creator, member

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final paymentsSnapshot = await _firestore
          .collection('tripPayments')
          .orderBy('completedAt', descending: true)
          .get();

      final payments = <Map<String, dynamic>>[];

      for (final doc in paymentsSnapshot.docs) {
        final payment = TripPayment.fromMap(doc.data());
        
        // Check if user is creator or member
        final isCreator = payment.creatorId == userId;
        final isMember = payment.memberPayments.containsKey(userId);

        if (isCreator || isMember) {
          // Get trip details
          final tripDoc = await _firestore
              .collection('trips')
              .doc(payment.tripId)
              .get();

          if (tripDoc.exists) {
            payments.add({
              'payment': payment,
              'trip': tripDoc.data(),
              'isCreator': isCreator,
              'isMember': isMember,
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          _payments = payments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredPayments {
    if (_filter == 'all') return _payments;
    if (_filter == 'creator') {
      return _payments.where((p) => p['isCreator'] == true).toList();
    }
    return _payments.where((p) => p['isMember'] == true).toList();
  }

  void _showPaymentDetails(TripPayment payment, bool isCreator) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentDetailsBottomSheet(
        payment: payment,
        isCreator: isCreator,
      ),
    );
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
          'Payment History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryYellow,
                    ),
                  )
                : _filteredPayments.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPayments,
                        color: AppColors.primaryYellow,
                        backgroundColor: AppColors.cardBackground,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPayments.length,
                          itemBuilder: (context, index) {
                            final paymentData = _filteredPayments[index];
                            return _buildPaymentCard(paymentData);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildFilterChip('All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip('As Creator', 'creator'),
          const SizedBox(width: 8),
          _buildFilterChip('As Member', 'member'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryYellow
              : AppColors.darkBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryYellow
                : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> paymentData) {
    final payment = paymentData['payment'] as TripPayment;
    final trip = paymentData['trip'] as Map<String, dynamic>;
    final isCreator = paymentData['isCreator'] as bool;
    final isMember = paymentData['isMember'] as bool;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final memberPayment = payment.memberPayments[userId];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: payment.isFullyPaid
              ? AppColors.accentGreen.withOpacity(0.3)
              : AppColors.divider,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showPaymentDetails(payment, isCreator),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: payment.isFullyPaid
                          ? AppColors.accentGreen.withOpacity(0.1)
                          : AppColors.primaryYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      payment.isFullyPaid
                          ? Icons.check_circle
                          : Icons.payment,
                      color: payment.isFullyPaid
                          ? AppColors.accentGreen
                          : AppColors.primaryYellow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['destination'] ?? 'Unknown Destination',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy')
                              .format(payment.completedAt),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCreator)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Creator',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCreator ? 'Total Amount' : 'Your Share',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isCreator
                                  ? '₹${payment.totalAmount.toStringAsFixed(2)}'
                                  : '₹${memberPayment?.amountDue.toStringAsFixed(2) ?? '0.00'}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isCreator ? 'Received' : 'Status',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  isCreator
                                      ? (payment.isFullyPaid
                                          ? Icons.check_circle
                                          : Icons.pending)
                                      : (memberPayment?.status ==
                                              PaymentStatus.paid
                                          ? Icons.check_circle
                                          : Icons.pending),
                                  size: 16,
                                  color: isCreator
                                      ? (payment.isFullyPaid
                                          ? AppColors.accentGreen
                                          : AppColors.accentOrange)
                                      : (memberPayment?.status ==
                                              PaymentStatus.paid
                                          ? AppColors.accentGreen
                                          : AppColors.accentOrange),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isCreator
                                      ? '${payment.paidCount}/${payment.memberPayments.length}'
                                      : (memberPayment?.status ==
                                              PaymentStatus.paid
                                          ? 'Paid'
                                          : 'Pending'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isCreator
                                        ? (payment.isFullyPaid
                                            ? AppColors.accentGreen
                                            : AppColors.accentOrange)
                                        : (memberPayment?.status ==
                                                PaymentStatus.paid
                                            ? AppColors.accentGreen
                                            : AppColors.accentOrange),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${payment.memberPayments.length + 1} members',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primaryYellow,
                  ),
                ],
              ),
            ],
          ),
        ),
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
                color: AppColors.primaryYellow.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                color: AppColors.primaryYellow,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Payment History',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _filter == 'all'
                  ? 'Your payment history will appear here\nonce you complete trips'
                  : _filter == 'creator'
                      ? 'Payments for trips you created\nwill appear here'
                      : 'Payments for trips you joined\nwill appear here',
              textAlign: TextAlign.center,
              style: const TextStyle(
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
}