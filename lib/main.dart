import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/services/local_data_services.dart';
import 'core/utils/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/dashboard/admin_dashboard_screen.dart';
import 'presentation/screens/dashboard/student_dashboard_screen.dart';
import 'presentation/screens/dashboard/teacher_dashboard_screen.dart';
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/viewmodels/admin_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localDataService = LocalDataService();
  await localDataService.initialize();
  runApp(MyApp(localDataService: localDataService));
}

class MyApp extends StatelessWidget {
  final LocalDataService localDataService;

  const MyApp({super.key, required this.localDataService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: localDataService),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(localDataService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminViewModel(localDataService),
        ),
      ],
      child: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'School Management App',
            theme: AppTheme.lightTheme,
            routerConfig: _createRouter(authViewModel),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/teacher',
          builder: (context, state) => const TeacherDashboardScreen(),
        ),
        GoRoute(
          path: '/student',
          builder: (context, state) => const StudentDashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        final userRole = authViewModel.userRole;
        final currentPath = state.uri.path;

        if (userRole == null && currentPath != '/' && currentPath != '/signup') {
          return '/';
        }

        if (userRole != null && (currentPath == '/' || currentPath == '/signup')) {
          switch (userRole) {
            case 'admin':
              return '/admin';
            case 'teacher':
              return '/teacher';
            case 'student':
              return '/student';
          }
        }

        return null;
      },
    );
  }
}
