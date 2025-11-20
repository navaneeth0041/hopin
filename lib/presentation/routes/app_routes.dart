import 'package:flutter/material.dart';
import 'package:hopin/presentation/features/help_faq/help_faq_screen.dart';
import 'package:hopin/presentation/features/notifications/notifications_screen.dart';
import 'package:hopin/presentation/features/payments/screens/payment_history_screen.dart';
import 'package:hopin/presentation/features/payments/screens/unpaid_trips_screen.dart';
import 'package:hopin/presentation/features/profile/edit_profile_screen.dart';
import 'package:hopin/presentation/features/report_support/my_reports_screen.dart';
import 'package:hopin/presentation/features/settings/blocked_users_screen.dart';
import 'package:hopin/presentation/features/settings/privacy_settings_screen.dart';
import 'route_names.dart';
import '../../presentation/features/onboarding/onboarding_screen.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/auth/register_screen.dart';
import '../../presentation/features/auth/otp_verification_screen.dart';
import '../../presentation/features/auth/forgot_password_screen.dart';
import '../../presentation/features/auth/reset_password_screen.dart';
import '../../presentation/features/home/home_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';
import '../../presentation/features/settings/about_screen.dart';
import '../../presentation/features/settings/privacy_policy_screen.dart';
import '../../presentation/features/settings/terms_of_service_screen.dart';
import '../../presentation/features/settings/change_password_screen.dart';
import '../../presentation/features/emergency_contact/emergency_contact_screen.dart';
import '../../presentation/features/driver_directory/driver_directory_screen.dart';
import '../../presentation/features/report_support/report_support_screen.dart';
import '../../presentation/features/home/pages/create_trip_page.dart';
import '../../presentation/features/home/pages/join_trip_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      RouteNames.onboarding: (context) => const OnboardingScreen(),
      RouteNames.login: (context) => const LoginScreen(),
      RouteNames.signup: (context) => const RegisterScreen(),
      RouteNames.forgotPassword: (context) => const ForgotPasswordScreen(),
      RouteNames.resetPassword: (context) => const ResetPasswordScreen(),
      RouteNames.home: (context) => const HomeScreen(),
      RouteNames.settings: (context) => const SettingsScreen(),
      RouteNames.about: (context) => const AboutScreen(),
      RouteNames.privacyPolicy: (context) => const PrivacyPolicyScreen(),
      RouteNames.termsOfService: (context) => const TermsOfServiceScreen(),
      RouteNames.help: (context) => const HelpFaqScreen(),
      RouteNames.changePassword: (context) => const ChangePasswordScreen(),
      RouteNames.editProfile: (context) => const EditProfileScreen(),
      RouteNames.emergencyContact: (context) => const EmergencyContactScreen(),
      RouteNames.driverDirectory: (context) => const DriverDirectoryScreen(),
      RouteNames.reportSupport: (context) => const ReportSupportScreen(),
      RouteNames.myReport: (context) => const MyReportsScreen(),
      RouteNames.blockedUsers: (context) => const BlockedUsersScreen(),
      RouteNames.privacy: (context) => const PrivacySettingsScreen(),
      RouteNames.notifications: (context) => const NotificationsScreen(),
      RouteNames.createTrip: (context) => const CreateTripPage(),
      RouteNames.joinTrip: (context) => const JoinTripPage(),
      RouteNames.unpaidTrips: (context) => const UnpaidTripsScreen(),
      RouteNames.paymentHistory: (context) => const PaymentHistoryScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case RouteNames.login:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case RouteNames.signup:
        return MaterialPageRoute(builder: (context) => const RegisterScreen());
      case RouteNames.otpVerification:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(email: email),
        );
      case RouteNames.forgotPassword:
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen(),
        );
      case RouteNames.resetPassword:
        return MaterialPageRoute(
          builder: (context) => const ResetPasswordScreen(),
        );
      case RouteNames.home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case RouteNames.settings:
        return MaterialPageRoute(builder: (context) => const SettingsScreen());
      case RouteNames.about:
        return MaterialPageRoute(builder: (context) => const AboutScreen());
      case RouteNames.privacyPolicy:
        return MaterialPageRoute(
          builder: (context) => const PrivacyPolicyScreen(),
        );
      case RouteNames.termsOfService:
        return MaterialPageRoute(
          builder: (context) => const TermsOfServiceScreen(),
        );
      case RouteNames.help:
        return MaterialPageRoute(builder: (context) => const HelpFaqScreen());
      case RouteNames.changePassword:
        return MaterialPageRoute(
          builder: (context) => const ChangePasswordScreen(),
        );
      case RouteNames.editProfile:
        return MaterialPageRoute(
          builder: (context) => const EditProfileScreen(),
        );
      case RouteNames.emergencyContact:
        return MaterialPageRoute(
          builder: (context) => const EmergencyContactScreen(),
        );
      case RouteNames.driverDirectory:
        return MaterialPageRoute(
          builder: (context) => const DriverDirectoryScreen(),
        );
      case RouteNames.reportSupport:
        return MaterialPageRoute(
          builder: (context) => const ReportSupportScreen(),
        );
      case RouteNames.myReport:
        return MaterialPageRoute(builder: (context) => const MyReportsScreen());
      case RouteNames.blockedUsers:
        return MaterialPageRoute(
          builder: (context) => const BlockedUsersScreen(),
        );
      case RouteNames.privacy:
        return MaterialPageRoute(
          builder: (context) => const PrivacySettingsScreen(),
        );
      case RouteNames.notifications:
        return MaterialPageRoute(builder: (context) => NotificationsScreen());

      case RouteNames.createTrip:
        return MaterialPageRoute(builder: (context) => const CreateTripPage());

      case RouteNames.joinTrip:
        return MaterialPageRoute(builder: (context) => const JoinTripPage());

      case RouteNames.unpaidTrips:
        return MaterialPageRoute(builder: (context) => const UnpaidTripsScreen());
      case RouteNames.paymentHistory:
        return MaterialPageRoute(builder: (context) => const PaymentHistoryScreen());

      case RouteNames.tripHistory:
      case RouteNames.notificationSettings:
      case RouteNames.locationSettings:
      case RouteNames.licenses:
        return MaterialPageRoute(
          builder: (context) =>
              PlaceholderScreen(title: _getScreenTitle(settings.name ?? '')),
        );

      default:
        return null;
    }
  }

  static String _getScreenTitle(String routeName) {
    final titles = {
      RouteNames.tripHistory: 'Trip History',
      RouteNames.notificationSettings: 'Notification Settings',
      RouteNames.locationSettings: 'Location Settings',
      RouteNames.privacy: 'Privacy & Data',
      RouteNames.licenses: 'Open Source Licenses',
    };
    return titles[routeName] ?? 'Screen';
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: const Color(0xFFFFC107)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon',
              style: TextStyle(fontSize: 16, color: Color(0xFFB0B0B0)),
            ),
          ],
        ),
      ),
    );
  }
}
