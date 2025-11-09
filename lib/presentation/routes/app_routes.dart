import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../presentation/features/onboarding/onboarding_screen.dart';
import '../../presentation/features/auth/login_screen.dart';
import '../../presentation/features/auth/register_screen.dart';
import '../../presentation/features/auth/otp_verification_screen.dart';
import '../../presentation/features/auth/forgot_password_screen.dart';
import '../../presentation/features/auth/reset_password_screen.dart';
import '../../presentation/features/home/home_screen.dart';
import '../../presentation/features/settings/settings_screen.dart';
import '../../presentation/features/emergency_contact/emergency_contact_screen.dart';
import '../../presentation/features/driver_directory/driver_directory_screen.dart';
import '../../presentation/features/report_support/report_support_screen.dart';

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
      RouteNames.emergencyContact: (context) => const EmergencyContactScreen(),
      RouteNames.driverDirectory: (context) => const DriverDirectoryScreen(),
      RouteNames.reportSupport: (context) => const ReportSupportScreen(),
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

      case RouteNames.tripHistory:
      case RouteNames.editProfile:
      case RouteNames.notificationSettings:
      case RouteNames.locationSettings:
      case RouteNames.privacy:
      case RouteNames.blockedUsers:
      case RouteNames.changePassword:
      case RouteNames.help:
      case RouteNames.about:
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
      RouteNames.editProfile: 'Edit Profile',
      RouteNames.notificationSettings: 'Notification Settings',
      RouteNames.locationSettings: 'Location Settings',
      RouteNames.privacy: 'Privacy & Data',
      RouteNames.blockedUsers: 'Blocked Users',
      RouteNames.changePassword: 'Change Password',
      RouteNames.help: 'Help & FAQ',
      RouteNames.about: 'About HopIn',
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
              '$title',
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