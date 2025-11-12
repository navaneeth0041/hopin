import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopin/data/providers/report_provider.dart';
import 'package:hopin/data/providers/trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/user_profile_provider.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/features/onboarding/onboarding_screen.dart';
import 'presentation/features/auth/login_screen.dart';
import 'presentation/features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await _requestInitialPermissions();

  runApp(const MyApp());
}

Future<void> _requestInitialPermissions() async {
  try {
    await Permission.location.request();

    await Permission.sms.request();
    await Permission.phone.request();
  } catch (e) {
    return;
  }
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
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: MaterialApp(
        title: 'HopIn - Ride Sharing',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFC107),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AuthStateHandler(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(Duration.zero);

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    int attempts = 0;
    while (!authProvider.isInitialized && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (!mounted) return;

    Widget targetScreen;

    if (authProvider.isAuthenticated && authProvider.user != null) {
      if (authProvider.isEmailVerified) {
        final profileProvider = Provider.of<UserProfileProvider>(
          context,
          listen: false,
        );
        if (profileProvider.userProfile.email.isEmpty) {
          await profileProvider.loadUserProfile(authProvider.user!.uid);
        }
        targetScreen = const HomeScreen();
      } else {
        targetScreen = const LoginScreen();
      }
    } else {
      targetScreen = const OnboardingScreen();
    }

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => targetScreen));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFFFC107))),
    );
  }
}
