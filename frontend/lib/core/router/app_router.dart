import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/modules/breast_cancer/upload_screen.dart';
import '../../features/modules/breast_cancer/processing_screen.dart';
import '../../features/modules/breast_cancer/results_screen.dart';
import '../../features/modules/breast_cancer/explainability_screen.dart';
import '../../features/modules/breast_cancer/report_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/breast/upload', builder: (context, state) => const UploadScreen()),
      GoRoute(path: '/breast/processing', builder: (context, state) => const ProcessingScreen()),
      GoRoute(path: '/breast/results', builder: (context, state) => const ResultsScreen()),
      GoRoute(path: '/breast/explain', builder: (context, state) => const ExplainabilityScreen()),
      GoRoute(path: '/breast/report', builder: (context, state) => const ReportScreen()),
      GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ],
  );
});
