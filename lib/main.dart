import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopin/data/providers/report_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hopin/presentation/routes/route_names.dart';
import 'firebase_options.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/user_profile_provider.dart';
import 'presentation/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isAuthenticated && authProvider.user != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final profileProvider = Provider.of<UserProfileProvider>(
                context,
                listen: false,
              );

              if (profileProvider.userProfile.email.isEmpty) {
                profileProvider.loadUserProfile(authProvider.user!.uid);
              }
            });
          }

          return MaterialApp(
            title: 'HopIn - Ride Sharing',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFFFC107),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: RouteNames.onboarding,
          );
        },
      ),
    );
  }
}
