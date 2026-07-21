import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'presentation/providers/auth_notifier.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'data/repositories/property_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/properties/presentation/screens/property_list_screen.dart';
import 'features/payment/providers/payment_notifier.dart';
import 'features/payment/presentation/screens/access_pass_purchase_screen.dart';
import 'features/properties/providers/property_notifier.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/notifications/providers/notification_notifier.dart';
import 'features/properties/presentation/screens/my_listings_screen.dart';
import 'features/properties/presentation/screens/add_property_screen.dart';
import 'features/location/providers/location_notifier.dart';
import 'features/location/data/repositories/location_repository_impl.dart';
import 'features/location/presentation/screens/location_picker_screen.dart';
import 'features/location/presentation/widgets/property_map_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Client
  final apiClient = ApiClient();

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
      providers: [
        // Auth Providers
        Provider<AuthRepositoryImpl>(
          create: (_) => AuthRepositoryImpl(apiClient: apiClient),
        ),
        ChangeNotifierProvider<AuthNotifier>(
          create: (context) => AuthNotifier(
            authRepository: context.read<AuthRepositoryImpl>(),
          )..initialize(),
        ),
        // Property Providers
        Provider<PropertyRepositoryImpl>(
          create: (_) => PropertyRepositoryImpl(apiClient: apiClient),
        ),
        ChangeNotifierProvider<PropertyNotifier>(
          create: (context) => PropertyNotifier(
            propertyRepository: context.read<PropertyRepositoryImpl>(),
          ),
        ),
        // Payment Providers
        Provider<PaymentRepositoryImpl>(
          create: (_) => PaymentRepositoryImpl(apiClient: apiClient),
        ),
        ChangeNotifierProvider<PaymentNotifier>(
          create: (context) => PaymentNotifier(
            paymentRepository: context.read<PaymentRepositoryImpl>(),
          ),
        ),
        // Notification Providers
        Provider<NotificationRepositoryImpl>(
          create: (_) => NotificationRepositoryImpl(apiClient: apiClient),
        ),
        ChangeNotifierProvider<NotificationNotifier>(
          create: (context) => NotificationNotifier(
            notificationRepository: context.read<NotificationRepositoryImpl>(),
          ),
        ),
        // Location Providers
        Provider<LocationRepositoryImpl>(
          create: (_) => LocationRepositoryImpl(),
        ),
        ChangeNotifierProvider<LocationNotifier>(
          create: (context) => LocationNotifier(
            repository: context.read<LocationRepositoryImpl>(),
          )..checkPermission(),
        ),
      ],
      child: const RoomlyApp(),
    ),
  );
}

class RoomlyApp extends StatelessWidget {
  const RoomlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        darkTheme: AppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        ),
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const PropertyListScreen(),
        '/access-pass': (context) => const AccessPassPurchaseScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const SearchScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/my-listings': (context) => const MyListingsScreen(),
        '/add-property': (context) => const AddPropertyScreen(),
        '/pick-location': (context) => const LocationPickerScreen(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child!,
        );
      },
    ), // End ScreenUtilInit
    ); // End MultiProvider
  }
}
