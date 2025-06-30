import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:school_management_app/core/utils/app_animation.dart';
import 'package:school_management_app/presentation/screens/dashboard/admin_dashboard_screen.dart';
import 'package:school_management_app/presentation/screens/auth/login_screen.dart';
import 'package:school_management_app/presentation/screens/dashboard/student_dashboard_screen.dart';
import 'package:school_management_app/presentation/screens/dashboard/teacher_dashboard_screen.dart';
import 'package:school_management_app/presentation/screens/auth/signup_screen.dart';
import 'package:school_management_app/presentation/viewmodels/auth_view_model.dart';

class MyAppRouter {
  final AuthViewModel loginViewModel;

  MyAppRouter(this.loginViewModel);

  late final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) {
          return AppAnimations.customSlideTransition(
            key: state.pageKey,
            child: const LoginScreen(),
          );
        },
      ),
      GoRoute(
        path: '/signup', // New route for signup
        name: 'signup',
        pageBuilder: (context, state) {
          return AppAnimations.customSlideTransition(
            key: state.pageKey,
            child: const SignupScreen(),
          );
        },
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (context, state) {
          return AppAnimations.customSlideTransition(
            key: state.pageKey,
            child: const AdminDashboardScreen(),
          );
        },
      ),
      GoRoute(
        path: '/teacher',
        name: 'teacher',
        pageBuilder: (context, state) {
          return AppAnimations.customSlideTransition(
            key: state.pageKey,
            child: const TeacherDashboardScreen(),
          );
        },
      ),
      GoRoute(
        path: '/student',
        name: 'student',
        pageBuilder: (context, state) {
          return AppAnimations.customSlideTransition(
            key: state.pageKey,
            child: const StudentDashboardScreen(),
          );
        },
      ),
    ],
    initialLocation: '/login', // Start at the login screen
    refreshListenable: loginViewModel, // Listen to loginViewModel for changes
    redirect: (context, state) {
      final loggedIn = loginViewModel.currentUser != null;
      final loggingIn = state.matchedLocation == '/login';
      final signingUp =
          state.matchedLocation == '/signup'; // Check if signing up

      // If not logged in and not trying to log in or sign up, redirect to login
      if (!loggedIn && !loggingIn && !signingUp) {
        return '/login';
      }

      // If logged in
      if (loggedIn) {
        // If trying to log in or sign up while already logged in, redirect to appropriate dashboard
        if (loggingIn || signingUp) {
          final userRole = loginViewModel.userRole;
          if (userRole == 'admin') return '/admin';
          if (userRole == 'teacher') return '/teacher';
          if (userRole == 'student') return '/student';
          // If logged in but role not found, maybe redirect to a generic home or logout
          return '/login'; // Or handle no role scenario
        }
      }

      // No redirect needed
      return null;
    },
  );
}
