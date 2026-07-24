import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomly/core/theme/app_theme.dart';
import 'package:roomly/core/constants/app_strings.dart';
import 'package:roomly/presentation/providers/auth_notifier.dart';
import 'package:roomly/data/repositories/auth_repository_impl.dart';
import 'package:roomly/data/repositories/payment_repository_impl.dart';
import 'package:roomly/data/repositories/property_repository_impl.dart';
import 'package:roomly/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:roomly/core/network/api_client.dart';
import 'package:roomly/features/auth/presentation/screens/login_screen.dart';
import 'package:roomly/features/properties/presentation/screens/property_list_screen.dart';
import 'package:roomly/features/payment/providers/payment_notifier.dart';
import 'package:roomly/features/payment/presentation/screens/access_pass_purchase_screen.dart';
import 'package:roomly/features/properties/providers/property_notifier.dart';
import 'package:roomly/features/profile/presentation/screens/profile_screen.dart';
import 'package:roomly/features/search/presentation/screens/search_screen.dart';
import 'package:roomly/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:roomly/features/notifications/providers/notification_notifier.dart';
import 'package:roomly/features/properties/presentation/screens/my_listings_screen.dart';
import 'package:roomly/features/properties/presentation/screens/add_property_screen.dart';
import 'package:roomly/features/properties/presentation/screens/add_property_flow_screen.dart';
import 'package:roomly/features/properties/providers/add_property_flow_notifier.dart';
import 'package:roomly/features/location/providers/location_notifier.dart';
import 'package:roomly/features/location/data/repositories/location_repository_impl.dart';
import 'package:roomly/features/location/presentation/screens/location_picker_screen.dart';
import 'package:roomly/features/search/data/repositories/search_repository_impl.dart';
import 'package:roomly/features/search/providers/search_notifier.dart';
import 'package:roomly/data/repositories/review_repository_impl.dart';
import 'package:roomly/features/reviews/providers/review_notifier.dart';
import 'package:roomly/data/repositories/enquiry_repository_impl.dart';
import 'package:roomly/features/enquiries/providers/enquiry_notifier.dart';
import 'package:roomly/features/enquiries/presentation/screens/enquiry_list_screen.dart';
import 'package:roomly/features/enquiries/presentation/screens/enquiry_chat_screen.dart';
import 'package:roomly/features/notifications/providers/app_notification_manager.dart';
import 'package:roomly/features/notifications/presentation/widgets/notification_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API Client
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
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
        // Multi-step Add Property Flow Provider (clean-arch: depends on Property + Payment repositories)
        ChangeNotifierProvider<AddPropertyFlowNotifier>(
          create: (context) => AddPropertyFlowNotifier(
            propertyRepository: context.read<PropertyRepositoryImpl>(),
            paymentRepository: context.read<PaymentRepositoryImpl>(),
          ),
        ),
        // Search Providers with refined map filter queries
        Provider<SearchRepositoryImpl>(
          create: (_) => SearchRepositoryImpl(apiClient: apiClient),
        ),
        ChangeNotifierProvider<SearchNotifier>(
          create: (context) => SearchNotifier(
            searchRepository: context.read<SearchRepositoryImpl>(),
          )..initialize(),
        ),
        // Review Providers
        Provider<ReviewRepositoryImpl>(
          create: (_) => ReviewRepositoryImpl(apiClient: apiClient),
        ),
        ChangeNotifierProvider<ReviewNotifier>(
          create: (context) => ReviewNotifier(
            reviewRepository: context.read<ReviewRepositoryImpl>(),
          ),
        ),
        // Enquiry & Booking Chat Providers (production-grade)
        Provider<EnquiryRepositoryImpl>(
          create: (_) => EnquiryRepositoryImpl(apiClient: apiClient),
        ),
        ChangeNotifierProvider<EnquiryNotifier>(
          create: (context) => EnquiryNotifier(
            enquiryRepository: context.read<EnquiryRepositoryImpl>(),
          )..loadAllEnquiries(),
        ),
        // App-wide Real-time Notification Manager (matches active chat + subscription state changes)
        ChangeNotifierProvider<AppNotificationManager>(
          create: (_) => AppNotificationManager(),
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
    return AppNotificationListener(
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
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
          '/add-property-flow': (context) => const AddPropertyFlowScreen(),
          '/pick-location': (context) => const LocationPickerScreen(),
          '/enquiries': (context) => const EnquiryListScreen(),
          '/enquiry-chat': (context) => const EnquiryListScreen(),
        },
        builder: (context, child) {
          return NotificationOverlay(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
