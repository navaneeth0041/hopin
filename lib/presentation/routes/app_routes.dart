import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/otp_verification_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';

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
    };
  }
  
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case RouteNames.signup:
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        );
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
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      case RouteNames.settings:
        return MaterialPageRoute(
          builder: (context) => const SettingsScreen(),
        );
      default:
        return null;
    }
  }
}