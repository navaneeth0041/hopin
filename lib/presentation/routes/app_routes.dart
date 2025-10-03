import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      RouteNames.onboarding: (context) => const OnboardingScreen(),
      RouteNames.login: (context) => const LoginScreen(),
      RouteNames.signup: (context) => const RegisterScreen(),
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
      default:
        return null;
    }
  }
}