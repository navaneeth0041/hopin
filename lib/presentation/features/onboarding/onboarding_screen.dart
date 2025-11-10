import 'package:flutter/material.dart';
import '../../common_widgets/custom_button.dart';
import '../../../core/constants/app_strings.dart';
import '../../routes/route_names.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black, // overall black background
      body: Stack(
        children: [
          // 🎬 Very small centered Lottie Animation
          Center(
            child: Lottie.asset(
              'assets/animations/onboarding(auto).json',
              width: size.width * 0.990, // 👈 25% of screen width — very small
              height: size.height * 0.30, // 👈 15% of screen height
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
          ),

          // 🖤 Optional Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // 💬 Text + Button Section
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    AppStrings.onboardingTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.onboardingSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    text: AppStrings.continueButton,
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.login);
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
