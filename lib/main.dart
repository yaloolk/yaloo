import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/features/guide/providers/guide_provider.dart';
import 'package:yaloo/features/guide/screens/guide_dashboard_screen.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';
import 'package:yaloo/features/tourist/providers/guide_booking_provider.dart';
import 'package:yaloo/features/tourist/providers/stay_booking_provider.dart';
import 'package:yaloo/features/tourist/providers/tourist_provider.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';
import 'package:yaloo/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'features/tourist/providers/city_provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
  final stripePublishable = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  if (!kIsWeb) {
    // This will now only run on Android/iOS, preventing the web crash
    Stripe.publishableKey = stripePublishable;
    await Stripe.instance.applySettings();
  } else {
    // Optional: If you intend to process payments on the web version of Yaloo later,
    // you must add 'flutter_stripe_web' to your pubspec.yaml and uncomment this block.
    Stripe.publishableKey = stripePublishable;
    await Stripe.instance.applySettings();
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: false,
  );

  try {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await Supabase.instance.client.auth.refreshSession();
    }
  } catch (e) {
    // Not logged in yet — that's fine, login flow handles it
    debugPrint('Session refresh skipped: $e');
  }

  runApp(const YalooApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };
}

class YalooApp extends StatelessWidget {
  const YalooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TouristProvider()),
          ChangeNotifierProvider(create: (_) => HostProvider()),
          ChangeNotifierProvider(
            create: (_) => GuideBookingProvider(
              service: GuideBookingService(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => GuideProvider()..init()),
          ChangeNotifierProvider(
            create: (_) => StayBookingProvider(),
          ),
          ChangeNotifierProvider(create: (_) => CityProvider()),
        ],
        child: ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Yaloo - Explore Sri Lanka',
          scrollBehavior: AppScrollBehavior(),
          theme: ThemeData(
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
          initialRoute: '/splash',
          routes: AppRoutes.routes,
        );
      },
    ),
    );
  }
}
