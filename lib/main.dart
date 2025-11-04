import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const YalooApp());
}

class YalooApp extends StatelessWidget {
  const YalooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yaloo - Explore Sri Lanka',
      theme: ThemeData(
        // fontFamily: 'Poppins',
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.thirdBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          primary: AppColors.primaryBlue,
          secondary: AppColors.eggplant,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
       initialRoute: '/onboarding1', // Start app from Onboarding 1
       routes: AppRoutes.routes,
    );
  }
}
