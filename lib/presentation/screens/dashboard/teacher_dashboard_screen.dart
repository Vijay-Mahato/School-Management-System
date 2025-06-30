import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/models/teacher.dart';
import '../../../core/services/local_data_services.dart';
import '../../../core/utils/app_theme.dart';
import '../../viewmodels/auth_view_model.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 24),
            _buildTeacherInfoCard(context),
            const SizedBox(height: 24),
            _buildQuickActions(context),
            const SizedBox(height: 24),
            _buildMyClasses(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.secondaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        authViewModel.currentUser?.name ?? 'Teacher',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: -0.3, delay: 200.ms);
      },
    );
  }

  Widget _buildTeacherInfoCard(BuildContext context) {
    return Consumer2<AuthViewModel, LocalDataService>(
      builder: (context, authViewModel, localDataService, child) {
        final currentUser = authViewModel.currentUser;
        if (currentUser == null) return const SizedBox();

        final teacher = localDataService.getTeachers().firstWhere(
              (t) => t.email == currentUser.email,
          orElse: () => Teacher(
            id: '',
            name: 'Unknown',
            email: '',
            teacherIdNumber: '',
            subject: '',
          ),
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teacher Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(context, 'Name', teacher.name, Icons.person),
                _buildInfoRow(context, 'Teacher ID', teacher.teacherIdNumber, Icons.badge),
                _buildInfoRow(context, 'Subject', teacher.subject, Icons.subject),
                _buildInfoRow(context, 'Email', teacher.email, Icons.email),
              ],
            ),
          ),
        ).animate().slideX(begin: -0.3, delay: 400.ms);
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              context,
              'Grade Students',
              Icons.grade,
              AppTheme.primaryColor,
                  () => _showComingSoon(context),
            ).animate().scale(delay: 600.ms),
            _buildActionCard(
              context,
              'Create Assignment',
              Icons.assignment,
              AppTheme.secondaryColor,
                  () => _showComingSoon(context),
            ).animate().scale(delay: 800.ms),
            _buildActionCard(
              context,
              'Attendance',
              Icons.how_to_reg,
              AppTheme.successColor,
                  () => _showComingSoon(context),
            ).animate().scale(delay: 1000.ms),
            _buildActionCard(
              context,
              'Class Schedule',
              Icons.schedule,
              Colors.orange,
                  () => _showComingSoon(context),
            ).animate().scale(delay: 1200.ms),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyClasses(BuildContext context) {
    return Consumer<LocalDataService>(
      builder: (context, localDataService, child) {
        final classes = localDataService.getStudents()
            .map((s) => s.className)
            .toSet()
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Classes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (classes.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No classes assigned yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final className = classes[index];
                  final studentsInClass = localDataService?.getStudents()
                      .where((s) => s.className == className)
                      .length;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                        child: Text(
                          className.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(className),
                      subtitle: Text('$studentsInClass students'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showComingSoon(context),
                    ),
                  ).animate().slideX(begin: 0.3, delay: (index * 100 + 1400).ms);
                },
              ),
          ],
        );
      },
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await context.read<AuthViewModel>().logout();
      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
