import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      RouteNames.onboarding: (context) => const OnboardingScreen(),
      RouteNames.login: (context) => const LoginScreen(),
      RouteNames.signup: (context) => const RegisterScreen(),
      RouteNames.home: (context) => const HomeScreen(),
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
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      default:
        return null;
    }
  }
}