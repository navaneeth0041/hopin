// // lib/features/home/widgets/home_header.dart
// import 'package:flutter/material.dart';
// import 'package:hopin/core/constants/app_colors.dart';

// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Hello, John!',
//                 style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.location_on_outlined,
//                     color: AppColors.textSecondary,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Kochi, Kerala',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         Row(
//           children: [
//             // Notification Bell
//             Stack(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: AppColors.cardBackground,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: AppColors.divider, width: 1),
//                   ),
//                   child: Icon(
//                     Icons.notifications_outlined,
//                     color: AppColors.textSecondary,
//                     size: 22,
//                   ),
//                 ),
//                 Positioned(
//                   top: 4,
//                   right: 4,
//                   child: Container(
//                     width: 18,
//                     height: 18,
//                     decoration: BoxDecoration(
//                       color: AppColors.accentRed,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: AppColors.accentRed.withOpacity(0.4),
//                           blurRadius: 6,
//                           spreadRadius: 0,
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         '3',
//                         style: TextStyle(
//                           color: AppColors.textPrimary,
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 12),
//           ],
//         ),
//       ],
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

// lib/features/home/widgets/home_header.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hopin/core/constants/app_colors.dart';
import 'package:hopin/data/services/trip_request_service.dart';
import 'package:hopin/presentation/features/notifications/notifications_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, John!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Kochi, Kerala',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Row(
          children: [
StreamBuilder<int>(
  stream: TripRequestService().getUnreadNotificationsCount(
    FirebaseAuth.instance.currentUser?.uid ?? '',
  ),
  builder: (context, snapshot) {
    final unreadCount = snapshot.data ?? 0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NotificationsScreen(),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 1),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.accentRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  },
),

            const SizedBox(width: 12),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('SOS triggered!')));
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentRed, width: 1),
                ),
                child: const Icon(
                  Icons.emergency_outlined,
                  color: AppColors.accentRed,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
