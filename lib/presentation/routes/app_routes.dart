import 'package:flutter/material.dart';
import 'route_names.dart';
import '../features/onboarding/onboarding_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes {
    return {
      RouteNames.onboarding: (context) => const OnboardingScreen(),
    };
  }
  
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      default:
        return null;
    }
  }
}