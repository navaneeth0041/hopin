import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/models/trip_payment_model.dart';
import 'package:hopin/data/providers/trip_payment_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PaymentDetailsBottomSheet extends StatefulWidget {
  final TripPayment payment;
  final bool isCreator;
  final VoidCallback? onPaymentMarked;

  const PaymentDetailsBottomSheet({
    super.key,
    required this.payment,
    required this.isCreator,
    this.onPaymentMarked,
  });

  @override
  State<PaymentDetailsBottomSheet> createState() =>
      _PaymentDetailsBottomSheetState();
}

class _PaymentDetailsBottomSheetState extends State<PaymentDetailsBottomSheet> {
  String? _selectedMemberId;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(),
          _buildPaymentSummary(),
          Expanded(
            child: _buildMembersList(),
          ),
          if (widget.isCreator && !widget.payment.isFullyPaid)
            _buildMarkAsPaidButton(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.payment.isFullyPaid
                  ? AppColors.accentGreen.withOpacity(0.1)
                  : AppColors.primaryYellow.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.payment.isFullyPaid
                  ? Icons.check_circle
                  : Icons.payment,
              color: widget.payment.isFullyPaid
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
                  widget.payment.isFullyPaid
                      ? 'All Payments Received'
                      : 'Payment Status',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(
                    widget.payment.completedAt,
                  ),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!widget.payment.isFullyPaid)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.3),
                ),
              ),
              child: Text(
                '${widget.payment.pendingCount} Pending',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Total Amount',
            '₹${widget.payment.totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: AppColors.divider.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Per Person Share',
            '₹${widget.payment.perPersonShare.toStringAsFixed(2)}',
            highlight: true,
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Total Members',
            '${widget.payment.memberPayments.length + 1}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            'Paid Members',
            '${widget.payment.paidCount}',
            valueColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool highlight = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: valueColor ??
                (highlight ? AppColors.primaryYellow : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList() {
    final members = widget.payment.memberPayments.entries.toList();

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: members.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = members[index];
        final memberId = entry.key;
        final payment = entry.value;

        return _buildMemberCard(memberId, payment);
      },
    );
  }

  Widget _buildMemberCard(String memberId, MemberPayment payment) {
    final isSelected = _selectedMemberId == memberId;
    final isPaid = payment.status == PaymentStatus.paid;
    final isDisputed = payment.status == PaymentStatus.disputed;

    return GestureDetector(
      onTap: widget.isCreator && !isPaid
          ? () {
              setState(() {
                _selectedMemberId = isSelected ? null : memberId;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPaid
              ? AppColors.accentGreen.withOpacity(0.05)
              : isDisputed
                  ? AppColors.accentRed.withOpacity(0.05)
                  : AppColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryYellow
                : isPaid
                    ? AppColors.accentGreen.withOpacity(0.3)
                    : isDisputed
                        ? AppColors.accentRed.withOpacity(0.3)
                        : AppColors.divider.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isPaid
                      ? AppColors.accentGreen.withOpacity(0.2)
                      : isDisputed
                          ? AppColors.accentRed.withOpacity(0.2)
                          : AppColors.primaryYellow.withOpacity(0.2),
                  child: Text(
                    payment.userName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isPaid
                          ? AppColors.accentGreen
                          : isDisputed
                              ? AppColors.accentRed
                              : AppColors.primaryYellow,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusText(payment.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(payment.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${payment.amountDue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (isPaid && payment.paidAt != null)
                      Text(
                        DateFormat('MMM dd').format(payment.paidAt!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (payment.note != null && payment.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDisputed ? Icons.warning_amber : Icons.note_outlined,
                      size: 16,
                      color: isDisputed
                          ? AppColors.accentRed
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        payment.note!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMarkAsPaidButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedMemberId != null ? _handleMarkAsPaid : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.divider,
            ),
            child: const Text(
              'Mark as Paid',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMarkAsPaid() async {
    if (_selectedMemberId == null) return;

    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    final provider = Provider.of<TripPaymentProvider>(
      context,
      listen: false,
    );

    final success = await provider.markAsPaid(
      paymentId: widget.payment.id,
      memberId: _selectedMemberId!,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (mounted) {
      if (success) {
        setState(() => _selectedMemberId = null);
        _noteController.clear();
        
        widget.onPaymentMarked?.call();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text('Payment marked as received')),
              ],
            ),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(provider.errorMessage ?? 'Failed to mark as paid'),
                ),
              ],
            ),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog() async {
    final member = widget.payment.memberPayments[_selectedMemberId!];
    if (member == null) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.accentGreen,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Confirm Payment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mark ${member.userName}\'s payment of ₹${member.amountDue.toStringAsFixed(2)} as received?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'Add a note (optional)',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: AppColors.darkBackground,
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: AppColors.divider),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
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
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.disputed:
        return 'Disputed';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return AppColors.accentGreen;
      case PaymentStatus.disputed:
        return AppColors.accentRed;
      case PaymentStatus.pending:
        return AppColors.accentOrange;
    }
  }
}