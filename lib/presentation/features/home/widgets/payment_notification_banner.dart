import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/providers/trip_payment_provider.dart';
import 'package:hopin/presentation/features/payments/screens/unpaid_trips_screen.dart';
import 'package:provider/provider.dart';

class PaymentNotificationBanner extends StatefulWidget {
  const PaymentNotificationBanner({super.key});

  @override
  State<PaymentNotificationBanner> createState() =>
      _PaymentNotificationBannerState();
}

class _PaymentNotificationBannerState extends State<PaymentNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    final provider = Provider.of<TripPaymentProvider>(
      context,
      listen: false,
    );
    final status = await provider.checkPaymentStatus();
    
    if (status['hasUnpaidTrips'] && mounted && !_isDismissed) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    setState(() => _isDismissed = true);
    _animationController.reverse();
  }

  void _handleViewDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UnpaidTripsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripPaymentProvider>(
      builder: (context, provider, child) {
        final unpaidTrips = provider.unpaidTripDetails;
        
        if (unpaidTrips.isEmpty || _isDismissed) {
          return const SizedBox.shrink();
        }

        final totalUnpaid = unpaidTrips.fold<double>(
          0,
          (sum, trip) => sum + ((trip['amount'] as double?) ?? 0),
        );

        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentRed.withOpacity(0.9),
                  AppColors.accentOrange.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentRed.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleViewDetails,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.payment,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Pending Payment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${unpaidTrips.length}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${totalUnpaid.toStringAsFixed(2)} outstanding',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Text(
                                  'Tap to view details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _handleDismiss,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Compact version for smaller screens or different placements
class PaymentNotificationChip extends StatelessWidget {
  const PaymentNotificationChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripPaymentProvider>(
      builder: (context, provider, child) {
        final unpaidCount = provider.unpaidTripDetails.length;
        
        if (unpaidCount == 0) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UnpaidTripsScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accentRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: AppColors.accentRed,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '$unpaidCount pending ${unpaidCount == 1 ? 'payment' : 'payments'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentRed,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}