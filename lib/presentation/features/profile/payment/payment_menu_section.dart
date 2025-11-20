// import 'package:flutter/material.dart';
// import 'package:hopin/core/constants/app_colors.dart';
// import 'package:hopin/data/providers/trip_payment_provider.dart';
// import 'package:hopin/presentation/features/payments/screens/payment_history_screen.dart';
// import 'package:hopin/presentation/features/payments/screens/unpaid_trips_screen.dart';
// import 'package:provider/provider.dart';


// class PaymentMenuSection extends StatelessWidget {
//   const PaymentMenuSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TripPaymentProvider>(
//       builder: (context, provider, child) {
//         final unpaidCount = provider.unpaidTripDetails.length;
//         final hasUnpaid = unpaidCount > 0;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Padding(
//               padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
//               child: Text(
//                 'Payments',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: AppColors.cardBackground,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 children: [
//                   _buildMenuItem(
//                     context: context,
//                     icon: Icons.receipt_long,
//                     iconColor: AppColors.primaryYellow,
//                     title: 'Payment History',
//                     subtitle: 'View all payment records',
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const PaymentHistoryScreen(),
//                         ),
//                       );
//                     },
//                   ),
                  
//                   Divider(
//                     height: 1,
//                     color: AppColors.divider.withOpacity(0.3),
//                     indent: 60,
//                   ),
                  
//                   _buildMenuItem(
//                     context: context,
//                     icon: Icons.payment,
//                     iconColor: hasUnpaid ? AppColors.accentRed : AppColors.accentGreen,
//                     title: 'Pending Payments',
//                     subtitle: hasUnpaid 
//                         ? '$unpaidCount ${unpaidCount == 1 ? 'payment' : 'payments'} pending'
//                         : 'No pending payments',
//                     trailing: hasUnpaid
//                         ? Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColors.accentRed,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               '$unpaidCount',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           )
//                         : null,
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const UnpaidTripsScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildMenuItem({
//     required BuildContext context,
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     String? subtitle,
//     Widget? trailing,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: iconColor, size: 22),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w600,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   if (subtitle != null) ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             if (trailing != null) trailing,
//             const SizedBox(width: 8),
//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: AppColors.textSecondary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class PaymentQuickAccessButton extends StatelessWidget {
//   const PaymentQuickAccessButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<TripPaymentProvider>(
//       builder: (context, provider, child) {
//         final unpaidCount = provider.unpaidTripDetails.length;
//         final hasUnpaid = unpaidCount > 0;

//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => hasUnpaid 
//                     ? const UnpaidTripsScreen()
//                     : const PaymentHistoryScreen(),
//               ),
//             );
//           },
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: hasUnpaid 
//                       ? AppColors.accentRed.withOpacity(0.1)
//                       : AppColors.primaryYellow.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: hasUnpaid 
//                         ? AppColors.accentRed.withOpacity(0.3)
//                         : AppColors.primaryYellow.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.payment,
//                   color: hasUnpaid ? AppColors.accentRed : AppColors.primaryYellow,
//                   size: 22,
//                 ),
//               ),
//               if (hasUnpaid)
//                 Positioned(
//                   right: -4,
//                   top: -4,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: AppColors.accentRed,
//                       shape: BoxShape.circle,
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 18,
//                       minHeight: 18,
//                     ),
//                     child: Text(
//                       unpaidCount > 9 ? '9+' : '$unpaidCount',
//                       style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }