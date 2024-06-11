import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chatapp_firebase/authentication/login_screen.dart';
import 'package:chatapp_firebase/authentication/otp_screen.dart';
import 'package:chatapp_firebase/authentication/user_information_screen.dart';
import 'package:chatapp_firebase/main_screen/home_screen.dart';
import 'package:chatapp_firebase/main_screen/settings_screen.dart';
import 'package:chatapp_firebase/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:provider/provider.dart';
import 'authentication/landing_screen.dart';
import 'constants.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ],child:MyApp(savedThemeMode: savedThemeMode),),);


}
class MyApp extends StatelessWidget {
   const MyApp({super.key,required this.savedThemeMode});
   final AdaptiveThemeMode? savedThemeMode;

  // Tạo một instance của FirebaseAnalytics
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode?? AdaptiveThemeMode.light,
      builder: (theme,darktheme) =>MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: theme,
        darkTheme: darktheme,
       initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen:(context) =>const OtpScreen(),
          Constants.userInformationScreen: (context) => const UserInformationScreen(),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.settingsScreen: (context) => const SettingsScreen(),


        },
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
      ),
    );
  }
}


